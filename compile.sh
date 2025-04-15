v3c-wasm-wave -heap-size=1900M -O3 -symbols ~/virgil/lib/util/*.v3 src/*.v3 src/util/*.v3 $1
v3c-x86-64-linux -O3 -symbols ~/virgil/lib/util/*.v3 src/*.v3 src/util/*.v3 $1
