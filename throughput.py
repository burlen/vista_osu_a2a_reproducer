import sys

fn = sys.argv[1]
f = open(fn)

part = fn.split('_')[1]
n_per_node = 2 if part == 'gg' else 1
n_nodes = int(fn.split('_')[4][1:])
n_ranks = n_nodes*n_per_node

print('Bi-Directional Throuput %s Num Ranks %d'%(part.upper(),n_ranks))
print('Num Ranks, Per-Process Size (KB), Total Size (MB), Time (s), Throughput (GB/s)')

for line in f.readlines():
  if line[0].isdigit():
    msz_B, time_us = line.split()
    msz_B = float(msz_B)
    time_us = float(time_us)
    print('%d, %g, %g, %g, %g'%(n_ranks,
                                msz_B/1e3,
                                2*n_ranks*msz_B/1e6,
                                time_us/1e6,
                                2*n_ranks*msz_B/time_us*1e6/1e9))









