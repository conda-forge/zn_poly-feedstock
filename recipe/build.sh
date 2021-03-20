#!/bin/bash

unset _CONDA_PYTHON_SYSCONFIGDATA_NAME

export CFLAGS="-g -O3 -fPIC $CFLAGS"

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="-Wno-unknown-attributes $CFLAGS"
fi

set -x
chmod +x configure

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
 (
  export CC=$CC_FOR_BUILD
  export CFLAGS=""
  export CXXFLAGS=""
  export CPPFLAGS=""
  export LDFLAGS="-L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib"
  ./configure \
        --prefix="$BUILD_PREFIX" \
        --gmp-prefix="$BUILD_PREFIX" \
        --cflags="$CFLAGS" \
        --ldflags="$LDFLAGS" \
        --cppflags="$CPPFLAGS" \
        --cxxflags="$CXXFLAGS"
  make tune
  cp tune/tune $BUILD_PREFIX/bin/
  make clean
 )
 EXTRA_CONFIGURE_ARGS="--disable-tuning"
fi

./configure \
        --prefix="$PREFIX" \
        --gmp-prefix="$PREFIX" \
        --cflags="$CFLAGS" \
        --ldflags="$LDFLAGS" \
        --cppflags="$CPPFLAGS" \
        --cxxflags="$CXXFLAGS" ${EXTRA_CONFIGURE_ARGS}

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  rm -rf tune/tuning.c
  $BUILD_PREFIX/bin/tune > tune/tuning.c
  make
else
  make tune
  tune/tune > src/tuning.c
  make
  make check
fi

make libzn_poly${SHLIB_EXT}
make install

cp libzn_poly*$SHLIB_EXT "$PREFIX/lib"
