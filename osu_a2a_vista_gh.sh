#!/bin/bash

#SBATCH -A OTH24023
#SBATCH -o out_%x_%j.txt
#SBATCH -e out_%x_%j.txt
#SBATCH -t 01:00:00
#SBATCH -p gh

# capture job id
echo SLURM_JOB_ID=${SLURM_JOB_ID}
echo SLURM_JOB_NUM_NODES=${SLURM_JOB_NUM_NODES}

# load modules
module load cuda/12.5
export PATH=/work/10108/bloringnv/vista/installs/osu-7.4-install/libexec/osu-micro-benchmarks/mpi/collective/:$PATH
socket=package # OpenMPI 4 vs 5

# CUDA/UCX settings
export CUDA_VISIBLE_DEVICES=0
export UCX_IB_SL=1
export UCX_DC_MLX5_NUM_DCI=32

# NUMA affinity
n_nodes=${SLURM_JOB_NUM_NODES}
gpus_per_node=1
cores_per_socket=72
sockets_per_node=1
let n_ranks=${n_nodes}*${gpus_per_node}
ranks_per_node=$(( n_ranks < gpus_per_node ? n_ranks : gpus_per_node ))
ranks_per_socket=$(( ranks_per_node / sockets_per_node ))
ranks_per_socket=$(( ranks_per_socket==0 ? 1 : ranks_per_socket ))
cores_per_rank=$(( cores_per_socket / ranks_per_socket ))

# set OpenMP thread affinity, use --report-bindings to show processor affinity
export OMP_NUM_THREADS=${cores_per_rank} OMP_PROC_BIND=true
bind_opts="--map-by ppr:${ranks_per_socket}:${socket}:PE=${cores_per_rank} --bind-to core"

# use UCX (required for CUDA aware features)
ucx_opts="--mca pml ucx --mca osc ucx --mca spml ucx"

# OSU command line
units=`printf %0.f 1e3`
min_msg_size_B=$(( 16 * units ))
max_msg_size_B=$(( 32768 * units ))
buf_size_B=$(( max_msg_size_B * n_ranks ))
echo "osu_alltoall sizes: $buf_size_B,  $min_msg_size_B, $max_msg_size_B"

osu_opts="-i 50 -x 10 -T mpi_float -d cuda -M ${buf_size_B} -m ${min_msg_size_B}:${max_msg_size_B}"

# disable udnerperforming implementations
#tuned_opts="--mca coll_ucc_enable 0 --mca coll_hcoll_enable 0"
tuned_opts="--mca coll_ucc_enable 0 --mca coll_hcoll_enable 0  --mca coll_tuned_use_dynamic_rules 1 --mca coll_tuned_alltoall_algorithm 4 --mca coll_tuned_alltoall_algorithm_max_requests 0 --mca coll_base_verbose 100"

# show the command we ran
set -x

mpirun -n ${n_ranks} ${ucx_opts} ${tuned_opts} ${bind_opts} osu_alltoall ${osu_opts}


