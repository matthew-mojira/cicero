# Errors

Errors occur because of illegal behavior in code, that is, when a value for an
expression cannot be found.

## Kinds of errors

### Type error

Type errors occur when there is a mismatch in types, where the actual type in
an expression does not match the expected type. 

An example is the use of a non-boolean value in a condition expression. Unlike
other languages which may accept this, Cicero requires that a condition must
evaluate to a boolean:

```
if 1 + 1 then
  2
else
  3
```

Type errors can also happen when a expression returns the wrong arity:

```
var x = (1, 2)
```

### Assertion error

A runtime assertion (at present, a `where` clause) did not evaluate to true.

### Arithmetic error

Arithmetic errors can occur because of illegal operations in an arithmetic
exception. There is only one possible arithmetic error:
* division by zero: `1 / 0`

### Name error

A name error occurs when an identifier is used when it out of scope, or
otherwise hasn't been defined.

```
{
  var x = 1;
};
x;
```

### Redefinition error

A redefinition errors occurs when an identifier is used in two declarations
within the same scope.

```
var x = 1
var x = 2
```

### Assignment error

An assignment error occurs when an assignment is being made to an
immutable variable:

```
var x = 1;
func foo() -> {
  x := 3;
};
x := 2;
foo();
```

### Lexing/parsing error

Lexing or parsing errors can occur when the interpreter is reading in malformed
code. These occur before a program can be evaluated, because the interpreter
does not know how to understand the code it has been given.

## Handling errors

The `try` and `catch` block allows for handling errors:

```
try {
  1 / 0;
} catch {
  2;
};
=> 2
```
