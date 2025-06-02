# Translating AST to Wasm

A code object contains an expression. In tier0 it is the AST, in tier1 it is
Cicero bytecode. Tier2 shall be Wasm.

In the tier1 compilation we added a parameter where you pass a list of strings
as Cicero parameters. These are so that they can be the first set of locals and
indexed. This is sorta weird and you can lie, because the true parameter
information, including arity checking, is included as part of the object that
wraps around the CodeObject (e.g. FuncObject). But we can reuse this for tier2.

Let's say that each CodeObject shall translate to a Wasm module which
includes one function with all these parameter stuff.

## Translation by AST 

This document outlines how to translate the cicero AST to wasm (for use in a
Type II-c embedding). A Type II-ic embedding would use a conversion from
Cicero's bytecode to Wasm bytecode, and might entail different things (such as
the need for beyond relooper to structure the control flow that has been
unstructured)

This is a basicish conversion where a lot (but not all) of the possible logic
is deferred to the runtime system in imported functions which basically handle
all the logic. We can lower further if we use Wasm GC to make Cicero objects
into Wasm objects, but how much engineering is required to do that? Is this a
reimplementation of the language? Can it be automatically generated from the
source code? (thinking about structs in CPython, which are complicated but 
could programmatically generate the Wasm GC structs types from)

### Lit
* these should be immutable globals so that they can be initialized easily (the
  runtime system must provide the pointer to this value--problem: Virgil uses a
  semispace copying collector, so this pointer might move!)
* translate as `global.get` and the operand is the value in the constant pool

### VarGet
* local:
  * `local.get N`
  * NOTE: if local is not initialized (i.e. wasm value is 0) -- throw exn/TRAP
* global:
  * Maybe these shouldn't be the same as wasm globals, since they exist from
    function to function. Instead this should be implemented as a call to an
    imported function from the RTS that does this (what value does it give?)
* nonlocal:
  * nonlocals are provided as part of the `nonlocalArgs`, so these can be 
    initialized as either locals or (immutable) globals

### VarSet
* local:
  * `local.set N`
* global:
  * import call?
* nonlocal:
  * not a valid case

### And
* short-circuiting and requires special logic
* to translate `(and e1 e2)`:

```
(func $is_true (import "cicero" "is_true") (param i64) (result i64 i64))
;; is_true takes an object and returns that object and a truthiness value (0/1)
```

```
<evaluate e1>
call $is_true
if (param i64) (result i64)
  drop
  <evaluate e2>
else
;; v1
end
```

### Or
* similar to and

```
(func $is_true (import "cicero" "is_true") (param i64) (result i64 i64))
;; is_true takes an object and returns that object and a truthiness value (0/1)
```

```
<evaluate e1>
call $is_true
if (param i64) (result i64)
;; v1
else
  drop
  <evaluate e2>
end
```

### Apply

* apply semantics:
  * evaluate the first argument, and assert that it is a function
  * requires arity checking of the input arguments versus the function that
    is being called
  * also requires passing bound object in the case of a method
* this seems complicated, and the complexity (who has to be complex) depends on
  whether or not we use the Wasm GC proposal and if we're removing the
  abstractions and doing call checks in Wasm

* Suppose we want to avoid any and all Wasm lowering at this stage. What we have
  are a bunch of expressions which need to be evaluated
  * First, we evaluate the target (function) and then assert that this is a function:
    ```
    <evaluate tgt>
    call $assert_func
    if
      ;; okay
    else
      ;; bad = TRAP
      unreachable
    end
    ```
  * Next, we must evaluate each target expression, leaving one value on the 
    stack for each argument
  * So we have a bunch of values and an additional one for the function (note:
    we know how many we have in total). Who's doing the arity checking and
    subsequent call? What if this call is to a method?
    * RTS needs to know arity in a call to an imported function. We could generate
      different copies of RTS calls based on the arity (also flattens arity check
      from RTS side)
    * could trap if wrong
    * return type is always i64 since there is no multiple return in Cicero
    * still: who is doing the bound object in a method call?

So an example could look like

```
(func $call3 (import "cicero" "call3") (param i64 i64 i64 i64) (result i64))
(func $assert_func (import "cicero" "assert_func") (param i64) (result i64 i32))

func ;;...
  <eval tgt>
  call $assert_func
  if
    ;; good
  else
    ;; bad = TRAP
    unreachable
  end
  <eval arg0>
  <eval arg1>
  <eval arg2>
  call $call3 ;; wasm call = function application... perhaps one level of indirection too many
end
```

### If

* A wasm if using an extra truthiness call

```
<eval cond>
call $is_true ;; unlike previous $is_true, consume stack and return truthiness value
if (result i64)
  <eval true>
else
  <eval false>
end
```

### Cond

```
block (result i64)
  ;; first case
  block (result i64)
    <eval cond1>
    call $is_false ;; consume value
    br_if 0
    <eval case1>
    br_if 1  ;; does it return the evaluated value above?
  end
  drop
  ;; second case
  block (result i64)
    ;; ...
  end
  drop
  ;; no matching cond = TRAP
  unreachable
end
```

### Raise

How are we doing exceptions?
* wasm GC extension
* special value
* two-value return (like go)
* trap only?

### Try-catch

Resolve issue above

### Func

Get the necessary captured variables on the stack (`local.get`--check initialization!)
and the index of the funchole (`i32.const`) and then make a call to the RTS
(`call $make_funcN`) to get the value

### While

Use `loop`

```
block (result i64)
  loop (result i64)
    <eval cond>
    call $is_false ;; peek original value, because we need it for return
    br_if 1 ;; consume one value from $is_false return, return the other?
    <eval body>
    drop ;; need this?
    br 0
  end
end
```

### Begin

Evaluate each expression separately and drop the intermediate ones.

### Get-field

* implementation provided by the RTS
* how to pass in the string? constant index into the stringholes? dynamically
  generate handler functions for each possible string?
* exception?

### Set-field

* same as above

### Class

* evaluate the superclass expression
* who will assert that this value is a class? explicit in Wasm or RTS below?
* call to the RTS to make the class

### New

* who will do the type assertion? explicit in Wasm or call to RTS?
* call to RTS to return i64 for object

### List

* another case of variadic input types, which could be done by generating
  `make_listN` for each `N` list size encountered in the code (but what if there
  are too many?)
