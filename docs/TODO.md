# Todos

Final list:
[X] re-couple Objects and their underlying data, introducing *primitive fields*
    to represent immutable core information of the object (but accessible
    through methodsX
[ ] create exception class which holds stacktrace information
[X] decide on local vs. global scope
    [ ] do not allow `set` in the top level
[X] make locals of a Frame an array (maybe only needed for tier1). Ensure that
    semantics in tier0 and tier1 remain the same.
[X] make fields of an object stored in an Array where you must lookup in the
    class for the offset into the Array instead of all HashMap lookups
    [ ] create ICs for field lookups in the bytecode interpreter
    [ ] research how python does attribute accesses (what is `__getattr__`?)
[ ] built-in classes should override base class methods for `display` and
    others
[ ] allow map literals and/or creation of the map
[ ] add an exit primitive and make EOF in the repl end nicely
[X] make lazy allocation of methods unobservable
[ ] canonicalize constants and name strings in the bytecode compiler. Ensure
    that we are properly optimizing PC aligned accesses
[ ] collect a set of design decisions, keeping track of dynamic language
    features we've added and what languages they model

* don't cache overly large numbers
* variable-length bytecode?
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
  - potentially use an array instead of a map for value lookup (can be used for
    dynamci optimizations?)
  - built-in classes should override base class methods, instead of having base
    class methods implement those for it (for display)
  - Don't use a hashmap for fields!! (but an IC could optimize this--actually no)
* allow map to be created (maybe define built-in function for the time being)
* more methods for classes
* Ensure that internal objects do not have multiple Virgil objects? This is
  easiest when we remove the decoupling we already did...
* implement `ObjectOf<T>`
* CL args, better repl handling
* debug state stuff?
* local and global variables
  - should variables be declared before they are used?
  - should we separate set-local/global (like wasm!) SEE BELOW
* make the lazy allocation of methods unobservable (i.e. return lazy methods
  in `o.fields` and fix incorrect inheritance behavior)
* better tier1 bytecode
  - develop a method of dynamically tiering up tier0 -> tier1
  - tier0 -> tier1 compiler don't use DataWriter (or use it better)
  - canonicalize constants and strings
* understand tier1 bytecode
  - GRP (unable to detect interpreter loop!)
  - wizard engine profiling
  - cut down tier1 eval overhead
* parser
  - when input is stdin, keep reading on incomplete input
  - nicer parser error messages
  - first-class parser (make parser errors exceptions? would mean that loading
    process is a feature of the language)
  - clarify keywords, literals, and builtins
* limits: incorporate limits to settle potentially unbounded weird things
* arbitary length integers?
* multiple files, namespaces
* decimal/floating-point numbers?

## Scoping
There are two scopes:

* global scope
* local scope

The global scope is local to the first frame of execution. Each new frame
creates its own local scope. 

### nonlocal/free variables

Perhaps in the case of anonymous or (named)
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

Sets and gets are now split into local and global scopes (giving `local-get`,
`local-set`, `global-get`, and `global-set`, much like Wasm!). So if we write
a variable `x`, how do we know what it is?

By default, any access is global:
```
(func (f x)
  y) ; access to `y` is global
```
Unless:
1. the variable is already a parameter to the function
2. at *any* point in the function, there is a set.
```
(func (f x) {
  x ; local
  y ; global
  z ; local
  (set z 1) ; local
  z ; local
})
```
We now introduce two features, `global-get` and `global-set`, to get around
possible restrictions.
```
(func (f x) {
  x ; local
  y ; global
  z ; local
  (set z 1) ; local
  (global-get z) ; global
  (global-set z 2) ; global
  z ; local
})
```
Use of `global-get` is strictly necessary when a `set` turns a variable from
being global to being local. This is slightly simpler than the `global` feature
of Python.

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
Cicero object which wraps around the same underlying Virgil value. This value 
is not backed by the original value nor can modifying this new value modify the
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

The question is speed. Obviously this is slower in a trivial implementation,
but how much can dynamic optimizations cut down on this overhead?

## Should fields be a HashMap?

Right now, we do not allow fields to be added to a class (you may only set
fields which have already been set). The HashMap lookup is pretty inefficient
since it must run a hash function on every string access. It is much easier if
all the fields are stored in an array where each field has an allocated
location that is the same for every object of the same class. To find the index,
look into the class which stores fields/methods in order to find the index
into the fields.

We can use inline caches to reduce the lookup penalty.

This also means if we recombine built-in types the lookups aren't so bad either
since we can probably determine them statically.

If we decide that fields can be dynamically added to a class, we can include
a hashmap anyway and "tack on" the extra fields in this map (which I think
Python already does!).

```
Func:
  |--------------------|
  | class: class       |
  | display: method    |
  | =: method          |
  | !=: method         | <- removed fields since you need to get that from class
  |--------------------|
  | id: str            |
  | params: list[str]  |
  | code: code         |
  |--------------------|
```

instead of
```
def fv = FuncObject.!(obj);
def params = fv.func.params, code = fv.func.code;
```
it becomes
```
def params = obj.fields[5], code = obj.fields[6]; // 5 and 6 are predetermined lookups
```
but now you have to typecheck `params` and `code`

Some things (like `int` and `list`) still need to be backed by Virgil. And now
a lot more operations may fail! And it can be harder to optimize this stuff
(although JavaScript presents an example on how to do it). And it becomes a
bigger question of if allowing this mutability is even useful. It's funky and
cool, but also probably tedious to implement and unintuitive to the user. Hence
not worth it until this becomes less of a toy artifact and more of a language
used out in the wild (won't happen).

```
class Object {
    def fields: Array<Object>

    new(class: Class) {

    }
}
```

# Default values

We can reduce potential boilerplate code and possible exceptions by introducing
default values and allowing uninitialized variables.

Possible changes:
* if without else: only trigger evaluation if the true branch is taken (useful
  for when we care about imperative effects). () is the value if the condition
  evaluates to false
* no matching cond: if no case in a cond matches, instead of raising an
  exception, it evaluates to ()
* uninitialized fields: do not require an expression to initialize fields in a
  class. Those fields will be ()
* uninitialized variables: accessing a variable's value that has not already
  been set yields (). This is more controversial to add, because it is more
  likely that an uninitialized variable is read because of a misspelled
  initialized variable.
* false loop: the while loop returns the last value of the condition (either
  false or ()). It makes more sense to return the last value of the body, but
  if the condition is false during the first evaluation there is no value for
  the body. Instead, it could evaluate to ().
* empty begin: an empty begin could evaluate to ().
* incomplete function arguments: if fewer than the required number of arguments
  are provided to a function, the remaining arguments could be initialized to
  (). This seems like a bad idea
