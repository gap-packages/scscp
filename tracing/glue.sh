#!/bin/sh
cd ../tmp/
cat ../tracing/stdhead.txt euler.localhost.26133.tr euler.localhost.26134.tr euler.client.tr > euler.trs
cat ../tracing/stdhead.txt quillen16.localhost.26133.tr quillen16.localhost.26134.tr quillen16.client.tr > quillen16.trs
cat ../tracing/stdhead.txt quillen100.localhost.26133.tr quillen100.localhost.26134.tr quillen100.client.tr > quillen100.trs
cat ../tracing/stdhead.txt vkg64.localhost.26133.tr vkg64.localhost.26134.tr vkg64.client.tr > vkg64.trs
cat ../tracing/stdhead.txt vkg81.localhost.26133.tr vkg81.localhost.26134.tr vkg81.client.tr > vkg81.trs
rm *.tr