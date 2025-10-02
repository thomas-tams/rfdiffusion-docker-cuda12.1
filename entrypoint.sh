#!/bin/bash
set -e

# Source conda and activate environment
source /opt/conda/etc/profile.d/conda.sh
conda activate SE3nv

# Ensure CUDA libraries are in path (conda environment CUDA + NVIDIA runtime)
export LD_LIBRARY_PATH=/opt/conda/envs/SE3nv/lib:${LD_LIBRARY_PATH}

# Execute the command
exec "$@"
