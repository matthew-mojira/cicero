all: x86-linux x86-64-linux jvm wasm-wave

.PHONY: clean x86-linux x86-64-linux jvm wasm-wave
clean:
	rm -f TAGS bin/*
	cp scripts/* bin/

x86-linux: bin/cicero.x86-linux

x86-64-linux: bin/cicero.x86-64-linux

jvm: bin/cicero.jvm

wasm-wave: bin/cicero.wasm

v3i: bin/cicero.v3i

ENGINE=src/*.v3 src/eval/*.v3 src/util/*.v3
CORE=lib/*.co
CICERO=$(ENGINE) $(LIB)

TAGS: $(CICERO)
	vctags -e $(CICERO)

# JVM targets
bin/cicero.jvm: $(CICERO) build.sh
	./build.sh cicero jvm

# WAVE targets
bin/cicero.wasm: $(CICERO) build.sh
	./build.sh cicero wasm-wave

# x86-linux targets
bin/cicero.x86-linux: $(CICERO) build.sh
	./build.sh cicero x86-linux

# x86-64-linux targets
bin/cicero.x86-64-linux: $(CICERO) build.sh
	./build.sh cicero x86-64-linux

# interpreter targets
bin/cicero.v3i: $(CICERO) build.sh
	./build.sh cicero v3i
