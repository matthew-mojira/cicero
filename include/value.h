#include <inttypes.h>

#ifndef VALUE_H
#define VALUE_H

typedef struct _value Value;

typedef enum {
	INT_T, FUNC_T
} Type;

typedef struct {
	uint64_t value;
} IntV;

typedef struct {
	size_t n_params;
	Value *(*func)(Value *, ...);
} FuncV;

typedef struct _value {
	Type v_type;
	union {
		IntV *v_int;
		FuncV *v_func;
	} v_data;
};

void print_value(Value *);

#endif
