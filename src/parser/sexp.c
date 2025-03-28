#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "sexp.h"

#define BUFFER_SIZE 80
#define MAX_DEPTH 80
#define MAX_SEXPS 1000 

#define RESET_BUFFER() 	memset(buffer, 0x00, BUFFER_SIZE);								\
			buf_index = 0;
#define CREATE_ATOMIC() struct sexp *new_sexp = malloc(sizeof(struct sexp));						\
			new_sexp->sexp_type = Atomic;									\
			new_sexp->start.line = buf_line;								\
			new_sexp->start.col = buf_col; 									\
			new_sexp->end.line = line; 									\
			new_sexp->end.col = col - 1; /* safe subtraction since `buf_index > 0` */ 			\
			new_sexp->size = buf_index;									\
			new_sexp->sexp_data.string = calloc(buf_index + 1, sizeof(char)); /* +1 for nul-terminated */	\
			memcpy(new_sexp->sexp_data.string, buffer, buf_index);

/* note: this is an unbuffered add and can grow to an unbounded size
*/
#define ADD_SEXP(NEW) \
			struct sexp *enclosing_sexp = stack[depth - 1]; /* safe index because `depth > 0` */			\
			enclosing_sexp->sexp_data.apply = reallocarray(enclosing_sexp->sexp_data.apply, enclosing_sexp->size + 1, sizeof(struct sexp *));	\
			enclosing_sexp->sexp_data.apply[enclosing_sexp->size] = NEW;									\
			enclosing_sexp->size += 1;


void print_sexp(Sexp *sexp) {
	assert(sexp != NULL);
	switch (sexp->sexp_type) {
	case Atomic:
		printf("%s", sexp->sexp_data.string);
		break;
	case Apply:
		putchar('(');
		uint32_t i = 0;
		while (i < sexp->size) {
			print_sexp(sexp->sexp_data.apply[i]);
			if (i < sexp->size - 1) putchar(' ');
			i++;
		}
		putchar(')');
		break;
	}
}

void free_sexp(Sexp *sexp) {
	assert(sexp != NULL);
	switch (sexp->sexp_type) {
	case Atomic:
		free(sexp->sexp_data.string);
		break;
	case Apply:
		uint32_t i;
		for (i = 0; i < sexp->size; i++) {
			free_sexp(sexp->sexp_data.apply[i]);
		}
		free(sexp->sexp_data.apply);
		break;
	}
	free(sexp);
}

