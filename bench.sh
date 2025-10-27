CICERO=bin/cicero
WIZENG=wizeng

hyperfine -N -r 2 \
	"$WIZENG --mode=int  $CICERO.wasm -tier=0 examples/richards.co" \
	"$WIZENG --mode=int  $CICERO.wasm -tier=1 examples/richards.co" \
	"$WIZENG --mode=int  $CICERO.wasm -tier=2 examples/richards.co" \
	"$WIZENG --mode=jit  $CICERO.wasm -tier=0 examples/richards.co" \
	"$WIZENG --mode=jit  $CICERO.wasm -tier=1 examples/richards.co" \
	"$WIZENG --mode=jit  $CICERO.wasm -tier=2 examples/richards.co" \
	"$WIZENG --mode=lazy $CICERO.wasm -tier=0 examples/richards.co" \
	"$WIZENG --mode=lazy $CICERO.wasm -tier=1 examples/richards.co" \
	"$WIZENG --mode=lazy $CICERO.wasm -tier=2 examples/richards.co" \
	"$WIZENG --mode=dyn  $CICERO.wasm -tier=0 examples/richards.co" \
	"$WIZENG --mode=dyn  $CICERO.wasm -tier=1 examples/richards.co" \
	"$WIZENG --mode=dyn  $CICERO.wasm -tier=2 examples/richards.co"
