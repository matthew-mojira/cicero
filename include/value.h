#ifndef VALUE_H
#define VALUE_H

typedef enum {
	INT_T
} Type;

typedef struct {
	long long value;
} IntV;

typedef struct {
	Type v_type;
	union {
		IntV *v_int;
	} v_data;
} Value;

#endif
