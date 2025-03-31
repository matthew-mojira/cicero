# Cicero language features

## Types and values

* Int - backed by a Virgil integer
* Bool
* Func
* Str
* Type
* PoopCrap - this is the unit type, what is `null` or `None` in other languages.
  The literal form of PoopCrap is `()`.

### Truthiness

The truthiness of PoopCrap and `false` is False. Every other value is True.

## Syntax

Cicero uses s-expressions for its grammar to make life easy for the
implementers (not so much for the programmers).

### Identifiers

Identifiers may be any sequence of characters as long as:
* it does not contain whitespace, `'`, `"`, `(`, `)`, `[`, or `]`
* it does not have an integer literal as as a prefix (e.g. `1250xpdsr`) --
  although this is broken for very large literals, so don't try it
* it is not a literal (right now it is always parsed as a literal)

An identifier *may* be a keyword or literal. This probably causes weird
behavior so you probably sohuldn't do it (and I should probably disallow it).

### Literals

The literals are:

* an integer encoded in base 10
* `true` and `false`
* `int`, `bool`, `func`, `str`, `type`, `poopcrap` referring to those types
* `()` as the PoopCrap literal

### Comments

No comments supported.

## Evaluation

Here is how the easy things evaluate:

* The value of a literal is its value!
* The value of the identifier is a lookup in the environment. Right now you
  can't define your own variables so it is only the built-ins.
* To evaluate a function call `(f e1 e2 ... en)`:
  - evaluate `f`
  - assert `f` is a value of function type
  - evaluate `e2 ... en`
  - do the call

### Special language features

Some language features are special. You will see in a moment. These look like
normal s-expressions, except that they have different semantics not
representable as a normal function call (i.e. require non-strict evaluation or
some unusual control flow). Also, the arity is checked at parse time and not
during evaluation.
* `(if e1 e2 e3)`: conditional expression works like you would expect. `e1` is
  the condition, `e2` is the true expression and `e3` is the false expression.
  `e1` may be a value of any type, not just `bool`. See the note on truthiness.
* `(raise e)`: evaluates `e` and raises it as an exception.
* `(try e1 e2)`: evaluates `e1` and returns its value. But if `e1` raises an
  exception, evaluate `e2` and return that value. Note that you raise a value
  (any value!) as an exception but you can't get it back for the catch.
* `(set x e)`: evaluates `e` and binds it to `x` (identifer) local variable.
  The value of the expression is whatever `e` evaluated to.
* `(defn ...)`: defines a function, see below


### Built-ins

Some functions are provided as built-ins. They are

* `typeof`: takes in a single value and returns its type
* `print`: takes in a single value and prints it. returns PoopCrap
* `+`: takes in two integers and adds them.

These are not literals but are instead variables defined in the environment.

### Defining your own functions.

Use `defn` to define your own functions:

```
(defn (f ()) 1)
```

```
(defn (f (x))
  x)
```

```
(defn (f (x y))
  (+ x y))
```

The name of the function (up there, `f`) is bound to a local variable.
Parameter names can (but should not) be dupliated.
