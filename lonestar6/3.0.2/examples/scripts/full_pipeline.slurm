#!/bin/bash
#SBATCH -J af3_full_test
#SBATCH -o af3_full_test.o%j
#SBATCH -e af3_full_test.e%j
#SBATCH -p gpu-a100-small
#SBATCH -N 1
#SBATCH -t 02:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.2-ctr
 
export AF3_INPUT_DIR=$SCRATCH/input
export AF3_OUTPUT_DIR=$SCRATCH/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters
export AF3_SAVE_DISTOGRAM=1

run_alphafold3 --json_path=$AF3_INPUT_DIR/modified_protein.json