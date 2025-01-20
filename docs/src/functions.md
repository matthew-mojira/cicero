# Functions

Functions allow computations to be *abstracted* into a single callable unit.

A named function can be declared as follows, with the `func` keyword, followed
by its name, a list of parameters in parentheses, an arrow, and a body
expression.

```
func foo(x, y) -> {
  x + y;
};
```

We can call a function by providing arguments (using parentheses). The value of
a function call is the value of the body expression in the function, with the
argument values attached to the parameter names:

```
foo(10, 11);
=> 21
```

<!--Unlike other languages, the arguments are immutable (i.e. constant). This helps-->
<!--eliminate unintuitive behavior because of multiple expectations from assigning-->
<!--to arguments in other languages.-->

## Anonymous functions

Anonymous functions, also known as *lambdas*, are functions defined without
names. One can write a lambda similarly to the named function, but without the
name:

```
func (x) -> x + 1
```

## Higher-order functions

In Cicero, functions are first class. This means that one can refer to a
function by itself without calling it, and use it as a value to call other
functions with:

```
func apply(f, x) -> f(x);
apply((x) -> x + 1, 5);
=> 6
```

## Closure rules

All functions are *closures* over the environment in which they are declared.
Consider the following example:

```
var x = 10;
func bar(y) -> x + y;
```

The function `bar` can see the binding for `x`. When the function declaration
expression is evaluated, it copies the *current state* of the outside
environment (that is, existing bindings) so that it is available when that
function is called.

```
x := 20;
bar(5);
=> 15
```

However, the copy of the existing state is an *immutable* copy. Functions
cannot assign to things declared outside the function, even if it is a
variable. One can get around this by using indirection via the box.

## Recursion

Functions can refer to themselves and can even call themselves, commonly known
as *recursion*:

```
func fib(n) -> {
  if n < 2 then
    n
  else
    fib(n - 1) + fib(n - 2);
}
```

## Returning multiple values from a function

One can return multiple values from a function using the *tuple* construct:

```
func two() -> (1, 2)
```

Unlike other languages, tuples are not first class.

## Typed functions

One can specify patterns which arguments or return values must satisfy. These
are dynamically checked at call time and before returning.

```
func apply(f: func_t, x) -> f(x);
```

In this case, the return type and arity are untyped. One can specify how many
return values by separating them with `,`:

```
func bar(): int_t, bool_t -> (3, false);
```

To specify that the function does not return any values, use `void`:

```
func nothing(): void -> { };
```

One can also specify a condition in which arguments must satisfy when the
function is called using a `where` clause:

```
func isqrt(n: int_t where n >= 0): int_t -> {
  ...
}

func foo(x: int_t where x > 0,
         y: int_t where x + y /= 0) -> {
  ...
}
```
