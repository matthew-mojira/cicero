# Variables

Variables are places where you can store values. They are declared using the
`var` keyword, where you supply the name of the element and an initial value:

```
var x = 1
var y = 2
x + y
=> 3
```

Variables can be modified using the assignment operator in `:=`.

```
x := 2
x + y
=> 4
```

To declare a variable or constant and use it later, you will want to create a
*block expression* which allows the chaining of any number of expressions
together:

```
{
  var x = 1;
  var y = 2;
  x := x * 2;
  y := x + 375;
  x * y;
}
=> 754
```

The block expression also defines a *lexical scope* for the variable or
constant. Its scope is from the expression after the declaration expression to
the end of the block (which may include other block expressions).

## Duplicate names and shadowing

Duplicate names are allowed only if the declaration appears in a lower scope
than the original declaration. This is known as *shadowing*:

```
{
  var x = 1;
  {
    var x = 9;
    x := 10;
  };
  x;
}
=> 1
```

Right now, there is no way to access the value of `x` in the outer scope from
within the inner scope after the second `x` is declared.

## Typed variables

One can declare the type of values which can be assigned to a variable or
constant:

```
var x: int_t = 5
x := 6
```

In addition, one can use a `where` clause to define a condition which must hold
for an assignment to be made.

```
var i: int_t where i > 0 = 30
i := 20
i := 0   -- fails
```
