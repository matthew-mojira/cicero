# Todo list

Benchmarking/unit tests
- [ ] test suite holes
  - [ ] redefining things in the base class, especially determining what is
        canoncalized
  - [ ] set-field

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
- [ ] figure out caching of BigInts
- [ ] find what objects/types can be unboxed boxed

CLI
- [ ] tracing, debugging enable flags
- [ ] use option groups (from Aeneas) and refactor
- [ ] pass command line arguments to program

Exceptions
- [~] allow reflection over stacktrace information (just returns list of lines
      as strings, not very useful)

Built-in classes
- [ ] add more operations to many classes

Maps
- [ ] add methods to the map class
- [ ] map literals and/or some way to create maps

Better bytecode
- [ ] reduce operands by one of the following: (1) operand length depends on
      bytecode, (2) use LEBs, (3) add `EXTENDED_ARG` bytecode
- [ ] create better DataWriter wrappers (e.g. combine `source.put`/`putb`/`putO`)
- [ ] canonicalize constants and name strings in the bytecode compiler

Better functions
- [X] closures (allowing recursion for a function not at the top level)
  - [X] ONE-pass nonlocal detection
- [ ] allow (mutation of) nonlocal variables
- [ ] optional arguments
- [ ] variadic functions
- [ ] keyword arguments
- [ ] coroutines: figure out what they are

Nicer parsing experience
- [ ] fix hang when parsing mismatched parentheses in method definition
- [ ] when input is stdin, keep reading on incomplete input
- [~] clarify between keywords, literals, and builtins
  - [ ] improve literal detection
- [X] do not allow duplicate parameter/field/methods names
- [X] do not allow self as a parameter in methods
- [-] do not require {} for blocks inside functions (and whiles too) -- CANCELLED
- [-] warn on redefinition? (runtime's responsibility?) -- CANCELLED

More types
- [ ] floating-point numbers
- [ ] set

Wasm
- [ ] GRP
  - [ ] GRP: use abstract interpreter to detect dispatch in switch
  - [ ] investigate why opcode counts are wrong for Cicero tier1 in GRP
- [ ] Tier II layering: compile bytecode to Wasm, link wizard, and execute

Potpourri of potentially bigger things
- [ ] anonymous classes
- [ ] Default values proposal
- [ ] Object constructors
- [ ] add an exit primitive
- [ ] do not allow `set` in the top level
- [ ] collect a set of design decisions, keeping track of dynamic language
      features we've added and what languages they model
- [ ] print should call field display, not internal Virgil object's 
- [ ] rename XObjects component (e.g. getIntObject -> fromLong)
- [ ] return, break, continue
- [ ] namespaces?
- [ ] rename PoopCrap to something more school-appropriate (and maybe Classhole too)

## nonlocal variables

The final plan for nonlocal variables:

A variable is nonlocal if it is not a local in the current scope but it is
local in the enclosing scope (note that if the enclosing scope is the top-level
all variables declared in that scope are global, so there can be no nonlocals).
We might find it useful in situations like this:

```
(func (add-n n)
  (lambda (x) (+ x n))) ; n is non-local captured from above scope
```

Nonlocal variables must be captured from the enclosing scope. The following
items are eligible for capture:
* `func`
* `lambda`
* in a class definition (maybe not preferable?)
  * `field`
  * `init`
  * `method`

Unlike Python, we will not allow the enclosing scope to modify a nonlocal
variable, that is, no `set-nonlocal` or anything like that.

**Right now, only func/lambda will allow nonlocal variables**

What has to be updated?

### AST

In the AST, `Func` and `Class` need to be updated to include the list of
variables that need to be captured. We must also add a `Nonlocal` access mode
to variable accesses.

### Parser

In the Parser, we must detect nonlocal accesses. This is tricky because a
naive single-pass approach will fail to detect local set later:

```
{ 
  (lambda (y) (+ x y)) ; x is parsed as a global access
  (set x 1) ; x now local!
}
```

The parser must also collect the set of nonlocal variables which need to be
captured.

### Objects

Function and class Objects (in Cicero) must now include a mapping of the
captured variables to the value that was captured. Note that built-in classes
and functions don't have any captured variables (yet?).

Classes need to be changed so that it doesn't use `FuncObjects` as holes for
methods.

### AST evaluator

The AST evaluator currently does a trivial restructuring from AST to
`FuncObject`. That will need to be augmented with a capturing process. Same
for constructing `ClassObject`s. Notably, this may now fail if the captured
variable has not yet been bound!

### Bytecode evaluator

This is going to be more complicated. Currently, functions are translated into
`FuncObject`s at compile time. Classes are translated into classholes. We will
need to do a similar thing in turning functions into funcholes.

We add a new opcode, `CREATE_FUNCTION`, that handles this. Its operand is an
index into a funchole table that determines how many locals to pop from the
stack to put as nonlocals in the function object. That also means we need to
either (1) load the bound variables on the stack or (2) use the information
in the funchole to determine how to grab the bound variables from the locals.

Something similar for upgrading classholes to handle bound variables too,
except that there are three places where bound variables can be used.

Also, we need a `LOAD_FREE_VAR` instruction for nonlocal reads.

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

## Short-circuiting boolean operators

`and` and `or` are usually short-circuiting, but right now they are not since
it is an operation on the boolean type only. We propose a new syntax feature
`and` and `or` which prescribe short-circuiting boolean operations on *all*
values, using the established truthiness rules.

`(and p q)`
* evaluate `p => v1`
* if `v1` is a falsy value, the entire expression is `v1`
* if `v1` is a truthy value, evaluate `p => v2`, the entire expression is `v2`

`(or p q)`
* evaluate `p => v1`
* if `v1` is a truth value, the entire expression is `v1`
* if `v1` is a falsy value, evaluate `p => v2`, the entire expression is `v2`

### How to compile to bytecode

`(and p q)`:
* evaluate `p`
* `JUMP_IF_FALSE_PEEK L1` -- reused from while loops
* evaluate `q`
`L1`:

`(or p q)`
* evaluate `p`
* `JUMP_IF_TRUE_PEEK L2` -- new opcode proposal
* evaluate `q`
`L1`:

### Sub-proposal: universal not

`(not x)`

evaluate `x => v`:
* if `v` is truthy: `false`
* if `v` is falsy: `true`

### Sub-proposal: custom truthiness definitions

Expose `is-true` as a method which is called on implicitly by the runtime (this
might be complicated) to allow user-defined classes to define their own methods
of determining truth.
