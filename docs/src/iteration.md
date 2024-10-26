# Iteration

One can perform iteration using a `while` loop, which evaluates an expression
as long as a condition is met:

```
var x = 10;
while x > 0 do {
  x := x - 1;
};
```

The value of the expression is the value of the body expression during the last
iteration before the condition evaluates to false, or nothing if the condition
is false the first time.
