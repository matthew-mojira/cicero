#ifndef INT_H
#define INT_H

#include <inttypes.h>
#include "value.h"

typedef struct _int Int;

/* constructor */
Value *int_to_value(uint64_t);

/* struct access */
uint64_t value_to_int(Value *);


/* operations on integers */
Value *i_add(Value *, Value *);

#endif
