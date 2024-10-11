#!/bin/bash

set -x

#
# Test on 59 Nodes
#
sbatch -N 59 -J osu_a2a_N59 ./osu_a2a_vista_gh.sh

#
# Test on 60 Nodes
#

# don't start the 60 node run until the 59 node run finished
jid=`sacct -X -u bloringnv -o JobId | tail -n1`

sbatch -N 60 -J osu_a2a_N60 -d afterany:${jid} ./osu_a2a_vista_gh.sh
