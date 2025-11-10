| Command | Mean [s] |
|:---|---:|
| `wizeng --mode=int  bin/cicero.wasm -tier=0 -suppress-output examples/richards.co` | 3.308 |
| `wizeng --mode=int  bin/cicero.wasm -tier=1 -suppress-output examples/richards.co` | 4.017 |
| `wizeng --mode=int  bin/cicero.wasm -tier=2 -suppress-output examples/richards.co` | 2.448 |
| `wizeng --mode=jit  bin/cicero.wasm -tier=0 -suppress-output examples/richards.co` | 0.490 |
| `wizeng --mode=jit  bin/cicero.wasm -tier=1 -suppress-output examples/richards.co` | 0.470 |
| `wizeng --mode=jit  bin/cicero.wasm -tier=2 -suppress-output examples/richards.co` | 0.313 |
| `wizeng --mode=lazy bin/cicero.wasm -tier=0 -suppress-output examples/richards.co` | 0.474 |
| `wizeng --mode=lazy bin/cicero.wasm -tier=1 -suppress-output examples/richards.co` | 0.462 |
| `wizeng --mode=lazy bin/cicero.wasm -tier=2 -suppress-output examples/richards.co` | 0.290 |
| `wizeng --mode=dyn  bin/cicero.wasm -tier=0 -suppress-output examples/richards.co` | 0.473 |
| `wizeng --mode=dyn  bin/cicero.wasm -tier=1 -suppress-output examples/richards.co` | 0.455 |
| `wizeng --mode=dyn  bin/cicero.wasm -tier=2 -suppress-output examples/richards.co` | 0.291 |

| Tier | `int` | `jit` | `lazy` | `dyn` |
|:---|---:|---:|---:|---:|
| 0 (AST)      | 3.308 | 0.470 | 0.474 | 0.473 |
| 1 (Bytecode) | 4.017 | 0.313 | 0.462 | 0.455 |
| 2 (Wasm)     | 2.448 | 0.474 | 0.290 | 0.291 |
