# Todo list

Benchmarking/unit tests
- [ ] add many example programs, unit tests (and expected outputs)
  - [X] matrix
  - [X] list sorting algorithms
  - [ ] hot-swapping a function at runtime
  - [ ] duck typine test
  - [~] higher-order functions (map, fold)
  - [ ] prime sieve
  - [X] Richards
  - [ ] DeltaBlue
  - [ ] Other virgil benchmarks?
- [ ] add benchmark programs (each program should stress test a different
      component and capture a potential bottleneck in the system)
- [ ] run benchmarks

Optimizations in the tier1 bytecode
- [ ] determine what optimizations are available
- [ ] create ICs for field lookups
- [ ] research how python does attribute accesses (what is `__getattr__`?)
- [ ] peephole optimizations in the bytecode. For example:
      ```
      STORE_LOCAL 1
      LOAD_LOCAL  1 \ these are redundant and can be removed
      POP         1 / (store above must be = to ensure that variable is bound)
      ```

Optimize memory usage
- [X] don't cache overly large numbers (command line option)
- [ ] find what objects/types can be unboxed boxed

CLI
- [X] use `Option.v3` and parse them
- [X] help message
- [X] allow multiple files to be evaluated (simply evaluate them in order)
- [X] allow configuring between tiers
- [ ] tracing, debugging enable flags
- [ ] use option groups (from Aeneas) and refactor
- [ ] pass command line arguments to program

Exceptions
- [X] fix extra `<Virgil func>` appearing at top of stacktrace
- [X] include function names in the stacktrace
- [X] the stacktrace is reversed?
- [X] column numbers in stacktrace is incorrect (matches rows)
- [X] maybe add better information about exceptions in Virgil functions? (name got added)
- [X] fix tier0 vs. tier1 stacktrace inconsistency (=> better bytecode writer!!)
- [X] intern exception strings
- [~] allow reflection over stacktrace information (just returns list of lines
      as strings, not very useful)

Built-in classes
- [X] override base class methods for `display` and others
- [ ] allow mixed virgil and cicero code in methods
- [ ] add more operations to many classes
- [ ] element-wise comparison of lists (might require virgil frames to create
      more frames!)--at least there is an example program for now

Maps
- [ ] add methods to the map class
- [ ] map literals and/or some way to create maps

Better bytecode
- [ ] reduce operands by one of the following: (1) operand length depends on
      bytecode, (2) use LEBs, (3) add `EXTENDED_ARG` bytecode
- [ ] if still using fixed-width instructions, use word-addressed PC to remove
      redundant alignment bits
- [ ] error when compilation is not possible (e.g. when the required operand
      exceeds size)
- [ ] create better DataWriter wrappers (e.g. combine `source.put`/`putb`/`putO`)
- [ ] canonicalize constants and name strings in the bytecode compiler

Better functions
- [X] anonymous functions
- [ ] closures (allowing recursion for a function not at the top level)
- [ ] allow (mutation of) nonlocal variables
- [ ] optional arguments
- [ ] variadic functions
- [ ] keyword arguments
- [ ] coroutines: figure out what they are

Nicer parsing experience
- [ ] fix hang when parsing mismatched parentheses in method definition
- [ ] print out relevant line when a parse error occurs
- [ ] when input is stdin, keep reading on incomplete input
- [ ] clarify between keywords, literals, and builtins
- [ ] do not allow duplicate parameter/field/methods names
- [ ] do not allow self as a parameter in methods
- [ ] do not require {} for blocks inside functions (and whiles too)
- [ ] warn on redefinition? (runtime's responsibility?)

More types
- [ ] floating-point numbers
- [ ] set

Wasm
- [X] Compile VM to Wasm
- [ ] Analyze compiled Wasm with GRP (update GRP)
- [ ] compile bytecode to Wasm, link wizard, and execute

Potpourri of potentially bigger things
- [X] Makefile/build system
- [ ] Default values proposal
- [ ] Object constructors
- [ ] add an exit primitive
- [ ] do not allow `set` in the top level
- [ ] collect a set of design decisions, keeping track of dynamic language
      features we've added and what languages they model
- [ ] print should call field display, not internal Virgil object's 
- [ ] rename XObjects component (e.g. getIntObject -> fromLong)
- [ ] return, break, continue
- [ ] short-circuiting boolean operators (not methods of bool class)
- [ ] namespaces?

## Scoping

There are two scopes:

* global scope
* local scope

The global scope is local to the first frame of execution. Each new frame
creates its own local scope. 

### Scope within a function

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

### Closures

Function expressions are not closures. We should probably capture the
environment, and use something similar to `nonlocal` in Python to allow
mutation of the free variables. The tricky part is that a function may outlive
the outer scope of the variables it has access to.

Also, if there are two functions which use the same free variable, and we
mutate from one, does that affect the other?
```
(func (f x)
  (set p 1)
  (func (g x)
    p) ; nonlocal access
  (func (h y)
    (nonlocal-set p)) ; does this set `p` in `g`?
)
```


## to decouple or not to decouple?

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

### Should fields be a HashMap?

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

## Default values

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
