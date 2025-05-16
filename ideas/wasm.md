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

Lit
* these should be immutable globals so that they can be initialized easily

VarGet



