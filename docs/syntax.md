# Syntactic language features

Some things look like function calls (since it's all s-expressions) but are not,
since it requires some different semantics not usually representable in a
function definition (usually non-strict evaluation or control flow).

The arity of these language features are checked at parse time, and arity
mismatches are treated as parse errors and not exceptions.

## Conditional evaluation

### `if`

```
(if e1 e2 e3)
```
`e1`, `e2` and `e3` are expressions.

Evaluates `e1`. If `e1` is a truthy value (read: not necessarily boolean), then
`e2` is evaluated and is the value of the entire expression. Otherwise, `e3` is
evaluated and is the value of the entire expression.

### `cond`

```
(cond
  (e1 f1)
  (e2 f2)
  ...
  (en fn))
```
All of the `ei`s and `fi`s are expressions. There must be at least one case.

Evaluates the `ei`s in order until it evaluates to a truthy value, then `f1` is
evaluated and is the value of the entire expression.

An exception is raised if no cases evaluate to a truthy value.

### `while`

```
(while e1
  e2)
```

Evaluates `e1`. If it is a truthy value, evaluate `e2`. Loop until `e1`
evaluates to a falsey value. The value of the entire expression is the value
from evaluating `e1` during the one time it is false.

## Chaining evaluation

```
(begin e1 e2 ... en)
{ e1 e2 ... en }
```
There must be at least one expression.

Evaluates each expression `ei` in order. The value of the entire expression is
the value from evaluating `en`.

## Functions

```
(func (f x1 x2 ... xn)
  e)
```
`f` and all of the `xi`s are identifiers. There may be zero or more `xi`s.

Creates a function and binds it to `f` in the current scope. The value of the
entire expression is the function.

## Variables

```
(set x e)
```

Evaluates `e` and binds it to `x` in the current scope. The value of the entire
expression is the value from `e`.

## Exception handling

### `raise`

```
(raise e)
```

Evaluates `e` and raises its value as an exception. 

### `try`

```
(try
  e1
  x e2)
```
`x` is an identifier.

Evaluates `e1`. If it raises an exception, then the exception value is bound
to `x`, then `e2` is evaluated and is the value of the entire expression.
Otherwise, the value from evaluating `e1` is the value of the entire expression.

## Objects

### `class`

```
(class x
  (extends c)
  (init i)
  (field x1 e1)
  (field x2 e2)
  ...
  (field xn en)
  (method (f1 y11 y12 ... y1n1) g1)
  (method (f2 y21 y22 ... y2n2) g2)
  ...
  (method (fm ym1 ym2 ... ymnm) gm)
```
`x` and the `xi`s and `fi`s are identifiers. `c`, `i`, and the `ei`s, yi`s, and
`gi`s are all expressions. The clauses inside the `class` except for the class
identifier `x` may be written in any order. Any clause may be omitted, so an
"empty" class `(class X)` is valid.

Evaluates `c` and throws an exception if it does not evaluate to a class
object. If the `extends` clause is omitted, then the class is considered a
subclass of the base class. Creates a class object and binds it to `x` in the
local scope. The value of the entire expression is also this class object.

### `new`

```
(new e)
```

`e` must evaluate to a class. Instantiates an object of that class. The
instantiation process works as follows:

For each superclassclass from the class of `e` to the base class:
* for each field `xi` not already bound, `ei` is evaluated in a new scope and 
  `xi` is set to that value. The `ei` expression may not see other fields or
  the object `self`.
* the expression `i` in the `init` clause is evaluated in a new scope. It may
  see the fields of the object through `self`.
* Nothing happens yet with methods. See comments for `get-field` down below.

The value of the entire expression is the newly created object.

### `get-field`

```
(get-field x e)
e.x
```

Accesses the field `x` of the object evaluated in `e`. If the object contains 
the field, then that field value is the value of the entire expression. If 
there is nothing bound to `x`, then the runtime looks into the class of the 
object for its methods, searching superclasses until it reaches the base object. 
If it finds a method with that name, it creates a method object and binds it as
a field of the object, returning that value. Otherwise, it raises an exception.

### `set-field`

```
(set-field x e1 e2)
```

Sets the field `x` of the object `e1` to the value in `e2`. Throws an exception
if `e1` does not have anything bound to `x` (note: that includes methods which
have not yet been bound). The value of the entire expression is the value from
`e2`.

