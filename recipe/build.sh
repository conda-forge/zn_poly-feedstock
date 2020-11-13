#!/bin/bash

unset _CONDA_PYTHON_SYSCONFIGDATA_NAME

export CFLAGS="-g -O3 -fPIC $CFLAGS"

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="-Wno-unknown-attributes $CFLAGS"
fi

chmod +x configure

./configure \
        --prefix="$PREFIX" \
        --gmp-prefix="$PREFIX" \
        --cflags="$CFLAGS" \
        --ldflags="$LDFLAGS" \
        --cppflags="$CPPFLAGS" \
        --cxxflags="$CXXFLAGS"

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make tune
  tune/tune > src/tuning.c
  make
  make check
else
  CC=$CC_FOR_BUILD CFLAGS="" CXXFLAGS="" CPPFLAGS="" LDFLAGS="-L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib" make tune
  tune/tune > src/tuning.c
  make
fi

make libzn_poly${SHLIB_EXT}
make install

cp libzn_poly*$SHLIB_EXT "$PREFIX/lib"
