#!/bin/bash -ve

export $(cat /etc/*release | grep DISTRIB_CODENAME)

sudo apt-get update

if [[ "$DISTRIB_CODENAME" = "trusty" ]]; then
    sudo apt-get install -y software-properties-common
    # LLVM Recomends this PPA so we can trust since ubuntu 14.04 libstdc++
    # and compilers are broken https://github.com/stan-dev/math/issues/604
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt-get update
fi

if [[ "$COMPILER_NAME" = "clang" ]]; then
    export C_COMPILER_PACKAGE=clang-$COMPILER_VERSION
    export C_COMPILER_BIN=clang-$COMPILER_VERSION
    export CPP_COMPILER_PACKAGE=
    export CPP_COMPILER_BIN=clang++-$COMPILER_VERSION
    export COV_TOOL_BIN=llvm-cov-$COMPILER_VERSION
    if [ ! -z "$(sudo apt-cache search llvm-$COMPILER_VERSION-tools)" ]; then export COV_TOOL_PACKAGE="$COV_TOOL_PACKAGE llvm-$COMPILER_VERSION-tools"; fi
    if [ ! -z "$(sudo apt-cache search llvm-$COMPILER_VERSION)" ]; then export COV_TOOL_PACKAGE="$COV_TOOL_PACKAGE llvm-$COMPILER_VERSION-tools"; fi
    export COV_TOOL_ARGS=gcov
    # This updates libstdc++ to version 4.9 which makes this software compiles accordingly
    # that is, in trusty this library will just works with g++ 4.9 backport and so on
    export CPP_STDLIB_PACKAGE=g++-4.9
elif [[ "$COMPILER_NAME" = "gcc" ]]; then
    export C_COMPILER_PACKAGE=gcc-$COMPILER_VERSION
    export C_COMPILER_BIN=gcc-$COMPILER_VERSION
    export CPP_COMPILER_PACKAGE=g++-$COMPILER_VERSION
    export CPP_COMPILER_BIN=g++-$COMPILER_VERSION
    export COV_TOOL_BIN=gcov-$COMPILER_VERSION
    export COV_TOOL_PACKAGE=gcov-$COMPILER_VERSION
    export COV_TOOL_ARGS=
    export CPP_STDLIB_PACKAGE=
fi

export CC=$C_COMPILER_BIN
export CXX=$CPP_COMPILER_BIN
export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"