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

