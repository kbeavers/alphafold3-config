#!/bin/bash
#
# --- Example script for running the full MSA + inference pipeline on CPU-only node
#
#SBATCH -J full_pipeline_cpu
#SBATCH -o full_pipeline_cpu.%j.out
#SBATCH -e full_pipeline_cpu.%j.err
#SBATCH -p gg
#SBATCH -N 1
#SBATCH -t 06:00:00
#SBATCH -A <your-project>

module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr  # CPU-only mode only works with v3.0.4                

#REQUIRED ENV VARIABLES
export AF3_INPUT_DIR=$SCRATCH/input
export AF3_OUTPUT_DIR=$SCRATCH/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

#OPTIONAL ENV VARIABLES
export AF3_CPU=1                  # Run CPU-only: drop --nv, set --jax_backend=cpu, default fla>
export AF3_SAVE_DISTOGRAM=1       # Save distogram as part of output

run_alphafold3 --json_path=$AF3_INPUT_DIR/modified_protein.json