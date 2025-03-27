#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "expr.h"
#include "interp.h"
#include "sexp.h"
#include "value.h"

#define BUFFER_SIZE 1999

int main(int argc, char **argv) {
	switch (argc) {
	case 2:
		if (argc != 2) {
			fprintf(stderr, "usage: %s <file>\n", argv[0]);
		}

		Sexp **sexps = parse_sexps(argv[1]);

		if (sexps == NULL) exit(EXIT_FAILURE);

		/* print out all found sexps */
		uint32_t i;
		for (i = 0; sexps[i] != NULL; i++) {
			print_sexp(sexps[i]);
			putchar('\n');
			Expr *expr = parse_sexp(sexps[i]);
			print_expr(expr);
			putchar('\n');
			print_value(eval_expr(expr));
			putchar('\n');
			// free_sexp(sexps[i]);
		}

		exit(EXIT_SUCCESS);
	case 1:
		char buf[BUFFER_SIZE];
		while (1) {
			printf("cicero> ");
			if (!fgets(buf, sizeof(buf), stdin)) break;

			Sexp **sexps = parse_sexps(buf);
			assert(sexps != NULL);
			assert(sexps[0] != NULL);

			Expr *expr = parse_sexp(sexps[0]);
			print_value(eval_expr(expr));
			putchar('\n');
		}
	default:
		exit(EXIT_FAILURE);
	}
}
