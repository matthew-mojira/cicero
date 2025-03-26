#include "value.h"

void print_value(Value *value) {
	switch (value->v_type) {
	case INT_T:
		IntV *v_int = value->v_data.v_int;
		printf("%ld", v_int->value);
		break;
	}
}
