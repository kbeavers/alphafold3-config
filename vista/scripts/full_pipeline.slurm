#!/bin/bash
#
# --- Example script for running the full MSA + inference pipeline
#
#SBATCH -J af3_full_pipeline
#SBATCH -o af3_full_pipeline.%j.out
#SBATCH -e af3_full_pipeline.%j.err
#SBATCH -p gh
#SBATCH -N 1
#SBATCH -t 02:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/<version>-ctr # Set <version> to your desired release (e.g. 3.0.4).

#REQUIRED ENV VARIABLES
export AF3_INPUT_DIR=$SCRATCH/input
export AF3_OUTPUT_DIR=$SCRATCH/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

#OPTIONAL ENV VARIABLES
export AF3_SAVE_DISTOGRAM=1          # Save distogram as part of output

run_alphafold3 --json_path=$AF3_INPUT_DIR/modified_protein.json