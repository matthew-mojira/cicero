#ifndef EXPR_H
#define EXPR_H

#include <stdint.h>

#include "sexp.h"
#include "value.h"

/* constructor */
Value *parse_sexp(Sexp *);

/* operations on expressions */
Value *e_eval(Value *);
Value *e_noeval(Value *);
Value *e_print(Value *);

#endif
