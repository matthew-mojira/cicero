#include <inttypes.h>

/* What are values in cicero are objects in CPython. In CPython, objects are
 * represented using a fake supertype (PyObject) and each object struct gets
 * a common header provided by a macro. Here, we use a more conventional
 * tag-union approach.
 */

#ifndef VALUE_H
#define VALUE_H

#define assert_type(T, V) (assert(v_type(V) == T))

typedef struct _value Value;

#include "type.h"

/* memory management */
Value *alloc_value(Type, void *);
void free_value(Value *);

/* struct access */
Type v_type(Value *);
void *v_data(Value *);

/* operations on values */
Value *v_typeof(Value *);
Value *v_print(Value *);

#endif
