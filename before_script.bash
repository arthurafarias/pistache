#!/bin/bash -ve

export $(cat /etc/*release | grep DISTRIB_CODENAME)

sudo apt-get update

sudo apt-get install -y software-properties-common

# This updates libstdc++ to version 4.9 which makes this software compiles correctly in clang.
# In Ubuntu Trusty this library will just works with g++-4.9 backport and so on.
# It's impossible to build this in trusty without backports once Ubuntu trusty release was in
# april 2014 and GCC at this time wasnt supporting C++14. In this case, third-party backports
# as provided by ubuntu-toolchain-r/test are necessary to build this in ubuntu xenial and trusty
# natively. Here we configure this backports repository and install g++-4.9.
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y g++-4.9

if [[ "$COMPILER_NAME" = "clang" ]]; then
    export C_COMPILER_PACKAGE=clang-$COMPILER_VERSION
    export C_COMPILER_BIN=clang-$COMPILER_VERSION
    export CPP_COMPILER_PACKAGE=
    export CPP_COMPILER_BIN=clang++-$COMPILER_VERSION
    export COV_TOOL_BIN=llvm-cov-$COMPILER_VERSION
    if [ ! -z "$(sudo apt-cache search llvm-$COMPILER_VERSION-tools)" ]; then export COV_TOOL_PACKAGE="$COV_TOOL_PACKAGE llvm-$COMPILER_VERSION-tools"; fi
    if [ ! -z "$(sudo apt-cache search llvm-$COMPILER_VERSION)" ]; then export COV_TOOL_PACKAGE="$COV_TOOL_PACKAGE llvm-$COMPILER_VERSION-tools"; fi
    export COV_TOOL_ARGS=gcov
elif [[ "$COMPILER_NAME" = "gcc" ]]; then
    export C_COMPILER_PACKAGE=gcc-$COMPILER_VERSION
    export C_COMPILER_BIN=gcc-$COMPILER_VERSION
    export CPP_COMPILER_PACKAGE=g++-$COMPILER_VERSION
    export CPP_COMPILER_BIN=g++-$COMPILER_VERSION
    export COV_TOOL_BIN=gcov-$COMPILER_VERSION
    export COV_TOOL_PACKAGE=gcov-$COMPILER_VERSION
fi

export CC=$C_COMPILER_BIN
export CXX=$CPP_COMPILER_BIN

sudo apt-get update
sudo apt-get install -y coreutils apparmor-profiles libssl-dev libcurl4-openssl-dev gdb valgrind lcov python-pip python3-pip git $C_COMPILER_PACKAGE $CPP_COMPILER_PACKAGE $CPP_STDLIB_PACKAGE

sudo python -m pip install --upgrade pip
sudo python3 -m pip install --upgrade pip

sudo pip3 install cmake

# Enable core dumps
ulimit -c
ulimit -a -S
ulimit -a -H

# Print debug system information
cat /proc/sys/kernel/core_pattern
cat /etc/default/apport || true
service --status-all || true
initctl list || true

mkdir -p $TRAVIS_BUILD_DIR/build/debug
mkdir -p $TRAVIS_BUILD_DIR/build/release

cd $TRAVIS_BUILD_DIR/build/debug

# Debug build
cmake -B$TRAVIS_BUILD_DIR/build/debug \
    -DCMAKE_BUILD_TYPE=debug \
    -DPISTACHE_BUILD_EXAMPLES=true \
    -DPISTACHE_BUILD_TESTS=true \
    -DPISTACHE_SSL=true \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX $TRAVIS_BUILD_DIR

cd $TRAVIS_BUILD_DIR/build/release

# Release build
cmake -B$TRAVIS_BUILD_DIR/build/release \
    -DCMAKE_BUILD_TYPE=Release \
    -DPISTACHE_SSL=true \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX $TRAVIS_BUILD_DIR

cd $TRAVIS_BUILD_DIR