# Cicero language features

## Types and values

* Int - backed by a Virgil integer
* Bool
* Func
* Str
* Type
* PoopCrap - this is the unit type, what is `null` or `None` in other languages.
  The literal form of PoopCrap is `()`.
* Frame - execution frames
* Expr - an abstraction over Virgil code and Cicero AST for function bodies
* Class - user-defined class
* Object - an instantiated version of a Class
* Method - a function bound to an object (as `self`)

Right now, there's no way (I think) to access or create frames or expressions
in the language.

### Truthiness

The truthiness of PoopCrap and `false` is False. Every other value is True.

## Syntax

Cicero uses s-expressions for its grammar to make life easy for the
implementers (not so much for the programmers).

### Identifiers

Identifiers may be any sequence of characters as long as:
* it does not contain whitespace, `'`, `"`, `(`, `)`, `[`, `]`, `{`, `}`, or `.`
* it does not have an integer literal as as a prefix (e.g. `1250xpdsr`) --
  although this is broken for very large literals, so don't try it
* it is not a literal (right now it is always parsed as a literal)

An identifier *may* be a keyword or literal. This probably causes weird
behavior so you probably shouldn't do it (and I should probably disallow it).

### Literals

The literals are:

* an integer encoded in base 10
* `()` as the PoopCrap literal

### Comments

No comments supported.

### Syntactic sugar

Some conveniences to reduce the amount of s-expressing:
* `{ e1 e2 ... en }` is sugar for `(begin e1 e2 ... en)`
* `e.f` is sugar for `(get-field f e)`. You can chain these: `e.f.g.h`

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
* `(func ...)`: defines a function, see below
* `(cond (e1 f1) ... (e2 f2))`: evaluate each condition `e1...en` in order
  until the first `ei` evaluates to true, then evaluate `fi` (which will be the
  value of the whole expression). Throws an exception if no cases match
* `(while e1 e2)`: while loop as you expect where `e1` is the condition and 
  `e2` is the body. The value of the expression is the value of `e1` during the
  last evaluation (not so helpful really, just one of two falsy values)
* `(begin e1 e2 ... en)`: evaluate all expressions in order (given that there's
  not some exception thrown). As a matter of syntax, the list of expressions
  must be nonempty
* `(get-field f e)`: accesses field `f` of the object evaluated in `e`
* `(set-field f e1 e2)`: sets field `f` of the object evaluated in `e1` to the
  value of `e2`. This value must already be bound to a value otherwise it
  raises an exception.
* `(class id f/m*)`: declares a new Class, see below
* `(new e)`: instantiate a new Object, given that `e` evaluates to a Class

### Built-ins

Some values are provided as built-ins. They are

* `typeof`: takes in a single value and returns its type
* `print`: takes in a single value and prints it. returns PoopCrap
* `+`: takes in two integers and adds them.
* `true` and `false`
* `int`, `bool`, `func`, `str`, `type`, `poopcrap`, `expr`, `frame` referring
  to those types (note that `func` is overloaded for the syntactic function
  declaration)
  

These are not literals but are instead variables defined in the global 
environment.

### Defining your own functions.

Use `func` to define your own functions:

```
(func (f) 1)
```

```
(func (f x)
  x)
```

```
(func (f x y)
  (+ x y))
```

The name of the function (up there, `f`) is bound to a local variable.
Parameter names can (but should not) be dupliated.

### Variable scope

Variables set at the top level have global scope (and can irreparably overwrite
built-ins!). Variables set in functions are always set locally, which may
shadow a global variable of the same name.

### Fields

All values are objects in that they have fields which can be accessed by
`get-field` and `set-field`. Except that, as stated above, you cannot set a
field that is not already bound to a value.

### Canonicalization

Values of type

* bool
* int
* poopcrap
* string
* type

have one unique instance for each underlying value. The underlying value is
immutable (i.e. you can't take the integer 1 and make it 2), but the fields
are mutable. This may make things strange if you mess with the fields.

## User-defined classes

You can define custom classes like this:

```
(class Counter
  (field value 0)
  (method (increment)
    (set-field value self (+ self.value 1))
  )
)
=> <class>
```

This evaluates to a Class value, which allows it to be instantiated with `new`

A class consists of
* a name: the resulting Class is bound to name as a local variable
* field and method declarations (they may be mixed)
  - a field consists of a name and an initial value
  - a method has the same syntax as a function declaration, except it also has
    a reference to an object in `self`. Note that there isn't an implicit
    lookup when you reference another field (i.e. you must access through
    `self`). Methods are also fields.

A method is a special kind of function which has a reference to the object in
`self`.

No static members of a class. No inheritance.

Create a new object using the `new` syntax:

```
(new Counter)
=> <object>
```

Access fields using `get-field` or the `.` sugar:

```
(set c (new Counter))
=> object
c.value
=> 0
```

Calling methods are like calling functions:

```
c.increment
=> <method>
(c.increment)
=> 1
c.value
=> 1
```
