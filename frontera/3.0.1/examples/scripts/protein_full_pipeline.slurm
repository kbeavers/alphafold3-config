#!/bin/bash
#----------------------------------------------------------------------
#SBATCH -J protein_full_pipeline.slurm            # Job name
#SBATCH -o protein_full_pipeline.o%j              # Name of stdout output file
#SBATCH -e protein_full_pipeline.e%j              # Name of stderr error file
#SBATCH -p rtx                                    # Queue (partition) name
#SBATCH -N 1                                      # Total # of nodes
#SBATCH -t 01:00:00                               # Run time (hh:mm:ss)
#SBATCH -A <your-allocation>                      # Allocation name
#----------------------------------------------------------------------

# Load required modules
module use /scratch2/projects/bio/alphafold3/modulefiles
module load alphafold3/3.0.1-ctr.lua

# Set input/output/model parameters directories
export AF3_INPUT_DIR=$SCRATCH/AF3_TESTING/input
export AF3_OUTPUT_DIR=$SCRATCH/AF3_TESTING/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_weights

# Run AlphaFold3 using the shell function defined by the module
run_alphafold3 --json_path=$AF3_INPUT_DIR/standard_protein.json