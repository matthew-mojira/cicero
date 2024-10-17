# Errors

Errors occur because of illegal behavior in code, that is, when a value for an
expression cannot be found.

## Type error

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

# Arithmetic error

Arithmetic errors can occur because of illegal operations in an arithmetic
exception. There is only one possible arithmetic error:
* division by zero: `1 / 0`

# Name error

A name error occurs when an identifier is used when it out of scope, or
otherwise hasn't been defined.

```
{
  const x = 1
}
x
```

# Redefinition error

A redefinition errors occurs when an identifier is used in two declarations
within the same scope.

```
var x = 1
const x = 2
```

# Assignment error

An assignment error occurs when an assignment is being made to a constant,
which cannot change, unlike variables:

```
const x = 1
x := 2
```

# Lexing/parsing error

Lexing or parsing errors can occur when the interpreter is reading in malformed
code. These occur before a program can be evaluated, because the interpreter
does not know how to understand the code it has been given.
