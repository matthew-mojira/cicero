v3c-wasm-wave -output=bin -program-name=cicero -heap-size=1900M -O3 -symbols ~/virgil/lib/util/*.v3 src/*.v3 src/eval/*.v3 src/util/*.v3
v3c-x86-64-linux -output=bin -program-name=cicero -O0 -symbols ~/virgil/lib/util/*.v3 src/*.v3 src/eval/*.v3 src/util/*.v3
v3c-x86-64-linux -output=bin -program-name=cicero3 -O3 -symbols ~/virgil/lib/util/*.v3 src/*.v3 src/eval/*.v3 src/util/*.v3
