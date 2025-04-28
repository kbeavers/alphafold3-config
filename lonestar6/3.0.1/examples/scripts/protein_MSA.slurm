#!/bin/bash
#----------------------------------------------------------------------
#SBATCH -J protein_MSA.slurm            # Job name
#SBATCH -o protein_MSA.o%j              # Name of stdout output file
#SBATCH -e protein_MSA.e%j              # Name of stderr error file
#SBATCH -p normal                       # Queue (partition) name
#SBATCH -N 1                            # Total # of nodes
#SBATCH -t 01:00:00                     # Run time (hh:mm:ss)
#SBATCH -A <your-allocation>            # Allocation name
#----------------------------------------------------------------------

# Load required modules
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.1-ctr_updated.lua

# Set input/output/model parameters directories
export AF3_INPUT_DIR=$SCRATCH/AF3_TESTING/input
export AF3_OUTPUT_DIR=$SCRATCH/AF3_TESTING/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_weights

# Run AlphaFold3 using the shell function defined by the module
run_alphafold3 --json_path=$AF3_INPUT_DIR/standard_protein.json --norun_inference