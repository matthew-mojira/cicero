#ifndef BOOL_H
#define BOOL_H

/* constructor */
Value *b_true(void);
Value *b_false(void);

/* struct access */
int istrue(Value *);

/* operations on bools */
Value *b_print(Value *);

#endif
