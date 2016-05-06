#!/bin/bash
set -e

FSROOT="./benchfs"
BIN="$FSROOT/usr/bin"
HBENCH="./test/hbench-os"
SHROOT="./fs"

export CHROME_BIN='google-chrome-beta'

export EMFLAGS='--memory-init-file 0 -s EMTERPRETIFY=1 -s EMTERPRETIFY_ASYNC=1 -s EMTERPRETIFY_BROWSIX=1 -O1'

(cd $HBENCH && make PLATFORM=js-pc-browsix EXT=.js CC="emcc $EMFLAGS")

# benchmarks to run
BENCHMARKS='lat_syscall lat_pipe lat_tcp lat_proc hello'

mkdir -p "$FSROOT/dev"
# fixme: this is a hack
touch "$FSROOT/dev/null"
mkdir -p "$BIN"

for b in $BENCHMARKS; do
	cp -a "$HBENCH/bin/browsix-js/$b.js" "$BIN/$b"
done

make bin

# copy in a few extra programs, mainly the shell
cp "$SHROOT/usr/bin/sh" "$BIN"

mkdir -p results

node_modules/.bin/gulp bench >results/raw
