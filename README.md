# RFdiffusion Docker Image (CUDA 12.1)

Optimized Docker image for RFdiffusion with NVIDIA CUDA 12.1 support, pre-configured with all dependencies and model checkpoints.

## Features

- **Base Image**: PyTorch 2.3.1 with CUDA 12.1 and cuDNN 8 (runtime)
- **No Conda**: Pure pip-based installation for smaller image size and better GPU compatibility
- **PyTorch**: 2.3.1 with CUDA 12.1 support (pre-installed with torchvision and torchaudio)
- **Pre-installed**: RFdiffusion and SE3Transformer
- **Model Checkpoints**: All 7 RFdiffusion model checkpoints pre-downloaded to `/app/RFdiffusion/models`
- **GPU Verified**: Tested with NVIDIA Driver 550.163.01 and RTX 4060 Laptop GPU

## Models Included

- Base_ckpt.pt
- Complex_base_ckpt.pt
- Complex_Fold_base_ckpt.pt
- InpaintSeq_ckpt.pt
- InpaintSeq_Fold_ckpt.pt
- ActiveSite_ckpt.pt
- Base_epoch8_ckpt.pt

## Requirements

- Docker with NVIDIA GPU support
- NVIDIA Container Toolkit installed on host
- NVIDIA GPU with CUDA capability
- NVIDIA Driver version 450.80.02 or higher (tested with 550.163.01)

## Installation

### Pull Pre-built Image

#### Using Docker

```bash
docker pull ghcr.io/thomas-tams/rfdiffusion-docker-cuda12.1:latest
```

#### Using Apptainer/Singularity

```bash
apptainer pull docker://ghcr.io/thomas-tams/rfdiffusion-docker-cuda12.1:latest
```

### Build Locally

```bash
git clone https://github.com/thomas-tams/rfdiffusion-docker-cuda12.1.git
cd rfdiffusion-docker-cuda12.1
docker build -t rfdiffusion-optimized .
```

### Test CUDA Availability

```bash
docker run --rm --gpus all ghcr.io/thomas-tams/rfdiffusion-docker-cuda12.1:latest python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

## Usage

### Run RFdiffusion Inference (Simple)

```bash
docker run --gpus all \
  -v $(pwd)/output:/app/output \
  rfdiffusion-optimized \
  python /app/RFdiffusion/scripts/run_inference.py \
    inference.output_prefix=/app/output/test \
    inference.num_designs=1 \
    'contigmap.contigs=[10-40]'
```

### Run with Symmetry Config

```bash
docker run --gpus all \
  -v $(pwd)/output:/app/output \
  rfdiffusion-optimized \
  python /app/RFdiffusion/scripts/run_inference.py \
    --config-name=symmetry \
    inference.symmetry="D2" \
    inference.num_designs=1 \
    inference.output_prefix=/app/output/D2_oligo \
    'potentials.guiding_potentials=["type:olig_contacts,weight_intra:1,weight_inter:0.1"]' \
    potentials.olig_intra_all=True \
    potentials.olig_inter_all=True \
    potentials.guide_scale=2.0 \
    potentials.guide_decay=quadratic \
    'contigmap.contigs=[320-320]'
```

### Using External Model Directory

If you have models stored locally, mount them:

```bash
docker run --gpus all \
  -v /path/to/models:/app/RFdiffusion/models \
  -v $(pwd)/output:/app/output \
  rfdiffusion-optimized \
  python /app/RFdiffusion/scripts/run_inference.py \
    inference.output_prefix=/app/output/test \
    inference.num_designs=1 \
    'contigmap.contigs=[10-40]'
```

### Interactive Shell

```bash
docker run --gpus all -it \
  --entrypoint /bin/bash \
  rfdiffusion-optimized
```

### Use in Nextflow

```groovy
process RFDIFFUSION_INFERENCE {
    container 'rfdiffusion-optimized:latest'
    containerOptions '--gpus all'

    input:
    tuple val(meta), path(input_pdb)

    output:
    tuple val(meta), path("*.pdb"), emit: structures
    tuple val(meta), path("*.trb"), emit: trajectories

    script:
    """
    python /app/RFdiffusion/scripts/run_inference.py \\
      --config-name=symmetry \\
      inference.input_pdb=${input_pdb} \\
      inference.symmetry="C6" \\
      inference.num_designs=10 \\
      inference.output_prefix="${meta.id}" \\
      'contigmap.contigs=[480-480]'
    """
}
```

### Use with Apptainer/Singularity

```bash
# Pull pre-built image
apptainer pull rfdiffusion.sif docker://ghcr.io/thomas-tams/rfdiffusion-docker-cuda12.1:latest

# Or build from local Docker image
apptainer build rfdiffusion.sif docker-daemon://rfdiffusion-optimized:latest

# Run inference
apptainer run --nv rfdiffusion.sif \
  python /app/RFdiffusion/scripts/run_inference.py \
  inference.output_prefix=output/test \
  inference.num_designs=1 \
  'contigmap.contigs=[10-40]'
```

## Environment Details

- **Python Version**: 3.10 (from PyTorch base image)
- **RFdiffusion Location**: `/app/RFdiffusion`
- **Models Location**: `/app/RFdiffusion/models`
- **Git Commit**: e22092420281c644b928e64d490044dfca4f9175
- **Working Directory**: `/app/RFdiffusion`

## Troubleshooting

### CUDA Unknown Error

If you encounter "CUDA unknown error" when running the container:

1. **Reboot your system** - GPU state issues from suspend/resume can cause this
2. **Enable persistence mode**: `sudo nvidia-smi -pm 1`
3. **Verify GPU is accessible**: `docker run --rm --gpus all nvidia/cuda:12.1.0-runtime-ubuntu22.04 nvidia-smi`

### GPU Not Detected

Ensure NVIDIA Container Toolkit is properly installed:

```bash
# Install NVIDIA Container Toolkit (Ubuntu/Debian)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

## Architecture Improvements

This optimized version provides several improvements over conda-based approaches:

- **Smaller Image Size**: Uses runtime base image instead of devel, no conda overhead
- **Better GPU Compatibility**: No LD_LIBRARY_PATH conflicts between conda and NVIDIA runtime
- **Faster Builds**: PyTorch pre-installed, no conda environment creation
- **Simpler Maintenance**: Pure pip dependencies, standard Python packaging

## License

This Docker image packages RFdiffusion, which is licensed under its own terms. Please refer to the [RFdiffusion repository](https://github.com/RosettaCommons/RFdiffusion) for license information.

## References

- [RFdiffusion GitHub](https://github.com/RosettaCommons/RFdiffusion)
- [RFdiffusion Paper](https://www.nature.com/articles/s41586-023-06415-8)
- [PyTorch Docker Hub](https://hub.docker.com/r/pytorch/pytorch)
