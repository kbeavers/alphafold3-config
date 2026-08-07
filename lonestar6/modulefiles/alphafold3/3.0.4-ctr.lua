local help_message = [[
This is a module file for the container tacc/alphafold3_3.0.4, which exposes the
following program:

 - run_alphafold3

This command launches AlphaFold3 inside an Apptainer container. By default it runs on
GPU (apptainer --nv). As of AlphaFold3 v3.0.4 it can also run CPU-only: set AF3_CPU=1 to
drop GPU passthrough and default the flash-attention backend to 'xla' (the only backend
that runs without a GPU). CPU inference is much slower; submit CPU jobs to a CPU queue.

You must define the following variables before running:

    export AF3_INPUT_DIR=/your/json/dir
    export AF3_OUTPUT_DIR=/your/output/dir
    export AF3_MODEL_PARAMETERS_DIR=/your/model/parameters/dir

Optional variables:

    export AF3_CPU=1                   # Run CPU-only: drop --nv, set --jax_backend=cpu, default flash attn to xla
    export AF3_FLASH_ATTN=triton       # Flash attention backend: triton (GPU default), cudnn, xla
                                       # 'cudnn' requires Hopper (H100) GPUs or later
                                       # CPU runs must use 'xla' (the default when AF3_CPU=1)
    export AF3_FORCE_OUTPUT_DIR=1      # Allow writing into an existing output directory
    export AF3_SAVE_DISTOGRAM=1        # Save distogram as part of output

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
whatis("Version: 3.0.4")
whatis("Category: Bioinformatics")
whatis("Keywords: Container, AlphaFold3")
whatis("Description: AlphaFold3 run environment using TACC container image.")
whatis("URL: https://github.com/google-deepmind/alphafold3")

-- Environment vars
setenv("AF3_HOME", "/scratch/tacc/apps/bio/alphafold3/3.0.4")
setenv("AF3_IMAGE", "/scratch/tacc/apps/bio/alphafold3/3.0.4/image/alphafold3_3.0.4.sif")
setenv("AF3_CODE_DIR", "/scratch/tacc/apps/bio/alphafold3/3.0.4/code")
setenv("AF3_DATABASES_DIR", "/scratch/tacc/apps/bio/alphafold3/3.0.4/data")

-- Load dependencies
always_load("tacc-apptainer")
try_load("cuda/12.8")

-- Shell function
-- GPU by default (--nv, triton). Set AF3_CPU=1 for CPU-only (no --nv, xla default).
set_shell_function("run_alphafold3",
"if [ -z \"$AF3_CPU\" ]; then NV_FLAG=--nv; AF3_BACKEND=gpu; AF3_FA=${AF3_FLASH_ATTN:-triton}; else NV_FLAG=; AF3_BACKEND=cpu; AF3_FA=${AF3_FLASH_ATTN:-xla}; fi; " ..
"apptainer exec $NV_FLAG " ..
"  ${XLA_PYTHON_CLIENT_PREALLOCATE:+--env XLA_PYTHON_CLIENT_PREALLOCATE=$XLA_PYTHON_CLIENT_PREALLOCATE } " ..
"  ${TF_FORCE_UNIFIED_MEMORY:+--env TF_FORCE_UNIFIED_MEMORY=$TF_FORCE_UNIFIED_MEMORY } " ..
"  ${XLA_CLIENT_MEM_FRACTION:+--env XLA_CLIENT_MEM_FRACTION=$XLA_CLIENT_MEM_FRACTION } " ..
"  --env XLA_FLAGS=\"--xla_disable_hlo_passes=custom-kernel-fusion-rewriter\" " ..
"  --env AF3_FA=$AF3_FA --env AF3_BACKEND=$AF3_BACKEND " ..
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
"      --flash_attention_implementation=$AF3_FA --jax_backend=$AF3_BACKEND " ..
"      ${AF3_FORCE_OUTPUT_DIR:+--force_output_dir } " ..
"      ${AF3_SAVE_DISTOGRAM:+--save_distogram } " ..
"      \"${args[@]}\"; " ..
"  ' -- \"$@\"",
-- C-shell version
"if [ -z \"$AF3_CPU\" ]; then NV_FLAG=--nv; AF3_BACKEND=gpu; AF3_FA=${AF3_FLASH_ATTN:-triton}; else NV_FLAG=; AF3_BACKEND=cpu; AF3_FA=${AF3_FLASH_ATTN:-xla}; fi; " ..
"apptainer exec $NV_FLAG " ..
"  ${XLA_PYTHON_CLIENT_PREALLOCATE:+--env XLA_PYTHON_CLIENT_PREALLOCATE=$XLA_PYTHON_CLIENT_PREALLOCATE } " ..
"  ${TF_FORCE_UNIFIED_MEMORY:+--env TF_FORCE_UNIFIED_MEMORY=$TF_FORCE_UNIFIED_MEMORY } " ..
"  ${XLA_CLIENT_MEM_FRACTION:+--env XLA_CLIENT_MEM_FRACTION=$XLA_CLIENT_MEM_FRACTION } " ..
"  --env XLA_FLAGS=\"--xla_disable_hlo_passes=custom-kernel-fusion-rewriter\" " ..
"  --env AF3_FA=$AF3_FA --env AF3_BACKEND=$AF3_BACKEND " ..
"  --bind $AF3_INPUT_DIR:/root/af_input " ..
"  --bind $AF3_OUTPUT_DIR:/root/af_output " ..
"  --bind $AF3_MODEL_PARAMETERS_DIR:/root/models " ..
"  --bind $AF3_DATABASES_DIR:/root/public_databases " ..
"  $AF3_IMAGE " ..
"  python $AF3_CODE_DIR/run_alphafold.py " ..
"    --output_dir=/root/af_output " ..
"    --model_dir=/root/models " ..
"    --db_dir=/root/public_databases " ..
"    --flash_attention_implementation=$AF3_FA --jax_backend=$AF3_BACKEND " ..
"    ${AF3_FORCE_OUTPUT_DIR:+--force_output_dir } " ..
"    ${AF3_SAVE_DISTOGRAM:+--save_distogram } " ..
"    $*")
