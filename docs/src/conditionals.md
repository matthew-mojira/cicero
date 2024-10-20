# Conditionals

The conditional expression `if/else` can be used for conditional evaluation
between two sub-expressions. A basic example:

```
if 1 = 2 then
  30
else
  40
=> 40
```

The *condition* (in the above example, `1 = 2`) must be a boolean expression.
Boolean expressions can either be
* boolean literals `true` and `false`
* boolean operations `and` and `or` for compound expressions
* equality comparisons `=`, `!=`
* integer comparisons `<`, `>`, `<=`, `>=`

Unlike other languages, where conditionals are *statements*, the `else` branch
may not be omitted, because there needs to be a value for the false case. That
also means it may be used in assignments, like:

```
var x = if true or false then 1 else 0
```
