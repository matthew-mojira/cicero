#ifndef SEXP_H
#define SEXP_H

#include "posn.h"

typedef struct sexp {
	Posn start;
	Posn end;

	enum { Atomic, Apply } sexp_type; /* tag for union */
	uint32_t size;
	/* `size` is either
	 * - Atomic: length of string (string is also nul-terminated)
	 * - Apply: length of sexp array
	 */
	union {
		char *string;
		struct sexp **apply;
	} sexp_data;
} Sexp;

void print_sexp(Sexp *);
void free_sexp(Sexp *);

Sexp **parse_sexps(const char *filename);

#endif
