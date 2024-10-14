# OSU All-to-all TACC Vista Grace-Hopper Reproducer
Reproduces all-to-all perf drop between 59 and 60 nodes. That started happening after September 15 2024.
What these scripts do: Runs osu_alltoall twice, once on 59 nodes and the second on 60. 
A python script `throughput.py` can be used to convert time reported by the OSU benchmark output into a throughput.

## Solution
We found that setting `export UCX_TLS=^dc` resolved the issue.

## Dependencies
This reprodcuer requires OSU micro benchmarks to be compiled with CUDA support enabled. If you see an unknown command line option error, you have not compiled OSU suite with CUDA features enabled.

## Setup
Before running edit `osu_a2a_vista_gh.sh` and fix PATH to point to your OSU install. Note: current OSU benchmark install at TACC is not CUDA aware, and  cannot be used.

## Running
To run from the login node
```
$ git clone https://github.com/burlen/vista_osu_a2a_reproducer.git
$ cd vista_osu_a2a_reproducer
$ ./sbatch_osu_a2a_vista_gh.sh
```
This will submit 2 jobs and generate 2 files. A python script `throughput.py` can be used to convert time reported by the OSU benchmark into a throughput. Pass the name of the file on the command line.

## Example Results
After the run the `throughput.py` script can be used to generate a table. Here is for a 59 node run
```
login1.vista(1180)$ python3 throughput.py out_osu_a2a_N59_50125.txt
Bi-Directional Throuput out_osu_a2a_N59_50125.txt Num Ranks 59
Num Ranks, Per-Process Size (KB), Total Size (MB), Time (s), Throughput (GB/s)
59, 16, 1.888, 6.736e-05, 28.0285
59, 32, 3.776, 8.926e-05, 42.3034
59, 64, 7.552, 0.00013271, 56.906
59, 128, 15.104, 0.00023128, 65.3061
59, 256, 30.208, 0.00043747, 69.0516
59, 512, 60.416, 0.00082966, 72.8202
59, 1024, 120.832, 0.00160427, 75.319
59, 2048, 241.664, 0.00321859, 75.0838
59, 4096, 483.328, 0.00618589, 78.1339
59, 8192, 966.656, 0.0114197, 84.6478
59, 16384, 1933.31, 0.0217713, 88.8009
59, 32768, 3866.62, 0.0426872, 90.5804
```
And here is for a 60 node run.
```
login1.vista(1182)$ python3 throughput.py out_osu_a2a_N60_50126.txt
Bi-Directional Throuput out_osu_a2a_N60_50126.txt Num Ranks 60
Num Ranks, Per-Process Size (KB), Total Size (MB), Time (s), Throughput (GB/s)
60, 16, 1.92, 0.0001047, 18.3381
60, 32, 3.84, 0.00013793, 27.8402
60, 64, 7.68, 0.00018537, 41.4307
60, 128, 15.36, 0.00029261, 52.4931
60, 256, 30.72, 0.00051882, 59.2113
60, 512, 61.44, 0.00098902, 62.1221
60, 1024, 122.88, 0.00200895, 61.1663
60, 2048, 245.76, 0.00387706, 63.3882
60, 4096, 491.52, 0.00743863, 66.0767
60, 8192, 983.04, 0.014491, 67.8379
60, 16384, 1966.08, 0.0288316, 68.1919
60, 32768, 3932.16, 0.0576565, 68.1998
```
The throughput is expected to be roughly the same between the two runs but is markedly different illustrating the issue.
