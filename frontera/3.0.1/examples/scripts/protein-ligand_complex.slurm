#!/bin/bash
#----------------------------------------------------------------------
#SBATCH -J protein-ligand_complex.slurm       # Job name
#SBATCH -o protein-ligand_complex.o%j         # Name of stdout output file
#SBATCH -e protein-ligand_complex.e%j         # Name of stderr error file
#SBATCH -p rtx                                # Queue (partition) name
#SBATCH -N 1                                  # Total # of nodes
#SBATCH -t 01:00:00                           # Run time (hh:mm:ss)
#SBATCH -A <your-allocation>                  # Allocation name
#----------------------------------------------------------------------

# Load required modules
module use /scratch2/projects/bio/alphafold3/modulefiles
module load alphafold3/3.0.1-ctr.lua

# Set environment variable definitions to point to your input, output, and model parameters directories:
# - DO modify these variables
export AF3_INPUT_DIR=$SCRATCH/input
export AF3_OUTPUT_DIR=$SCRATCH/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_weights

# Run the container
apptainer exec \
     --nv \
     --bind $AF3_INPUT_DIR:/root/af_input \
     --bind $AF3_OUTPUT_DIR:/root/af_output \
     --bind $AF3_MODEL_PARAMETERS_DIR:/root/models \
     --bind $AF3_DATABASES_DIR:/root/public_databases \
     $AF3_IMAGE \
     python ${AF3_CODE_DIR}/run_alphafold.py \
     --json_path=/root/af_input/protein-ligand_complex.json \
     --model_dir=/root/models \
     --db_dir=/root/public_databases \
     --output_dir=/root/af_output