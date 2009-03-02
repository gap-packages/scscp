#!/bin/sh
cat stdhead.txt euler.localhost.26133.tr euler.localhost.26134.tr euler.client.tr > euler.tr
cat stdhead.txt quillen.localhost.26133.tr quillen.localhost.26134.tr quillen.client.tr > quillen.tr
cat stdhead.txt vkg64.localhost.26133.tr vkg64.localhost.26134.tr vkg64.client.tr > vkg64.tr
cat stdhead.txt vkg81.localhost.26133.tr vkg81.localhost.26134.tr vkg81.client.tr > vkg81.tr
mv euler.tr quillen.tr vkg64.tr vkg81.tr ~/builds/EdenTV-2.0b.20090225/myfiles/
rm *.tr