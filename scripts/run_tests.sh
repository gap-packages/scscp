#!/usr/bin/env bash
set -ex

GAP="$GAPROOT/bin/gap.sh -l $PWD/externpkgs; --quitonbreak"

# unless explicitly turned off, we collect coverage data
if [[ -z $NO_COVERAGE ]]; then
    mkdir $COVDIR
    GAP="$GAP --cover $COVDIR/test.coverage"
fi

# start SCSCP servers
./gapd.sh -p 26133 GAPROOT=${GAPROOT}
./gapd.sh -p 26134 GAPROOT=${GAPROOT}

# allow some time for the SCSCP servers to start
sleep 60

$GAP tst/testall.g
