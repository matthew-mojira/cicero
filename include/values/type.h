#ifndef TYPE_H
#define TYPE_H

typedef enum {
	INT_T, FUNC_T, TYPE_T, POOPCRAP_T, EXPR_T, BOOL_T
} Type;

#include "value.h"

/* operations on types */
Value *t_print(Value *);

#endif
