#!/bin/bash

function exit_usage() {
    echo "Usage: build.sh <cicero> <x86-linux|x86-64-darwin|x86-64-linux|jvm|wasm-wave>"
    exit 1
}

if [ "$#" -lt 2 ]; then
    exit_usage
fi

V3C=${V3C:=$(which v3c)}
if [ ! -x "$V3C" ]; then
    echo "Virgil compiler (v3c) not found in \$PATH, and \$V3C not set"
    exit 1
fi

if [ "$VIRGIL_LIB" = "" ]; then
    if [ "$VIRGIL_LOC" = "" ]; then
	V3C_LOC=$(dirname $(which v3c))
	VIRGIL_LOC=$(cd $V3C_LOC/../ && pwd)
    fi
    VIRGIL_LIB=${VIRGIL_LOC}/lib/
fi

if [ ! -e "$VIRGIL_LIB/util/Vector.v3" ]; then
    echo "Virgil library code not found (searched $VIRGIL_LIB)."
    echo "Please set either: "
    echo "  VIRGIL_LOC, to the root of your Virgil installation"
    echo "  VIRGIL_LIB, to point directly to root of the library"
    exit 1
fi
    
ENGINE="src/*.v3 src/util/*.v3 src/eval/*.v3 $VIRGIL_LIB/util/*.v3"

PROGRAM=$1
TARGET=$2

function make_build_file() {
	local target=$TARGET

	local build_time=$(date "+%Y-%m-%d %H:%M:%S")
	build_file="bin/Build-${TARGET}.v3"
	if [ "$release" == "release" ]; then
		local build_data="$target $build_time Release"
	else
		local build_data="$target $build_time by ${USER}@${HOST}"
	fi

        # TODO: handle case where build is not in a git repo
	# TODO: use -redef-field instead of generating a build file
        REVS="$(git rev-list --count HEAD)"
	echo "var unused__ = (Version.buildData = \"$build_data\", Version.minorVersion = $REVS);" > $build_file

	echo $build_file
}


# compute sources
if [ "$PROGRAM" = "cicero" ]; then
    SOURCES="$ENGINE"
else
    exit_usage
fi

# make build file with target
BUILD_FILE=$(make_build_file)

# build cicero text
CICERO_TEXT="bin/CiceroTexts.v3"
echo "component CiceroTexts {" > "$CICERO_TEXT"

cicero_input="src/cicero-texts.txt"

cat $cicero_input | while read p; do
  cicero_filepath=./$(echo "$p" | awk '{print $1}')
  cicero_output=$(echo "$p" | awk '{print $2}')

  if [[ -f "$cicero_filepath" ]]; then
      cicero_content=$(tr -d '\n' < "$cicero_filepath")
      cicero_content=$(printf "%s" "$cicero_content" | sed 's/\\/\\\\/g')
      cicero_content=$(printf "%s" "$cicero_content" | sed 's/"/\\"/g')
      echo "	def $cicero_output: string = \"$cicero_content\";" >> "$CICERO_TEXT"
  else
      echo "Warning: File '$cicero_filepath' not found." >&2
  fi
done
echo "}" >> "$CICERO_TEXT"

PREGEN=${PREGEN:=1}

LANG_OPTS="-simple-bodies -fun-exprs"
V3C_OPTS="$V3C_OPTS -symbols -shadow-stack-size=10M -heap-size=200M -stack-size=16M -O2"

# build
exe=${PROGRAM}.${TARGET}
if [[ "$TARGET" = "x86-linux" || "$TARGET" = "x86_linux" ]]; then
    exec v3c-x86-linux $LANG_OPTS $V3C_OPTS -program-name=${exe} -output=bin/ $SOURCES $BUILD_FILE $CICERO_TEXT $TARGET_V3
elif [[ "$TARGET" = "x86-64-darwin" || "$TARGET" = "x86_64_darwin" ]]; then
    exec v3c-x86-64-darwin $LANG_OPTS $V3C_OPTS -program-name=${exe} -output=bin/ $SOURCES $BUILD_FILE $CICERO_TEXT $TARGET_V3
elif [[ "$TARGET" = "x86-64-linux" || "$TARGET" = "x86_64_linux" ]]; then
    v3c-x86-64-linux $LANG_OPTS $V3C_OPTS -program-name=${exe} -output=bin/ $SOURCES $BUILD_FILE $CICERO_TEXT $TARGET_X86_64
    STATUS=$?
    if [ $STATUS != 0 ]; then
	exit $STATUS
    fi
elif [ "$TARGET" = "jvm" ]; then
    v3c-jar $LANG_OPTS $V3C_OPTS -program-name=${exe} -output=bin/ $SOURCES $BUILD_FILE $CICERO_TEXT $TARGET_V3
elif [[ "$TARGET" == wasm-* ]]; then
    # Compile to a wasm target
    V3C_PATH=$(which v3c)
    V3C_WASM_TARGET=${V3C_PATH/bin\/v3c/bin\/dev\/v3c-$TARGET}
    if [ ! -x $V3C_WASM_TARGET ]; then
	echo Unknown Wasm target \"$TARGET\". Found these:
	ls -a ${V3C_PATH/bin\/v3c/bin\/dev\/v3c-wasm-*} | cat
	exit 1
    fi
    exec $V3C_WASM_TARGET $LANG_OPTS $V3C_OPTS -program-name=${PROGRAM} -output=bin/ $SOURCES $BUILD_FILE $CICERO_TEXT $TARGET_V3
elif [ "$TARGET" = "v3i" ]; then
    # check that the sources typecheck
    $V3C $LANG_OPTS $V3C_OPTS $SOURCES $TARGET_V3 $CICERO_TEXT
    RET=$?
    if [ $RET != 0 ]; then
	exit $RET
    fi
    DIR=$(pwd)
    LIST=""
    for f in $SOURCES $TARGET_V3; do
	if [[ "$f" != /* ]]; then
	    f="$DIR/$f"
	fi
	LIST="$LIST $(ls $f)"
    done
    echo '#!/bin/bash' > bin/$PROGRAM.v3i
    echo "v3i $LANG_OPTS \$V3C_OPTS $LIST $CICERO_TEXT" '$@' >> bin/$PROGRAM.v3i
    chmod 755 bin/$PROGRAM.v3i
    # run v3c just to check for compile errors
    exec $V3C $LANG_OPTS $V3C_OPTS $LIST $CICERO_TEXT
else
    exit_usage
fi
