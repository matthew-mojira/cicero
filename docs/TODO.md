# Todos

* read "Crafting Interpreters"
  - better understand prototype-based objects, even though we are and probably
    will stick to class-based objects
* functions  
  - anonymous functions (closure?)
  - figure out how nested functions should be handled (closures, special
    scoping?)
  - recursive functions (this might work already? but you must know one way or
    the other!)
  - coroutines (for loop)
  - optional, variadic, and keyword arguments
* frames
  - stacktraces (catch values! built-in exception classes?)
  - return
* classes
  - define initialization semantics, especially when inheritance is involved
  - make fields and methods out of its internal components of class and expose
    to user (but how might this work when a user can change the internal
    properties of a class?)
  - inheritance (would allow general things like Callables and Exceptions) and
    superclass references. right now, inheritance can be done internally (not
    specifiable in user classes) and you can't access super things
  - (?) allow methods to be added dynamically to a class ([Section 12.5](https://craftinginterpreters.com/classes.html#methods-on-classes)) perhaps by allowing them
    to be created arbitarily
  - should lookups be helped by the class? isn't that the whole point of class-
    based objects?
  - casting? (not necessary because of duck typing?)
  - document your final decisions about class semantics!
  - idea: anything that's not necessary to back up the internal structure of an
    object (i.e. the `int` field of IntObject) should be a field and everything
    should access this field (allowing the user to change things)
  - init syntax, better constructors
* tier1: bytecode
  - generalize frame evaluator

## Scoping
Right now, there are two scopes that matter:

* global scope
* local scope

The global scope is local to the first frame of execution. Each new frame
creates its own local scope. But perhaps in the case of anonymous or (named)
nested functions you might want the higher scope to be accessed:

```
(func (f x) {
    (func (g y) {
        ; I want to access `x` here, but can't!
    })
})
```

Python allows non-local access using `local` which also permits mutation of
those variables. 

Anonymous functions may be closures which grant access to bound variables as
part of the closure's environment, but for simplicity's sake (especially when
the closure outlives the free variables it binds), it saves an immutable copy
at the time the closure is created.

### Scope within a function

Read [Chapter 11: Resolving and Binding](https://craftinginterpreters.com/resolving-and-binding.html)
more closely!

There is only one scope for a function. Sub-clauses may assign variables
accessible outside the lexical scope of the clause, leading to situations where
you may reference a variable without it being assigned:

```
(func (f x) {
    (if (= x 0)
        (set y x)
        () ; PoopCrap
    )
    y  ; not defined if x != 0
})
```

How does Python do this with code objects, since it identifies all local
variables which are referenced in a function, but still disallows variables
to be read before it is assigned?

### Mutability

We could require variables to be declared. I think I want to do this. We can
add a language feature for declaring variables (also forcing it to have an
initializer) and also specifying mutability:

```
(const x 10)
(var y (+ x 1))
```

This also means we could check references to undefined variables at parse time.

## Initializing classes

Right now you use `(new Class)` to create a class. This also initializes it,
since all fields have initializers attached to them and all methods (also a
field) have definitions.

So if you wanted to customize what those initial values are (say, parameterize
them), then you would need a function (outside the class!) that initializes
it:

```
(class Counter
  (field count 0)
  (method (increment) (set-field count (+ self.count 1)))
  (method (reset) (set-field count 0)))

(func (new-counter init) {
  (set c (new Counter))
  (set-field count c init)
  c
})
```



But that may complicate things if you want immutable fields and to change what
that initial (final) value is based on multiple initializers.