Sexp **parse_sexps(const char *filename) {
	FILE *file = fopen(filename, "r");
	if (file == NULL) {
		perror("Error loading file");
		return NULL;
	}

	/* storing all s-expressions found */
	struct sexp *sexps[MAX_SEXPS];	/* inefficiently allocating max size (8kB) */
	uint32_t sexps_count = 0;

	/* reading in characters */
	char byte;
	/* stack for sexp */
	int32_t depth = 0;
	struct sexp *stack[MAX_DEPTH];
	/* atomic buffer */
	char buffer[BUFFER_SIZE];
	uint8_t buf_index;
	RESET_BUFFER();
	uint32_t buf_line = 1, buf_col = 0;
	/* line numbers */
	uint32_t line = 1, col = 0;
	while ((byte = fgetc(file)) != EOF) {
		col += 1;
		switch (byte) {
		case '(':
			/* if there is a word remaining, create atomic sexp and add to current */
			if (buf_index > 0) {
				CREATE_ATOMIC();
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "%s:%d:%d: too many s-expressions (max=%d)\n", filename, line, col, MAX_SEXPS);
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				} else {
					ADD_SEXP(new_sexp);
				}
				RESET_BUFFER();

				ADD_SEXP(new_sexp);
			}

			/* allocate new sexp, starting here */
			struct sexp *new_sexp = malloc(sizeof(struct sexp));
			new_sexp->sexp_type = Apply;
			new_sexp->start.line = line;
			new_sexp->start.col = col;
			new_sexp->size = 0;
			new_sexp->sexp_data.apply = NULL;
			
			/* push sexp onto the stack as the active sexp */
			stack[depth] = new_sexp;
			depth += 1;
			if (depth >= MAX_DEPTH) {
				fprintf(stderr, "%s:%d:%d: too many nested expressions (max=%d)\n", filename, line, col, MAX_DEPTH);
			}
			break;
		case ')':
			/* if there is a word remaining, create atomic sexp and add to current */
			if (buf_index > 0) {
				if (depth == 0) {
					fprintf(stderr, "%s:%d:%d: extraneous closing parenthesis\n", filename, line, col);
					fclose(file);
					return NULL;
				}
				CREATE_ATOMIC();
				RESET_BUFFER();

				ADD_SEXP(new_sexp);
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "%s:%d:%d: too many s-expressions (max=%d)\n", filename, line, col, MAX_SEXPS);
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				}
			}

			depth -= 1;
			if (depth < 0) {
				fprintf(stderr, "%s:%d:%d: extraneous closing parenthesis\n", filename, line, col);
				fclose(file);
				return NULL;
			}

			/* pull sexp from stack */
			struct sexp *done_sexp = stack[depth];
			/* exit if this was the last sexp */
			if (depth == 0)	{
				if (sexps_count >= MAX_SEXPS) {
					fprintf(stderr, "%s:%d:%d: too many s-expressions (max=%d)\n", filename, line, col, MAX_SEXPS);
				}
				sexps[sexps_count] = done_sexp;
				sexps_count += 1;
			} else {
				/* otherwise, add it to enclosing sexp */
				ADD_SEXP(done_sexp);
			}

			break;
		case '\n':
			if (buf_index > 0) {
				CREATE_ATOMIC();
				/* if there is no enclosing sexp, then add to top level */
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "%s:%d:%d: too many s-expressions (max=%d)\n", filename, line, col, MAX_SEXPS);
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				} else {
					ADD_SEXP(new_sexp);
				}
				RESET_BUFFER();
			}
			line += 1;
			col = 0;
		case ' ':
		case '\t':
		case '\r':
			if (buf_index > 0) {
				CREATE_ATOMIC();
				/* if there is no enclosing sexp, then add to top level */
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "%s:%d:%d: too many s-expressions (max=%d)\n", filename, line, col, MAX_SEXPS);
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				} else {
					ADD_SEXP(new_sexp);
				}
				RESET_BUFFER();
			}
			break;
		default:
			/* if the buffer is empty, record this character as the first of new string */
			if (buf_index == 0) {
				buf_line = line;
				buf_col = col;
			}
			/* push character onto buffer */
			buffer[buf_index] = byte;
			buf_index += 1;
			/* assert buffer is not too overlong after push */
			if (buf_index >= BUFFER_SIZE) {
				fprintf(stderr, "%s:%d:%d: overlong identifier (max=%d)\n", filename, line, col, BUFFER_SIZE - 1);
				fclose(file);
				return NULL;
			}
		}
	}
	fclose(file);

	if (depth != 0) {
		fprintf(stderr, "%s:%d:%d: unmatched closing parentheses\n", filename, line, col);
		return NULL;
	}

	/* we return a pointer to a null-terminated array of sexp pointers */
	Sexp **result = calloc(sexps_count + 1, sizeof(Sexp *));
	memcpy(result, sexps, sexps_count * sizeof(Sexp *));

	return result;
}

#undef MAX_SEXPS
#define MAX_SEXPS 1

