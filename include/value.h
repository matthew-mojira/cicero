#include <inttypes.h>

#ifndef VALUE_H
#define VALUE_H

typedef enum {
	INT_T
} Type;

typedef struct {
	uint64_t value;
} IntV;

typedef struct {
	Type v_type;
	union {
		IntV *v_int;
	} v_data;
} Value;

void print_value(Value *);

#endif
