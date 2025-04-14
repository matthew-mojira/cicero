# Todos

* functions  
  - anonymous functions (closure?)
  - figure out how nested functions should be handled (closures, special
    scoping?)
  - recursive functions: at the top level, a function declaration is added to
    the global scope, so a function can see itself. if it is a method, it can
    access itself through `self`. but if it is a nested function, it cannot
    see itself (perhaps this should be enabled, see above)
  - coroutines (for loop)
  - optional, variadic, and keyword arguments
* frames and exceptions
  - exception class, and standardize exception names around built-ins
  - better stacktraces (include file name, methods around exn object to query
    location info)
  - return
* classes
  - initialization syntax for user-defined classes
  - extends syntax for inheritance in user-defined classes
  - document your final decisions about class semantics!
  - potentially use an array instead of a map for value lookup (can be used for
    dynamci optimizations?)
  - built-in classes should override base class methods, instead of having base
    class methods implement those for it (for display)
* tier1: bytecode
* allow map to be created (maybe define built-in function for the time being)
* list literals
* more methods for classes
* Ensure that internal objects do not have multiple Virgil objects? This is
  easiest when we remove the decoupling we already did...
* implement `ObjectOf<T>`
* CL args, better repl handling
* debug state stuff?
* global variables
* make the lazy allocation of methods unobservable (i.e. return lazy methods
  in `o.fields` and fix incorrect inheritance behavior)

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

Python allows non-local access using `nonlocal` which also permits mutation of
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

# to decouple or not to decouple?

Objects of built-in classes need Virgil-internal data in some cases. For
example, a boolean requires a Virgil boolean to indicate the actual value.
(This is actually not strictly true, because we canonicalize instances of
booleans, so that a pointer comparison between an object and the designated
canonical instance is sufficient. But this is not so scalable to other classes,
such as integers and strings where storing the Virgil-value directly in the
object is much more time-efficient.)

Some objects wrap around Virgil objects which could themselves be Cicero
objects. For example, a Cicero function object wraps around a function, which
wraps around a string (its name), a list of strings (its parameters), and code
(its body). These are accessible through the Cicero function object's methods
(`f_name`, `f_params`, and `f_body`, respectively). Since all fields in Cicero
are mutable, we can change these. But these are getter methods, not the actual
underlying values. In addition, each call to this method generates a new
Cicero object which wraps around an underlying Virgil value. This value is not
backed by the original value nor can modifying this new value modify the
internal one. `f_params` returns a list, which if modified, doesn't change the
original function.

Perhaps for the sake of a dynamic language this behavior should be allowed? At
present, a function object is represented as

```
class Func(id: string, params: Array<string>, code: Code) {}
class FuncObject(func: Func) extends Object {}
```

One proposal to remove this ugly `XXXObject` is to do as follows:

```
class Object {}
class ObjectOf<T> extends Object {}

def func: ObjectOf<Func>;
// or
def func: ObjectOf<(string, Array<string>, Code)>;
```

Another possibility is to integrate the components of a function as fields of
the object. When creating a new function, something like this occurs:

```
def func = Object.new(Class.func);
func.fields["name"] = StrObject.of(id);
func.fields["params"] = ListObject.of(params);
func.fields["code"] = CodeObject.of(code);
```

When a function is evaluated, the frame accesses the Cicero fields, which are 
now exposed to the user and mutable. This means the user can mess with them, in
a way which is more often than not confusing and unintuitive. But it's more
dynamic!


