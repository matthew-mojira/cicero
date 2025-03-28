#ifndef INT_H
#define INT_H

#include <inttypes.h>
#include "value.h"

typedef struct _int Int;

/* constructor */
Value *int_to_value(uint64_t);

/* operations on integers */
Value *i_add(Value *, Value *);
Value *i_print(Value *);

#endif
