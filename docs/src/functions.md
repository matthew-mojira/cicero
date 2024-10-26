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

## Anonymous functions

Anonymous functions, also known as *lambdas*, are functions defined without
names. One can write a lambda similarly to the named function, but without the
name:

```
(x) -> x + 1
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
