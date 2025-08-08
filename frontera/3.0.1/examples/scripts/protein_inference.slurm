#!/bin/bash
#----------------------------------------------------------------------
#SBATCH -J protein_inf                      # Job name
#SBATCH -o protein_inf.o%j                  # Name of stdout output file
#SBATCH -e protein_inf.e%j                  # Name of stderr error file
#SBATCH -p rtx                              # Queue (partition) name
#SBATCH -N 1                                # Total # of nodes
#SBATCH -t 01:00:00                         # Run time (hh:mm:ss)
#SBATCH -A <your-allocation>                # Allocation name
#----------------------------------------------------------------------

# Load required modules
module use /scratch2/projects/bio/alphafold3/modulefiles
module load alphafold3/3.0.1-ctr.lua

# Set input/output/model parameters directories
export AF3_INPUT_DIR=$SCRATCH/output/uqcr11_hsapiens
export AF3_OUTPUT_DIR=$SCRATCH/output/uqcr11_hsapiens
export AF3_MODEL_PARAMETERS_DIR=$WORK/af3_parameters

# Run AlphaFold3 using the shell function defined by the module
run_alphafold3 --json_path=$AF3_INPUT_DIR/uqcr11_hsapiens_data.json --norun_data_pipeline