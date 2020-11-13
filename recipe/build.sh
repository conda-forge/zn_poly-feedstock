#!/bin/bash

unset _CONDA_PYTHON_SYSCONFIGDATA_NAME

export CFLAGS="-g -O3 -fPIC $CFLAGS"

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="-Wno-unknown-attributes $CFLAGS"
fi

chmod +x configure

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
 (export CC=$CC_FOR_BUILD
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
 )
 make tune
 cp tune/tune $BUILD_PREFIX/bin/
 make clean
fi

./configure \
        --prefix="$PREFIX" \
        --gmp-prefix="$PREFIX" \
        --cflags="$CFLAGS" \
        --ldflags="$LDFLAGS" \
        --cppflags="$CPPFLAGS" \
        --cxxflags="$CXXFLAGS"

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  $BUILD_PREFIX/bin/tune > src/tuning.c
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
