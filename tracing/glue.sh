#!/bin/sh
cd ../tmp/
cat ../tracing/stdhead.txt euler.localhost.26133.tr euler.localhost.26134.tr euler.client.tr > euler.tr
cat ../tracing/stdhead.txt quillen10.localhost.26133.tr quillen10.localhost.26134.tr quillen10.client.tr > quillen10.tr
cat ../tracing/stdhead.txt quillen100.localhost.26133.tr quillen100.localhost.26134.tr quillen100.client.tr > quillen100.tr
cat ../tracing/stdhead.txt vkg64.localhost.26133.tr vkg64.localhost.26134.tr vkg64.client.tr > vkg64.tr
cat ../tracing/stdhead.txt vkg81.localhost.26133.tr vkg81.localhost.26134.tr vkg81.client.tr > vkg81.tr
mv euler.tr quillen10.tr quillen100.tr vkg64.tr vkg81.tr ~/builds/EdenTV-2.0b.20090225/myfiles/
rm *.tr