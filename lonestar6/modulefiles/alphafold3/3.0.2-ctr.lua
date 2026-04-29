local help_message = [[
This is a module file for the container tacc/alphafold3_3.0.2, which exposes the
following program:

 - run_alphafold3

This command launches AlphaFold3 inside an Apptainer container using GPU support.
You must define the following variables before running:
 
    export AF3_INPUT_DIR=/your/json/dir
    export AF3_OUTPUT_DIR=/your/output/dir
    export AF3_MODEL_PARAMETERS_DIR=/your/model/parameters/dir

Optional variables:

    export AF3_FLASH_ATTN=triton      # Flash attention backend: triton (default), cudnn, xla
                                      # 'cudnn' requires Hopper (H100) GPUs or later
    export AF3_FORCE_OUTPUT_DIR=1     # Allow writing into an existing output directory
    export AF3_SAVE_DISTOGRAM=1      # Save distrogram as part of output

    # Unified memory (GPU spill to host RAM)
    export XLA_PYTHON_CLIENT_PREALLOCATE=false
    export TF_FORCE_UNIFIED_MEMORY=true
    export XLA_CLIENT_MEM_FRACTION=3.2 
    
This container was pulled from:

  https://hub.docker.com/r/tacc/alphafold3

If you encounter errors in alphafold or need help running the
tools it contains, please find supporting documentation at:

  https://portal.tacc.utexas.edu/software/alphafold3

]]

help(help_message, "\n")

whatis("Name: alphafold3")
whatis("Version: 3.0.2")
whatis("Category: Bioinformatics")
whatis("Keywords: Container, AlphaFold3")
whatis("Description: AlphaFold3 run environment using TACC container image.")
whatis("URL: https://github.com/google-deepmind/alphafold3")

-- Environment vars
setenv("AF3_HOME", "/scratch/tacc/apps/bio/alphafold3/3.0.2")
setenv("AF3_IMAGE", "/scratch/tacc/apps/bio/alphafold3/3.0.2/image/alphafold3_3.0.2.sif")
setenv("AF3_CODE_DIR", "/scratch/tacc/apps/bio/alphafold3/3.0.2/code")
setenv("AF3_DATABASES_DIR", "/scratch/tacc/apps/bio/alphafold3/3.0.2/data")
setenv("AF3_FLASH_ATTN", "triton")

-- Load dependencies
always_load("tacc-apptainer")
try_load("cuda/12.8")

-- Shell function
set_shell_function("run_alphafold3",
"apptainer exec --nv " ..
"  ${XLA_PYTHON_CLIENT_PREALLOCATE:+--env XLA_PYTHON_CLIENT_PREALLOCATE=$XLA_PYTHON_CLIENT_PREALLOCATE } " ..
"  ${TF_FORCE_UNIFIED_MEMORY:+--env TF_FORCE_UNIFIED_MEMORY=$TF_FORCE_UNIFIED_MEMORY } " ..
"  ${XLA_CLIENT_MEM_FRACTION:+--env XLA_CLIENT_MEM_FRACTION=$XLA_CLIENT_MEM_FRACTION } " ..
"  --env XLA_FLAGS=\"--xla_disable_hlo_passes=custom-kernel-fusion-rewriter\" " ..
"  --bind $AF3_INPUT_DIR:/root/af_input " ..
"  --bind $AF3_OUTPUT_DIR:/root/af_output " ..
"  --bind $AF3_MODEL_PARAMETERS_DIR:/root/models " ..
"  --bind $AF3_DATABASES_DIR:/root/public_databases " ..
"  $AF3_IMAGE " ..
"  bash -c ' " ..
"    args=(\"$@\"); " ..
"    for i in \"${!args[@]}\"; do " ..
"      if [[ ${args[$i]} == --json_path=* ]]; then " ..
"        val=${args[$i]#--json_path=}; " ..
"        args[$i]=--json_path=/root/af_input/$(basename \"$val\"); " ..
"      fi; " ..
"    done; " ..
"    python $AF3_CODE_DIR/run_alphafold.py " ..
"      --output_dir=/root/af_output " ..
"      --model_dir=/root/models " ..
"      --db_dir=/root/public_databases " ..
"      --flash_attention_implementation=${AF3_FLASH_ATTN:-triton} " ..
"      ${AF3_FORCE_OUTPUT_DIR:+--force_output_dir } " ..
"      ${AF3_SAVE_DISTOGRAM:+--save_distogram } " ..
"      \"${args[@]}\"; " ..
"  ' -- \"$@\"",
-- C-shell version
"apptainer exec --nv " ..
"  ${XLA_PYTHON_CLIENT_PREALLOCATE:+--env XLA_PYTHON_CLIENT_PREALLOCATE=$XLA_PYTHON_CLIENT_PREALLOCATE } " ..
"  ${TF_FORCE_UNIFIED_MEMORY:+--env TF_FORCE_UNIFIED_MEMORY=$TF_FORCE_UNIFIED_MEMORY } " ..
"  ${XLA_CLIENT_MEM_FRACTION:+--env XLA_CLIENT_MEM_FRACTION=$XLA_CLIENT_MEM_FRACTION } " ..
"  --env XLA_FLAGS=\"--xla_disable_hlo_passes=custom-kernel-fusion-rewriter\" " ..
"  --bind $AF3_INPUT_DIR:/root/af_input " ..
"  --bind $AF3_OUTPUT_DIR:/root/af_output " ..
"  --bind $AF3_MODEL_PARAMETERS_DIR:/root/models " ..
"  --bind $AF3_DATABASES_DIR:/root/public_databases " ..
"  $AF3_IMAGE " ..
"  python $AF3_CODE_DIR/run_alphafold.py " ..
"    --output_dir=/root/af_output " ..
"    --model_dir=/root/models " ..
"    --db_dir=/root/public_databases " ..
"    --flash_attention_implementation=${AF3_FLASH_ATTN:-triton} " ..
"    ${AF3_FORCE_OUTPUT_DIR:+--force_output_dir } " ..
"    ${AF3_SAVE_DISTOGRAM:+--save_distogram } " ..
"    $*")