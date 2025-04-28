local help_message = [[
This is a module file for the container tacc/alphafold:3.0.1-rtx, which exposes the
following program:

 - run_alphafold3

This command launches AlphaFold3 inside an Apptainer container using GPU support.
You must define the following variables before running:
 
   export AF3_INPUT_DIR=/your/json/dir
   export AF3_OUTPUT_DIR=/your/output/dir
   export AF3_MODEL_PARAMETERS_DIR=/your/model/parameters/dir

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
whatis("Keywords: Container, AlphaFold3")
whatis("Description: AlphaFold3 run environment using TACC container image.")
whatis("URL: https://github.com/google-deepmind/alphafold3")

set_shell_function("run_alphafold3",
"apptainer exec --nv " ..
"  --bind $AF3_INPUT_DIR:/root/af_input " ..
"  --bind $AF3_OUTPUT_DIR:/root/af_output " ..
"  --bind $AF3_MODEL_PARAMETERS_DIR:/root/models " ..
"  --bind $AF3_DATABASES_DIR:/root/public_databases " ..
"  $AF3_IMAGE " ..
"  bash -c ' " ..
"    has_gpu=$(nvidia-smi >/dev/null 2>&1 && echo yes || echo no); " ..
"    args=(\"$@\"); " ..
"    for i in \"${!args[@]}\"; do " ..
"      if [[ ${args[$i]} == --json_path=* ]]; then " ..
"        val=${args[$i]#--json_path=}; " ..
"        args[$i]=--json_path=/root/af_input/$(basename \"$val\"); " ..
"      fi; " ..
"    done; " ..
"    if [[ \"$has_gpu\" == \"yes\" ]]; then " ..
"      python $AF3_CODE_DIR/run_alphafold.py " ..
"        --output_dir=/root/af_output " ..
"        --model_dir=/root/models " ..
"        --db_dir=/root/public_databases " ..
"        --flash_attention_implementation=xla " ..
"        \"${args[@]}\"; " ..
"    else " ..
"      python $AF3_CODE_DIR/run_alphafold.py " ..
"        --output_dir=/root/af_output " ..
"        --model_dir=/root/models " ..
"        --db_dir=/root/public_databases " ..
"        \"${args[@]}\"; " ..
"    fi' -- \"$@\"",
-- C-shell version
"apptainer exec --nv " ..
"  --bind $AF3_INPUT_DIR:/root/af_input " ..
"  --bind $AF3_OUTPUT_DIR:/root/af_output " ..
"  --bind $AF3_MODEL_PARAMETERS_DIR:/root/models " ..
"  --bind $AF3_DATABASES_DIR:/root/public_databases " ..
"  $AF3_IMAGE " ..
"  python $AF3_CODE_DIR/run_alphafold.py " ..
"    --output_dir=/root/af_output " ..
"    --model_dir=/root/models " ..
"    --db_dir=/root/public_databases " ..
"    $*")

-- Environment vars
setenv("AF3_HOME", "/scratch2/projects/bio/alphafold3/3.0.1")
setenv("AF3_IMAGE", "/scratch2/projects/bio/alphafold3/3.0.1/image/alphafold3_3.0.1-rtx.sif")
setenv("AF3_CODE_DIR", "/scratch2/projects/bio/alphafold3/3.0.1/code")
setenv("AF3_DATABASES_DIR", "/scratch2/projects/bio/alphafold3/3.0.1/data")
setenv("AF3_MODEL_PARAMETERS_DIR", "/scratch2/projects/bio/alphafold3/3.0.1/models")

-- Load dependencies
always_load("tacc-apptainer")
try_load("cuda/12.2")