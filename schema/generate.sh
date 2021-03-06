#!/bin/bash

# check is flatbuffer installed or not
FLATC=../3rd_party/flatbuffers/tmp/flatc
if [ ! -e $FLATC ]; then
  echo "*** building flatc ***"

  # make tmp dir
  pushd ../3rd_party/flatbuffers > /dev/null
  [ ! -d tmp ] && mkdir tmp
  cd tmp && rm -rf *

  # build
  env -i bash -l -c "cmake .. && make -j4"

  # dir recover
  popd > /dev/null
fi

# determine directory to use
DIR="default"
if [ -d "private" ]; then
  DIR="private"
fi

# clean up
echo "*** cleaning up ***"
rm -f current/*.h
[ ! -d current ] && mkdir current

# flatc all fbs
pushd current > /dev/null
echo "*** generating fbs under $DIR ***"
find ../$DIR/*.fbs | xargs ../$FLATC -c -b
popd > /dev/null

# build converter stuff
pushd ../tools/converter/ > /dev/null
./generate_schema.sh
popd > /dev/null

# finish
echo "*** done ***"
