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
