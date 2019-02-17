export COMPILER_NAME=gcc COMPILER_VERSION=4.9
. ./bootstrap.bash
make -C build/debug all test memcheck coverage
make -C build/release