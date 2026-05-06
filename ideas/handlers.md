# Translating bytecode handlers to Wasm

With this approach we separate the logic for the bytecode handlers and
translate those to wasm (by making them available as an imported component).

## Existing engineering

Right now, the bytecode interpreter is a match inside a while, where each case
of the match corresponds to each instruction. The base of the while loop (before
the match) has extra logic inside it
* fetching instruction and advancing pc
* checking for exceptions (this is special to cicero afaik)
* extra tracing/profiling
* setting up the inline caches (but these aren't very useful anyway)

## Not an easy one-to-one translation

Cicero bytecode is unstructured, meaning it includes arbitrary jumps. Wasm on
the other hand uses structured control flow (proper blocks). This makes
translating things like jump instructions difficult. Furthermore, conditional
jump instructions have extra semantics to complete before the jump can be 
taken.

To translate control flow instructions, we need to do the following:
* extract logic from conditional jump instructions
* use the Beyond Relooper algorithm to create structured control flow

## Some instructions are simple

The basic idea is that we translate bytecode handlers into wasm by separating
them into functions and making Wasm code a chain of calls to these handlers.
But some instructions, like `NOP` and `POP` are simple, and don't require a
call out to an imported function (this may not be the case in CPython, because
the `POP` equivalent might need to change refcount). These can be translated
into the wasm instructions `nop` and `drop`, respectively, except that `drop`
will need to be repeated as much as the operand to `POP` (because the operand
specifies how many values to pop). But the operand is of course statically
known, so this is easy.

## Reified frames

One goal we've seen is to remove the need for the operand stack in the guest
runtime, and instead use the Wasm operand stack to accomplish the same thing.
However, this may be very difficult. In addition, we may need to put extra
things on the stack to set up calls to external functions.

An alternative is to use "reified frames" where the Cicero-side execution frame
is passed into the handlers, and the handlers operate on the operand stack in 
the frame.

In cpython, you are allowed to ask for the currently executing frame and because
cpython is the spec, the runtime is required to construct one. By moving logic
away from this frame, it is possible that we have an inaccurate frame (or, we
would have to painstakingly create the cpython frame, which may require us to
undo optimizations performed on the wasm side). In cicero, frames are objects
but there is no way to get any of those objects at runtime (but you should, so
that we need to deal with this problem).

## Exception handling

Exception handling is difficult because many instructions can throw exception
which would otherwise require the early return. One way to do this is to return
an additional value from the handler indicating whether or not there has been
an exception (in that case a handler could return two values, an object and
an indicator of if that object is the proper value or an exceptional value).

Or, we could use wasm-gc which has `exnref`, and would also make try-catch
a simple translation as well.

## Fast calls for bytecode handlers

In the Wizard fast interpreter, replace the call opcode with a special fast
call to specially compiled bytecode handler functions. We compile the bytecode
handlers (from wasm, using spc) so that they respect the fast interpreter's
register usage so that we don't need to create a frame. The call to the handler
function is really a jump and the end of the bytecode handler is a (wasm)
dispatch to the next instruction.

Again, we're trying to deconstruct the operand stack and locals from cicero
to wasm. That means some instructions (like `LOAD_LOCAL`) can't really be made
into handlers since it would effectively be in a different wasm frame (though
implementation-wise it's murkier).

### Easy exceptions from handlers

Handlers return a pair. The first element is either the return value or the
exception value, indicated by the second element of the pair.

What about try-catch blocks? How about wasm-gc exceptions?

### The functions

The wasm implementation for cicero will be "one big fat module". The cicero
runtime will dynamically create new wasm functions in the cicero module
instance. 

Technically the code object is the thing that gets compiled, which is wrapped
either as part of a class definition or a function (or a method). So we don't
really know the arity?

### Handlers

#### `NOP`

`NOP` does not need to be translated, since it does nothing. But maybe as a
test for our fast calls we could give it a dummy function

```
def handle_NOP() -> void {

}
```

#### `LOAD_CONST`

Constants are presently available in the bytecode and are indexed by the
operand. However, in constructing the wasm we can simply get the pointer for
the constant and use `i32.const` (or `i64.const` if we use 64-bit pointers):

```
i32.const #ptr
```

#### `LOAD_GLOBAL`

See below.

```virgil
def handle_LOAD_GLOBAL(name: string) -> (Object, int) {
    if (globals.has(name)) {
        return (globals[name], 0);
    } else {
        /* throw and return exception */
    }
}
```

```wasm
i32.const #str
call $handle_LOAD_GLOBAL
```

#### `LOAD_LOCAL`

This needs to be translated as a both a handler function and inline
instructions. The inline instructions handle the actual load of the value from
the wasm locals, but then we need a special handler to check uninitialized
locals.

```
local.get #operand
i32.const #operand
call $handle_LOAD_LOCAL
;; check for exception
if
    ;; do exn stuff
end
;; if no exn, should be here with result local value on stack
```

Note that the handler function needs the local number (for creating the
exception) and the value at top of stack (which is a peek assuming it is not
null):

```
def handle_LOAD_LOCAL(local: Object, operand: int) -> (Object, int) {
    if (local == null) {
        /* create exception object and return */
    }
    return (local, 0);
}
```

#### `LOAD_FIELD`

Lookups on field are by name (and we don't yet have efficient inline caches to
lookup by index). The operand to the instruction is the index in the string
pool to get the name. The handler needs to receive this string somehow? 

If the call is out to an imported handler function, then one idea is to pass in
a pointer to a virgil string for the name. If it's in the same module then we
could also give it an index intoto wasm memory where the string is stored.

```virgil
def handle_LOAD_FIELD(obj: Object, name: string) -> (Object, int) {
    def ret = obj.getField(name);
    if (ret == null) {
        /* throw exception for missing field */
    }
    return (ret, 0);
}
```

```wasm
;; stack already has object
i32.const #str ;; pregenerated pointer
call $handle_LOAD_FIELD
if
    ;; check for exception
end
```

#### `STORE_GLOBAL`

```virgil
def handle_STORE_GLOBAL(val: Object, name: string) -> void {
    globals[val] = name;
}
```

```wasm
;; value on stack
i32.load #str
call $handle_STORE_GLOBAL
```

#### `STORE_LOCAL`

Unlike `LOAD_LOCAL`, this cannot throw exception, so we're okay here with a
simple (non-handler) translation.

```
local.set #operand
```

#### `STORE_FIELD`

Store field works like load field. However, the handler only needs to return a
bool because the values are consumed (the real semantics corresponding to the
`StoreField` AST note require that the assigned value be the value of the
operation, but the bytecode compiler accomplishes this as extra instructions
beyond `STORE_FIELD`).

```virgil
def handle_STORE_FIELD(obj: Object, val: Object, name: string) -> bool {
    return (obj.setField(name, val));
}
```

```wasm
;; stack already has:
;; value
;; object
;; alue
i32.const #str ;; pregenerated pointer
call $handle_STORE_FIELD
if
    ;; check for exception
end
```

#### `CALL`

Calls need to set up a new stack frame. However, I don't think we are going to
have stack frames anymore (at least, we are going to have a wasm stack frame
in cicero which will be different than the bytecode frame).

Calls are multi-arity, where the operand indicates how many values will be
pulled off the stack for arguments. An additional value, the function, is
pulled off the stack (thanks to `ASSERT_FUNC` which always appears before,
this is a callable function).

Note that the function might be a method, in which an additional object needs 
to be bound as the first local called `self`.

How do we set up functions?

An arity check has to occur. An mismatched arity (between the number of values
pulled from the stack and the function's desired arity) is an exception.

If the function returns in an exceptional state, then we have to rethrow that
exception.

#### `JUMP`

Eliminated by translating from control flow first.

#### `JUMP_IF_FALSE`

Eliminated by translating from control flow first.

#### `JUMP_IF_TRUE_PEEK`

Eliminated by translating from control flow first.

#### `JUMP_IF_FALSE_PEEK`

Eliminated by translating from control flow first.

#### `RAISE`

I think we will want to use wasm exception handling for this.

#### `TRY`

I think we will want to use wasm exception handling for this.

#### `CATCH`

I think we will want to use wasm exception handling for this.

#### `ASSERT_FUNC`

```cicero
def handle_ASSERT_FUNC(obj: Object) -> (Object, int) {
    if (!obj.instanceOf(ClassObjects.classFunc)) {
        /* create exception object and return */
    }
    return (obj, 0);
}
```

```wasm
call $handle_ASSERT_FUNC
if
    ;; exception
end
```

#### `CREATE_OBJECT`

Object creation requires a handler that consumes a class object at the top
of the stack, and returns a new object. It will need to set up new stack
frames to for the class initializer and field initializers.

#### `CREATE_CLASS`

Class creation consumes a object which must be a class for the superclass.
What about the classhole? How does the runtime know about those? Again we
could just give it a special pointer to the `ClassObject -> ClassObject`
classhole function.

#### `CREATE_LIST`

This instruction takes a variable number of values from the stack depending on
the operand. For the handler, we could separate these into different versions
for every size that we see during compilation:

```cicero
def handle_CREATE_LIST_0() -> Object { /* return type indicates no exception */
    return ListObjects.fromArray([]);
}
def handle_CREATE_LIST_1(obj1: Object) -> Object {
    return ListObjects.fromArray([obj1]);
}
def handle_CREATE_LIST_N(obj1: Object, obj2: Object, ..., objN: Object) -> Object {
    return ListObjects.fromArray([obj1, obj2, ..., objN]);
}
```

#### `CREATE_FUNC`

The handler here is complex since it needs to grab the locals which will be
captured as nonlocals. However, the bytecode compiler already compiles a 
sequence of `LOAD_LOCALS` corresponding to the nonlocals that will be captured
(with a common order that the handler can use to pull values correctly).

So again we can create a set of handlers depending on how many values need to
be pulled. However, the confusing part here is that when a function captures
itself (for recursion). That is considered a nonlocal, but the value is not
pushed to the stack (since it's not effectively bound yet). When going over
the funchole we have to skip the name that matches the name of the function and
insert our lazily-defined function for that.

How to get the funchole?

#### `POP`

Compile `POP n` as `n` `drop` instructions in wasm. Since cicero uses the
virgil GC and not refcount, there is no extra operations needed to complete
this.

For example, compile

```
POP 3
```

as

```
drop
drop
drop
```

#### `DUPE`

Right now, the bytecode compiler only generates `DUPE 0` and `DUPE 1`
instructions. Again we generate multiple handlers based on the operand, which
peek and return multiple values based on how many were read.

```
/* Duplicate the top element on the stack */
def handle_DUPE_0(obj: Object) -> (Object, Object) {
    return (obj, obj);
}
/* Duplicate element below the top element on the stack */
def handle_DUPE_1(obj0: Object, obj1: Object) -> (Object, Object, Object) {
    return (obj0, obj1, obj0);
}
```

#### `SWAP`

The only `SWAP` instruction the compiler generates is `SWAP 1` which swaps the
top two elements of the stack.

```
/* Swap top two elements of the stack */
def handle_SWAP_1(obj0: Object, obj1: Object) -> (Object, Object) {
    return (obj1, obj0);
}
```

### Avoiding beyond relooper

To avoid the need for beyond relooper, we will translate from the AST but use
the bytecodes as intermediaries. So we'll translate strictly the control flow
parts into wasm's control flow then translate the subparts using the regular
bytecode compiler that won't generate any control flow instructions.

So how do we translate the control flow?

#### `And`

`And` is a short-circuiting control flow, so the circuiting is control flow.
We'll also need a truthiness handler which peeks the stack:

```
func is_true_peek(obj: Object) -> (Object, bool) {
    return (obj, obj.isTrue());
}
```

So the wasm will look like this

```
; compile left
call $is_true_peek
if (param i32) (result i32)
    ; true, so the value is the other
    drop
    ; compile right
else
    ; false, the value is that false value
end
```

#### `Or`

Similar to `And`, except swap the cases:

```
; compile left
call $is_true_peek
if (param i32) (result i32)
    ; true, so this is the value
else
    ; false, the value is the right value
    drop
    ; compile right
end
```

#### `If`

Here, we're consuming the value to determine truthienss so no need to peek.

```cicero
func is_true(obj: Object) -> bool {
    return obj.isTrue();
}
```

```wasm
; compile cond
call $is_true
if (result i32)
    ; compile true
else
    ; compile false
end
```

#### `Cond`

`Cond` is the generalized form of `If` and so we'll translate it as a sequence
of `if-else` in wasm. However, if there is no matching case, it is an
exception.

```wasm
; compile cond1
call $is_true
if (result i32)
    ; compile body1
else
    ; compile cond2
    call $is_true
    if (result i32)
        ; compile body2
    else
        ; ...
        ; compile condN
        call $is_true
        if (result i32)
            ; compile bodyN
        else
            ; THROW EXCEPTION (use the generated code from bytecode compiler
            ; to fill this in)
        end
    end
end
```

#### `Catch`

This will depend if we use the wasm exception handling proposal.

#### `While`

```wasm
loop (result i32)
    block (result i32)
        ; compile cond
        call $is_false_peek
        br_if 1

        ; compile body
    end
    br 0
end
```

### Globals

So we decided to use "one big fat module" for cicero. The cicero runtime,
including the bytecode handlers, are packaged into one module. The runtime
generates new wasm code when it compiles a user's function from cicero
bytecode (just data with respect to the wasm engine) to wasm bytecode. This
means that wasm globals are globals to both the runtime and to the user
functions (that were compiled to wasm).

So that we can use wasm globals as cicero globals, we need a way of
dynamically adding globals to the wasm module instance. This functionality is
not currently present in wizard, but we (me) could add it.

But wait! Globals are stored by name, so can we index it?

#### So maybe not wasm globals

This is okay though, because then the handlers become lookups on the string.
Since we are using one big fat module, the bytecode handler looks up in the
same space for global variables no matter what frame or function calls it.

```virgil
def handle_LOAD_GLOBAL(name: string) -> (Object, int) {
    if (globals.has(name)) {
        return (globals[name], 0);
    } else {
        /* throw and return exception */
    }
}
```

```virgil
def handle_STORE_GLOBAL(val: Object, name: string) -> void {
    globals[val] = name;
}
```

## One big fat module

Our idea is that the entire cicero runtime (including bytecode handlers) will
be compiled as one wasm module. The runtime accepts text input and creates
user (cicero) code, which is data with respect to wasm. For efficiency
(hopefully), we compile user code to wasm as a new function which is
dynamically added to the module instance.

Wizard supports dynamically adding new functions to a module instance, but I
am not so sure this is a standard feature or that other engines support that.

## Garbage collection

The virgil runtime uses a semispace copying collector. This means that the
pointers for an object will move after a garbage collection. How does this work
with virgil code compiled to wasm? I am worried that for compiling
`LOAD_CONST` where the immediate is the pointer, the pointer value may not be
valid if a garbage collection occurs.

Big problem!
