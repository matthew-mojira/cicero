# Gradual typing

Cicero allows for *gradual typing* which allows for the use of both static and
dynamic typing. 

By annotating some expressions and variables with types, Cicero
can statically determine if there is a type mismatch. Omitting type information
leaves an element as untyped, which will be allowed to run. However, dynamic
type errors will occur if there is a type mismatch at runtime.
Use of the static type checker is optional. Users

## Mixing and matching typed and untyped expressions

Cicero will generally accept untyped expressions in areas where there are type
patterns. For example:

```
func add1(x: int) -> x + 1;

```

## Type patterns

Restrictions on values are written using *type patterns* which are a little
more advanced 
