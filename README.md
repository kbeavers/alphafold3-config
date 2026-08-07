# AlphaFold @ TACC — New Release Setup Guide
 
This guide documents the process for installing and configuring a new AlphaFold3 release on TACC systems. 
 
> **v3.0.4 highlights:** AlphaFold3 v3.0.4 adds CPU-only inference support, and bumps JAX 0.9.1 → 0.10.2 / Tokamax 0.0.11 → 0.0.12 for faster inference. Each system keeps a single modulefile that runs on GPU by default; to run CPU-only on any system, set `AF3_CPU=1`, which drops GPU passthrough (`--nv`) and defaults the flash-attention backend to `xla` (`triton` and `cudnn` require a GPU).
 
---

## System Reference
 
| System | Base Path | Modulefile Path | Container Tag |
|--------|-----------|-----------------|---------------|
| Vista | `/scratch/tacc/apps/bio/alphafold3` | `/scratch/tacc/apps/bio/alphafold3/modulefiles` | `tacc/alphafold3:<version>` |
| Lonestar6 | `/scratch/tacc/apps/bio/alphafold3` | `/scratch/tacc/apps/bio/alphafold3/modulefiles` | `tacc/alphafold3:<version>` |
| Frontera | `/scratch2/projects/bio/alphafold3` | `/scratch2/projects/bio/alphafold3/modulefiles` | `tacc/alphafold3:<version>-rtx` |
| Horizon | _coming soon_ | _coming soon_ | _coming soon_ |
 
> Container images are listed at https://hub.docker.com/r/tacc/alphafold3/tags. Check this page for the correct tag when setting up a new release.
> The `<version>-rtx` tag is x86_64-only, built for Frontera's RTX GPUs.

---
 
## Repository Layout

This repo holds the per-system deployment artifacts. Example **inputs are shared** (identical across systems and versions), and **SLURM scripts are version-agnostic templates**:

```
alphafold3-config/
├── examples/input/                       # shared input JSONs
├── <system>/                             # vista, lonestar6
│   ├── modulefiles/alphafold3/<version>-ctr.lua
│   └── scripts/                          # templated SLURM jobs — set <version> before submitting
```

---

## Directory Structure (on-system)
 
Each release lives under the base installation path with the following layout:

```
<base_path>/
├── modulefiles/
├── examples/
    ├── input/
    └── scripts/
└── <version>/               # e.g., 3.0.4
    ├── code/
    ├── data/                # May be a symlink to a previous version's data
    └── image/
```
 
---

## Step 1: Create Directories
 
Log into the target system and navigate to the base path. Create the modulefile directory (shared across all versions) and the subdirectories for the new release:
 
```bash
cd <base_path>
mkdir modulefiles  # only if it doesn't already exist
mkdir -p <version>/{data,image}
```
 
**Example** for version `3.0.4` on Vista or Lonestar6:
 
```bash
cd /scratch/tacc/apps/bio/alphafold3
mkdir modulefiles
mkdir -p 3.0.4/{data,image}
```
 
---

## Step 2: Clone the Source Code
 
Navigate into the <version> directory and clone the AlphaFold3 repository at the specific release tag:
 
```bash
cd <base_path>/<version>
git clone --depth 1 --branch <tag_name> https://github.com/google-deepmind/alphafold3.git
```

For example:

```bash
git clone --depth 1 --branch v3.0.4 https://github.com/google-deepmind/alphafold3.git
```

This clone creates a subdirectory called `alphafold3/`. Rename to `code/`:

```bash
mv alphafold3/ code/
```
 
---

## Step 3: Set Up the Database Data
 
The database files are large (~627 GB) and take approximately 45 minutes to download. **You only need to do this once per system** — if a prior version's data directory already exists on the same filesystem, symlink to it instead (see below).
 
