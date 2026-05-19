#!/bin/bash
#SBATCH --job-name=neuromancer_job
#SBATCH --output=/home/g202210120/neuromancer/examples/parametric_programming/logs/neuromancer_%j.out
#SBATCH --error=/home/g202210120/neuromancer/examples/parametric_programming/logs/neuromancer_%j.err
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --partition=gpu_x450
#SBATCH --gres=gpu:1
#SBATCH --chdir=/home/g202210120/neuromancer/examples/parametric_programming

# Exit immediately if a command exits with a non-zero status
set -e

# Load conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate neuromancer

# Validate input
if [ -z "$1" ]; then
    echo "Error: No Python script specified."
    echo "Usage: sbatch run_neuromancer.sh <script_name.py>"
    exit 1
fi

echo "--------------------------------------------------------"
echo "Job ID: $SLURM_JOB_ID"
echo "Running on node: $(hostname)"
echo "Target script: $1"
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
echo "--------------------------------------------------------"

# Optional: Start background GPU logger to monitor VRAM/Usage during simulation
nvidia-smi --query-gpu=timestamp,utilization.gpu,memory.used --format=csv -l 10 > logs/gpu_usage_$SLURM_JOB_ID.log &
GPU_LOG_PID=$!

# Run your python script
python -u "$1"

# Stop GPU logger
kill $GPU_LOG_PID

echo "--------------------------------------------------------"
echo "Finished execution of $1"