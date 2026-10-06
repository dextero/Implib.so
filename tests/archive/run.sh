#!/bin/sh

# Copyright 2026 Yury Gribov
#
# The MIT License (MIT)
#
# Use of this source code is governed by MIT license that can be
# found in the LICENSE.txt file.

# This is a test for generating stubs from a static archive (.a) where an
# earlier object member references a symbol defined in a later object member.

set -eu

cd $(dirname $0)

if test -n "${1:-}"; then
  ARCH="$1"
fi

. ../common.sh

AR=${PREFIX}${AR:-ar}
CFLAGS="-g -O2 $CFLAGS"

# Compile two object files where a.o references bar() (UND) and b.o defines bar().
$CC $CFLAGS -fPIC -c a.c -o a.o
$CC $CFLAGS -fPIC -c b.c -o b.o
rm -f libinterposed.a
$AR rcs libinterposed.a a.o b.o
$CC $CFLAGS -shared a.o b.o -o libinterposed.so

# Generate stubs from the static archive and load libinterposed.so at runtime.
${PYTHON:-python3} ../../implib-gen.py -q --target $TARGET --library-load-name=libinterposed.so libinterposed.a

$CC $CFLAGS main.c libinterposed.a.tramp.S libinterposed.a.init.c $LIBS

LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH:-} $INTERP ./a.out > a.out.log
diff test.ref a.out.log

echo SUCCESS
