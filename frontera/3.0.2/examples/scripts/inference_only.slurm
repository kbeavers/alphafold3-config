#!/bin/bash
#SBATCH -J inf_test
#SBATCH -o inf_test.o%j
#SBATCH -e inf_test.e%j
#SBATCH -p rtx
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>

module use /scratch2/projects/bio/alphafold3/modulefiles
module load alphafold3/3.0.2-ctr

export AF3_INPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_OUTPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/UQCR11_Hsapiens_data.json --norun_data_pipeline