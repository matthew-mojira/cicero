# Variables and constants

Variables and constants are places where you can store values. They are
declared using the `var` and `const` keywords, where you supply the name of the
element and an initial value:

```
var x = 1
const y = 2
x + y
=> 3
```

Variables can be modified using the assignment operator in `:=`. Constants,
however, cannot be modified and will result in an error.

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
  var x = 1
  var y = 2
  x := x * 2
  y := x + 375
  x * y
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
  const x = 1
  {
    var x = 9
    x := 10
  }
  x
}
=> 1
```

Right now, there is no way to access the value of `x` in the outer scope from
within the inner scope after the second `x` is declared.

## Type patterns

One can declare the type of values which can be assigned to a variable or
constant:

```
var x: int_t = 5
x := 6
```
