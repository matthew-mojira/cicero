# Types

The types in Cicero are:
* `int`
* `bool`
* `box`
* `type`
* `func`

In Cicero, types are *first class*. That means they are values. The literal
versions are the name of the type with `_t` appended.

One can get the type of a value using the `?` suffix operator:

```
(1 + 1)?
=> int
```

## Dynamic typing

There is no static type checking. All types are checked dynamically.

## Recursive types

The `box` type is recursive, with an additional parameter specifying the types
of an element it holds:

```
box_t[int_t]
```

The `_` term represents a *wild card* meaning the type of a box whose contents
can be any time.