> **Note:** AlphaFold3 database files are compatible across all `3.0.x` versions (as of now). Check the [release notes](https://github.com/google-deepmind/alphafold3/releases) before downloading to confirm whether a new release actually requires updated database files.
 
### Option A: Download Fresh Data
 
Start a 60-minute `idev` session and navigate to the `data` directory:
 
```bash
idev -m 60
cd <base_path>/<version>/data
```
 
Once the session starts, run the fetch script:
 
```bash
./../code/fetch_databases.sh .
```

### Option B: Symlink to Existing Data
 
If a prior release already has a populated `data` directory **on the same system system**, symlink to it instead of re-downloading:
 
```bash
# Remove the empty data directory created in Step 1
rmdir <base_path>/<new_version>/data
 
# Symlink to the existing data directory
ln -s <base_path>/<old_version>/data <base_path>/<new_version>/data
```
 
**Example** — reusing Lonestar6 `3.0.1` data for `3.0.4`:
 
```bash
rmdir /scratch/tacc/apps/bio/alphafold3/3.0.4/data
ln -s /scratch/tacc/apps/bio/alphafold3/3.0.1/data /scratch/tacc/apps/bio/alphafold3/3.0.4/data
```

---

## Step 4: Pull the Container Image
 
Navigate to the `image` directory. If not already in an idev session, start one. Load Apptainer and pull the appropriate image for the target system:
 
**Vista / Lonestar6:**
 
```bash
cd /scratch/tacc/apps/bio/alphafold3/<version>/image
module load tacc-apptainer
apptainer pull docker://tacc/alphafold3:3.0.4
```
 
> On Vista the multi-arch tag resolves to the aarch64 image; on Lonestar6 it resolves to the x86_64 image.
 
**Frontera:**
 
```bash
cd /scratch2/projects/bio/alphafold3/<version>/image
module load tacc-apptainer
apptainer pull docker://tacc/alphafold3:3.0.4-rtx
```
 
---

## Step 5: Create the Modulefile
 
Create `<base_path>/modulefiles/<version>-ctr.lua`. The modulefile is system-specific — paths and image names differ between systems. Current modulefiles for each system can be found within this repo in the system-specific folders.
 
When updating to a new release, check the release notes on GitHub and determine what options or flags need to be added to the modulefile. 
 
> **Flash attention note:** As of v3.0.2, the default implementation changed from `xla` (v3.0.1) to `triton`. The `AF3_FLASH_ATTN` variable is set to `triton` in the modulefile and can be overridden by the user at runtime. See the [Flash Attention Reference](#flash-attention-reference) table below.
 
> **CPU mode (`AF3_CPU`):** As of v3.0.4, the modulefile runs on GPU by default. Its `run_alphafold3` wrapper checks `AF3_CPU` at runtime: when unset it adds `apptainer --nv`, passes `--jax_backend=gpu`, and defaults flash attention to `triton`; when `AF3_CPU=1` it drops `--nv`, passes `--jax_backend=cpu`, and defaults flash attention to `xla`. Users still override the backend explicitly with `AF3_FLASH_ATTN`.

### Flash Attention Reference
 
| Value | Description |
|-------|-------------|
| `triton` | Tokamax/Triton implementation. Default as of v3.0.4. Recommended for Vista and Lonestar6 |
| `cudnn` | cuDNN implementation. Requires Hopper (H100) GPUs or later |
| `xla` | XLA fallback. Was the default in v3.0.1 and earlier. Recommended for Frontera (RTX) |
 
Override at runtime with `export AF3_FLASH_ATTN=xla` before calling `run_alphafold3`.
 
---

## Step 6: Validate the Installation
 
Run these checks in order after completing the setup. The first check can be run from an idev session on a CPU or GPU node with the module loaded.
 
```bash
# Stage the shared example inputs (from this repo) into $SCRATCH/input
mkdir -p $SCRATCH/input
cp <base_path>/examples/input/*.json $SCRATCH/input/

module use <base_path>/modulefiles
module load alphafold3/3.0.4-ctr
 
export AF3_INPUT_DIR=$SCRATCH/input
export AF3_OUTPUT_DIR=$SCRATCH/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters
```

### Check 1: AlphaFold3 Import Chain

Verifies the AlphaFold3 package is importable inside the container:

```bash
apptainer exec $AF3_IMAGE python3 -c "from alphafold3.common import folding_input; print('OK')"
```

Expected output: 'OK'

### Check 2: MSA-Only Run

Verifies the data pipeline runs without GPU, using `--norun_inference`:

**Lonestar6** — submit to the `normal` queue:
 
```bash
#!/bin/bash
#SBATCH -J msa_test
#SBATCH -o msa_test.%j.out
#SBATCH -e msa_test.%j.err
#SBATCH -p normal
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr

export AF3_INPUT_DIR=$SCRATCH/input/
export AF3_OUTPUT_DIR=$SCRATCH/output/
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/standard_protein.json --norun_inference
```

**Frontera** — submit to the `normal` queue:
 
```bash
#!/bin/bash
#SBATCH -J msa_test
#SBATCH -o msa_test.o%j
#SBATCH -e msa_test.e%j
#SBATCH -p normal
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>

module use /scratch2/projects/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr

export AF3_INPUT_DIR=$SCRATCH/input/
export AF3_OUTPUT_DIR=$SCRATCH/output/
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/standard_protein.json --norun_inference
```

**Vista** — submit to the `gg` queue:
 
```bash
#!/bin/bash
#SBATCH -J msa_test
#SBATCH -o msa_test.%j.out
#SBATCH -e msa_test.%j.err
#SBATCH -p gg
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr

export AF3_INPUT_DIR=$SCRATCH/input/
export AF3_OUTPUT_DIR=$SCRATCH/output/
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/standard_protein.json --norun_inference
```

Expected: job completes and a `<job_name>/` subdirectory containing a `_data.json` file appears in `$AF3_OUTPUT_DIR`.
 
### Check 3: Inference-Only Run

This check must be run on a GPU node. 
Verifies GPU inference using the `_data.json` output from Check 2.
 
**Lonestar6** — submit to the `gpu-a100` queue:
 
```bash
#!/bin/bash
#SBATCH -J inf_test
#SBATCH -o inf_test.%j.out
#SBATCH -e inf_test.%j.err
#SBATCH -p gpu-a100
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr

export AF3_INPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_OUTPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/UQCR11_Hsapiens_data.json --norun_data_pipeline
```

**Frontera** — submit to the `rtx` queue:
 
```bash
#!/bin/bash
#SBATCH -J inf_test
#SBATCH -o inf_test.o%j
#SBATCH -e inf_test.e%j
#SBATCH -p rtx
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>

module use /scratch2/projects/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr

export AF3_INPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_OUTPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/UQCR11_Hsapiens_data.json --norun_data_pipeline
```

**Vista** — submit to the `gh` queue:
 
```bash
#!/bin/bash
#SBATCH -J inf_test
#SBATCH -o inf_test.%j.out
#SBATCH -e inf_test.%j.err
#SBATCH -p gh
#SBATCH -N 1
#SBATCH -t 01:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr

export AF3_INPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_OUTPUT_DIR=$SCRATCH/output/UQCR11_Hsapiens
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters

run_alphafold3 --json_path=$AF3_INPUT_DIR/UQCR11_Hsapiens_data.json --norun_data_pipeline
```

Expected: job completes and structure prediction files (`.cif`, confidence JSON) appear in the output directory.

## Check 4: Full Data Pipeline Via SLURM

Verifies the complete MSA + inference pipeline runs end-to-end as a SLURM batch job on a GPU node.

**Lonestar6** — submit to the `gpu-a100` queue:
 
```bash
#!/bin/bash
#SBATCH -J af3_full_test
#SBATCH -o af3_full_test.o%j
#SBATCH -e af3_full_test.e%j
#SBATCH -p gpu-a100
#SBATCH -N 1
#SBATCH -t 02:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr
 
export AF3_INPUT_DIR=$SCRATCH/input
export AF3_OUTPUT_DIR=$SCRATCH/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters
export AF3_SAVE_DISTOGRAM=1

run_alphafold3 --json_path=$AF3_INPUT_DIR/modified_protein.json
```

**Frontera** — submit to the `rtx` queue:
 
```bash
#!/bin/bash
#SBATCH -J af3_full_test
#SBATCH -o af3_full_test.o%j
#SBATCH -e af3_full_test.e%j
#SBATCH -p rtx
#SBATCH -N 1
#SBATCH -t 02:00:00
#SBATCH -A <your-project>
 
module use /scratch2/projects/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr
 
export AF3_INPUT_DIR=$SCRATCH/af3_test/input
export AF3_OUTPUT_DIR=$SCRATCH/af3_test/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters
export AF3_SAVE_DISTOGRAM=1

run_alphafold3 --json_path=$AF3_INPUT_DIR/modified_protein.json
```

**Vista** — submit to the `gh` queue:
 
```bash
#!/bin/bash
#SBATCH -J af3_full_test
#SBATCH -o af3_full_test.o%j
#SBATCH -e af3_full_test.e%j
#SBATCH -p gh
#SBATCH -N 1
#SBATCH -t 02:00:00
#SBATCH -A <your-project>
 
module use /scratch/tacc/apps/bio/alphafold3/modulefiles
module load alphafold3/3.0.4-ctr
 
export AF3_INPUT_DIR=$SCRATCH/input
export AF3_OUTPUT_DIR=$SCRATCH/output
export AF3_MODEL_PARAMETERS_DIR=$HOME/af3_parameters
export AF3_SAVE_DISTOGRAM=1

run_alphafold3 --json_path=$AF3_INPUT_DIR/modified_protein.json
```

---
