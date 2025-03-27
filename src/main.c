#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "expr.h"
#include "interp.h"
#include "sexp.h"
#include "value.h"

int main(int argc, char **argv) {
	if (argc != 2) {
		fprintf(stderr, "usage: %s <file>\n", argv[0]);
		exit(EXIT_FAILURE);
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
}
