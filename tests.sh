#!/bin/sh
# Compares current source's ABI dump to ABI dump of last known
# SONAME bump git commit and looks for breaks. This test expects
# to be ran by CI and probably won't work locally.
set -e

error_message() {
	echo "##################################################"
	echo "# Attention! This branch contains an ABI break!  #"
	echo "# If this is intentional, be sure to increment   #"
	echo "# PKG_SONAME and/or update LAST_ABI_BUMP_COMMIT. #"
	echo "##################################################"
}

trap error_message ERR

# git commit hash of last known SONAME bump,
# usually passed as environment variable
LAST_ABI_BUMP_COMMIT=${LAST_ABI_BUMP_COMMIT:-"4c3c936"}

# Directory that contains this working branch's source code
BUILD_DIR="/tmp/build-dir"
cd "$BUILD_DIR"

# Dump this working branch's ABI
abi-dumper \
	"$BUILD_DIR"/lib/libgranite.so \
	-o "$BUILD_DIR"/proposed_commit.dump \
	-lver "proposed"

# Download master branch
git clone --quiet https://github.com/elementary/granite "$LAST_ABI_BUMP_COMMIT"
cd "$LAST_ABI_BUMP_COMMIT"

# Roll back to last known SONAME bump
git reset --quiet --hard "$LAST_ABI_BUMP_COMMIT"

# Compile last known SONAME bump
cmake . -DCMAKE_BUILD_TYPE=Debug
make

# Dump last known SONAME bump ABI
abi-dumper \
	"$BUILD_DIR"/"$LAST_ABI_BUMP_COMMIT"/lib/libgranite.so \
	-o "$BUILD_DIR"/"$LAST_ABI_BUMP_COMMIT".dump \
	-lver "$LAST_ABI_BUMP_COMMIT"

# Compare this working branch's ABI to last known SONAME bump ABI
abi-compliance-checker \
	-l granite \
	-old "$BUILD_DIR"/"$LAST_ABI_BUMP_COMMIT".dump \
	-new "$BUILD_DIR"/proposed_commit.dump
