V3C_LOCATION=$(dirname $(which v3c))
VIRGIL_LOCATION=$(cd $V3C_LOCATION/../ && pwd)
    
LIB=$VIRGIL_LOCATION/lib/
FILES="$(dirname $0)/doubles_arith.v3 ../src/util/BigInteger.v3 ../src/util/DoubleParserHelper.v3 $LIB/util/*.v3"

LANG_OPTS="-simple-bodies -fun-exprs"
V3C_OPTS="$V3C_OPTS -symbols -shadow-stack-size=10M -heap-size=200M -stack-size=16M -O2"

v3i $LANG_OPTS $V3C_OPTS $FILES