Sexp *parse_sexp_stdin(void) {
	/* storing all s-expressions found */
	struct sexp *sexps[MAX_SEXPS];
	uint32_t sexps_count = 0;

	/* reading in characters */
	char byte;
	/* stack for sexp */
	int32_t depth = 0;
	struct sexp *stack[MAX_DEPTH];
	/* atomic buffer */
	char buffer[BUFFER_SIZE];
	uint8_t buf_index;
	RESET_BUFFER();
	uint32_t buf_line = 1, buf_col = 0;
	/* line numbers */
	uint32_t line = 1, col = 0;
	while ((byte = fgetc(stdin)) != EOF) {
		col += 1;
		switch (byte) {
		case '(':
			/* if there is a word remaining, create atomic sexp and add to current */
			if (buf_index > 0) {
				CREATE_ATOMIC();
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "<stdin>:%d:%d: too many s-expressions (max=%d)\n", line, col, MAX_SEXPS);
						return NULL;
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				} else {
					ADD_SEXP(new_sexp);
				}
				RESET_BUFFER();

				ADD_SEXP(new_sexp);
			}

			/* allocate new sexp, starting here */
			struct sexp *new_sexp = malloc(sizeof(struct sexp));
			new_sexp->sexp_type = Apply;
			new_sexp->start.line = line;
			new_sexp->start.col = col;
			new_sexp->size = 0;
			new_sexp->sexp_data.apply = NULL;
			
			/* push sexp onto the stack as the active sexp */
			stack[depth] = new_sexp;
			depth += 1;
			if (depth >= MAX_DEPTH) {
				fprintf(stderr, "<stdin>:%d:%d: too many nested expressions (max=%d)\n", line, col, MAX_DEPTH);
				fflush(stdin);
				return NULL;
			}
			break;
		case ')':
			/* if there is a word remaining, create atomic sexp and add to current */
			if (buf_index > 0) {
				if (depth == 0) {
					fprintf(stderr, "<stdin>:%d:%d: extraneous closing parenthesis\n", line, col);
					fflush(stdin);
					return NULL;
				}
				CREATE_ATOMIC();
				RESET_BUFFER();

				ADD_SEXP(new_sexp);
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "<stdin>:%d:%d: too many s-expressions (max=%d)\n", line, col, MAX_SEXPS);
						fflush(stdin);
						return NULL;
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				}
			}

			depth -= 1;
			if (depth < 0) {
				fprintf(stderr, "<stdin>:%d:%d: extraneous closing parenthesis\n", line, col);
				fflush(stdin);
				return NULL;
			}

			/* pull sexp from stack */
			struct sexp *done_sexp = stack[depth];
			/* exit if this was the last sexp */
			if (depth == 0)	{
				if (sexps_count >= MAX_SEXPS) {
					fprintf(stderr, "<stdin>:%d:%d: too many s-expressions (max=%d)\n", line, col, MAX_SEXPS);
					fflush(stdin);
					return NULL;
				}
				sexps[sexps_count] = done_sexp;
				sexps_count += 1;
			} else {
				/* otherwise, add it to enclosing sexp */
				ADD_SEXP(done_sexp);
			}

			break;
		case '\n':
			if (buf_index > 0) {
				CREATE_ATOMIC();
				/* if there is no enclosing sexp, then add to top level */
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "<stdin>:%d:%d: too many s-expressions (max=%d)\n", line, col, MAX_SEXPS);
						fflush(stdin);
						return NULL;
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				} else {
					ADD_SEXP(new_sexp);
				}
				RESET_BUFFER();
			}
			if (sexps_count > 0) {
				goto end;
			}
			line += 1;
			col = 0;
		case ' ':
		case '\t':
		case '\r':
			if (buf_index > 0) {
				CREATE_ATOMIC();
				/* if there is no enclosing sexp, then add to top level */
				if (depth == 0) {
					if (sexps_count >= MAX_SEXPS) {
						fprintf(stderr, "<stdin>:%d:%d: too many s-expressions (max=%d)\n", line, col, MAX_SEXPS);
						fflush(stdin);
						return NULL;
					}
					sexps[sexps_count] = new_sexp;
					sexps_count += 1;
				} else {
					ADD_SEXP(new_sexp);
				}
				RESET_BUFFER();
			}
			break;
		default:
			/* if the buffer is empty, record this character as the first of new string */
			if (buf_index == 0) {
				buf_line = line;
				buf_col = col;
			}
			/* push character onto buffer */
			buffer[buf_index] = byte;
			buf_index += 1;
			/* assert buffer is not too overlong after push */
			if (buf_index >= BUFFER_SIZE) {
				fprintf(stderr, "<stdin>:%d:%d: overlong identifier (max=%d)\n", line, col, BUFFER_SIZE - 1);
				fflush(stdin);
				return NULL;
			}
		}
	}
end:
	assert(sexps_count <= 1);
	fflush(stdin);
	if (sexps_count == 0) return NULL;
	return sexps[0];
}
