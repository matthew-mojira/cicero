# Cicero language features

## Values

All values are objects.

### Poopcrap

Poopcrap is the unit type (null, nil, None, ()). The literal is `()` and it is
a singleton object of class `poopcrap`.

### Built-in classes

* `base`: the parent class of all objects
  * `bool`
  * `class`
  * `code`
  * `exn`
  * `frame`
  * `func`
    * `method`
  * `int`
  * `list`
  * `map`
  * `poopcrap`
  * `str`

Learn more about their methods and what they mean [here](./classes.md).

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

`;` for single-line comments. No block comments supported.

### Syntactic sugar

Some conveniences to reduce the amount of s-expressing:
* `{ e1 e2 ... en }` is sugar for `(begin e1 e2 ... en)`
* `x.f` is sugar for `(get-field f x)`. You can chain these: `x.f.g.h`. Note
  that `x` must be an identifier (not some other expression)

## Evaluation

Here is how the easy things evaluate:

* The value of a literal is its value!
* The value of an identifier is a lookup in the environment. See the
  subsection on variable scope.
* To evaluate a function call `(f e1 e2 ... en)`:
  - evaluate `f`
  - assert `f` is a value of function type
  - evaluate `e2 ... en`
  - do the call
* Some language features are special. See [syntactic language features](./syntax.md) 
  for the list and how they evaluate.

### Built-ins

Some values are provided as variables in the global environment. They are

* `true` and `false`
* `base`, `bool`, `class`, `code`, `exn`, `frame`, `func`, `int`, `list`, `map`,
  `method`, `poopcrap`, `str` referring to those classes (note that `func` is 
  overloaded for the syntactic function declaration)

These are not literals but are instead variables defined in the global 
environment.

### Core

The VM loads a file `lib/core.co` at startup and evaluates it, binding some
extra utility functions in the global scope (which is like the built-ins above,
except it is defined as Cicero code).

It is not intended for the end user to modify this file.

The core utilities are:
* binary operator wrappers: `+`, `-`, `*`, `/`, `=`, `!=`, `<`, `<=`, `>`, `>=`
  which wrap around a more ugly method call. 
  ```
  ((get-field + 1) 2)
  ; can be written more familiarly as
  (+ 1 2)
  ```

### Variable scope

Variables set at the top level have global scope (and can irreparably overwrite
built-ins!). Variables set in functions are always set locally, which may
shadow a global variable of the same name. That means it is currently not
possible to modify a global variable in an expression not at the top level.

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
* a name: the resulting Class is bound to the name
* optionally, a superclass
* optionally, an initializer
* field and method declarations
  - a field consists of an identifier and an initial value
  - methods are bound to an object which can be accessed through `self`.
    Note that there isn't an implicit lookup when you reference another field 
    (i.e. you must access through `self`). Methods are also fields.

No static members of a class.

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
"doNotInstantiateThisClass", => 1
```
