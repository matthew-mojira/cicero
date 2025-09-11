CICERO=bin/cicero

hyperfine \
	"$CICERO.x86-64-linux -tier=0 examples/richards.co" \
	"$CICERO.x86-64-linux -tier=1 examples/richards.co" \
	"wizeng $CICERO.wasm -tier=0 examples/richards.co"
