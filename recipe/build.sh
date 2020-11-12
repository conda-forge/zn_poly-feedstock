#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
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
  make
fi

make libzn_poly${SHLIB_EXT}
make install

cp libzn_poly*$SHLIB_EXT "$PREFIX/lib"
