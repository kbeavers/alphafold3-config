local help_message = [[
This is a module file for the container tacc/alphafold:3.0.1, which exposes the
following program:

 - run_alphafold.sh

This container was pulled from:

  https://hub.docker.com/r/tacc/alphafold3

If you encounter errors in alphafold or need help running the
tools it contains, please find supporting documentation at:

  https://portal.tacc.utexas.edu/software/alphafold3

]]

help(help_message,"\\n")

whatis("Name: alphafold3")
whatis("Version: 3.0.1")
whatis("Category: Bioinformatics")
whatis("Keywords: Container, alphafold3")
whatis("Description: Sets up the environment for AlphaFold3 using TACC's container image.")
whatis("URL: https://github.com/google-deepmind/alphafold3")

set_shell_function("run_alphafold.sh", "apptainer exec --nv /scratch/tacc/apps/bio/alphafold3/3.0.1/image/alphafold_3.0.1.sif /scratch/tacc/apps/bio/alphafold3/3.0.1/code/run_alphafold.sh $@","apptainer exec --nv /scratch/tacc/apps/bio/alphafold3/3.0.1/image/alphafold_3.0.1.sif /scratch/tacc/apps/bio/alphafold3/3.0.1/code/run_alphafold.sh $*")

setenv("AF3_HOME", "/scratch/tacc/apps/bio/alphafold3/3.0.1")
setenv("AF3_IMAGE", "/scratch/tacc/apps/bio/alphafold3/3.0.1/image/alphafold_3.0.1.sif")
setenv("AF3_CODE_DIR", "/scratch/tacc/apps/bio/alphafold3/3.0.1/code")
setenv("AF3_DATABASES_DIR", "/scratch/tacc/apps/bio/alphafold3/3.0.1/data")

always_load("tacc-apptainer")
try_load("cuda/12.2")