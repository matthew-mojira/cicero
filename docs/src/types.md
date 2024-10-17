# Types

The types in Cicero are:
* `int`
* `bool`
* `box`
* `type`
* `void`

In Cicero, types are *first class*. That means they are values. Once can get
the type of a value using the `?` suffix operator:

```
(1 + 1)?
=> int
```
