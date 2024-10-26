# Boxes

The box construct is designed to be a gentle introduction to indirection, which
appears as pointers or references in other languages.

A boxed value is a container for another value, which can be mutated. The main
purpose is so that two variables can share a value. It is best learned by
example.

We can create a boxed value using the `box` operator:

```
var x = box 2
=> box[#0]
```

Here, the variable `x` is created whose initial value is a box, and the box
holds the number 2. `x` is *not* an integer, but a box holding an integer. One
can get the value out of the box using the `unbox` operator:

```
unbox x
=> 2
```

We can change the value inside a box using the `<-` operator, where the
left-hand expression is a box and the right-hand expression is the new value to
put in the box:

```
x <- 4
x
=> box[#0]
```

`x` is still in the main box, but we see that the value in the box has changed:

```
unbox x
=> 4
```

The box's utility comes in how we can "share" values between two variables:

```
const y = x
unbox y
=> 4
```

Here, `x` and `y` both are the same box, but we can change the value inside the
box:

```
y <- 6
unbox y
=> 6
unbox x
=> 6
```

Even though `y` is a constant (set to the box) the value inside the box is
*not* constant, so it can be mutated.

## Boxes with type constraints

One can specify a type for which values in the box must satisfy:

```
box[int_t](5)
```
