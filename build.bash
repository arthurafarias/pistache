#!/bin/bash -ve

rm -rf build

if [ ! -x $COMPILER_NAME ]; then export COMPILER_NAME=gcc; fi
if [ ! -x $COMPILER_VERSION ]; then export COMPILER_VERSION=8; fi

. ./.travis/before_script.bash

make -C $TRAVIS_BUILD_DIR/build/debug -j $(nproc) all test VERBOSE=1 ARGS=-V
make -C $TRAVIS_BUILD_DIR/build/release -j $(nproc) all  VERBOSE=1 ARGS=-V