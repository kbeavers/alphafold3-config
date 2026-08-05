#!/bin/bash
#SBATCH -J inference_only
#SBATCH -o inference_only.%j.out
#SBATCH -e inference_only.%j.err
#SBATCH -p gh
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/<version>-ctr                    # Set <version> to the release under test (e.g. 3.0.4).

export AF3_INPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_OUTPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/UQCR11_Hsapiens_data.json --norun_data_pipeline