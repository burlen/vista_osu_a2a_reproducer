#!/bin/bash

set -x

#
# Test on 58 Ranks
#
sbatch -N 29 -J osu_a2a_N29 ./osu_a2a_vista_gg.sh

#
# Test on 60 Ranks
#

# don't start the 60 rank run until the 59 rank run finished
sleep 2s
jid59=`sacct -X -u bloringnv -o JobId | tail -n1`

sbatch -N 30 -J osu_a2a_N30 -d afterany:${jid59} ./osu_a2a_vista_gg.sh

sleep 2s
jid60=`sacct -X -u bloringnv -o JobId | tail -n1`


#sleep 30

#python3 throughput.py out_osu_a2a_N59_${jid59}.txt
#python3 throughput.py out_osu_a2a_N60_${jid60}.txt



