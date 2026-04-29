#!/bin/bash
#SBATCH -J msa_test
#SBATCH -o msa_test.%j.out
#SBATCH -e msa_test.%j.err
#SBATCH -p gg
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.2-ctr

export AF3_INPUT_DIR=$SCRATCH/input/
export AF3_OUTPUT_DIR=$SCRATCH/output/
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/standard_protein.json --norun_inference