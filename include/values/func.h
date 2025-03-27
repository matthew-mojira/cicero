#include <stddef.h>

#ifndef FUNC_H
#define FUNC_H

#include "value.h"

/* constructor */
Value *builtin_to_value(size_t, Value *(*)());

/* struct access */
size_t f_params(Value *);

/* operations on functions */
Value *f_call(Value *, Value **);

#endif
