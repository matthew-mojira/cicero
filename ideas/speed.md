# Remaining performance gaps

There are a few performance gaps that we should explore.

## tier1 interpreter

The tier1 bytecode interpreter is slower than the tier0 AST interpreter. This
could be because of
* overheads in the bytecode compilation process (translating AST to bytecode)
* overheads in the bytecode frame evaluation
* (bad) evaluating the bytecode itself is slower
  - the loop itself should be pretty fast (faster than the call overheads that
    would happen at the AST-level)
  - there are extra checks built into the loop (flags, exceptions). Some are
    effectively final (set at the start of the program only but not static)
    which the Virgil compiler can't optimize the check for statically.

For the richards benchmark, the slowdown of tier1 is around 2%.

Overheads such as the need for a lot of stackframes in a deeply-nested AST
nodes are not a problem in evaluation for tier1, but are still absorbed as part
of the compilation process. Also, by translating to bytecode, there is room for 
a round of optimization (anything from a sophisticated optimization on a CFG to 
peephole optimizations after bytecode is generated).

## Type I-i embedding

The Type I-i embedding, where the cicero code is compiled to wasm (under the
wave target) as opposed to native, is much slower. This is a known defect in
dynamic language runtimes, but we should actually explore why this is the case.

Unfortunately right now, there seems to be more issues with the tier1 (bytecode)
interpreter for cicero on wasm. Wizard fails to run the richards benchmark.
That is a much bigger deal that precludes fixing this one. 

For tier0 on richards, the overhead is about 24x.
