# RFdiffusion Docker Image (CUDA 12.4)

Docker image for RFdiffusion with NVIDIA CUDA 12.4 support, pre-configured with all dependencies and model checkpoints.

## Features

- **Base Image**: NVIDIA CUDA 12.4.0 with cuDNN on Ubuntu 22.04
- **Python Environment**: Conda environment with Python 3.9.17
- **PyTorch**: 2.4.0 with CUDA 12.4 support
- **Pre-installed**: RFdiffusion and SE3Transformer
- **Model Checkpoints**: All 7 RFdiffusion model checkpoints pre-downloaded to `/app/RFdiffusion/models`

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

## Installation

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest
```

### Build Locally

```bash
git clone https://github.com/YOUR_USERNAME/rfdiffusion-docker-cuda12.4.git
cd rfdiffusion-docker-cuda12.4
docker build -t rfdiffusion:latest .
```

## Usage

### Run RFdiffusion Inference (Simple)

The image is configured with an entrypoint that automatically activates the conda environment:

```bash
docker run --gpus all -v $(pwd)/output:/output \
  ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest \
  python scripts/run_inference.py \
  --config-name=base \
  inference.output_prefix=/output/test \
  inference.num_designs=1
```

### Run with Symmetry Config

```bash
docker run --gpus all -v $(pwd)/output:/output \
  ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest \
  python scripts/run_inference.py \
  --config-name=symmetry \
  inference.symmetry="C6" \
  inference.num_designs=1 \
  inference.output_prefix=/output/C6_oligo \
  'contigmap.contigs=[480-480]'
```

### Interactive Shell

```bash
docker run --gpus all -it --entrypoint /bin/bash \
  ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest
```

### Use in Nextflow

```groovy
process RFDIFFUSION_INFERENCE {
    container 'ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest'

    input:
    tuple val(meta), path(model_path)

    output:
    tuple val(meta), path("*.pdb"), emit: structures

    script:
    """
    python scripts/run_inference.py \\
      --config-name=symmetry \\
      inference.model_directory_path=/app/RFdiffusion/models \\
      inference.symmetry="C6" \\
      inference.num_designs=1 \\
      inference.output_prefix="${meta.id}" \\
      'contigmap.contigs=[480-480]' \\
      inference.ckpt_override_path=${model_path}
    """
}
```

### Use with Apptainer/Singularity

```bash
# Pull image
apptainer pull rfdiffusion.sif docker://ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest

# Run inference
apptainer run --nv rfdiffusion.sif \
  python scripts/run_inference.py \
  --config-name=base \
  inference.output_prefix=output/test \
  inference.num_designs=1
```

## Environment Details

- **Conda Environment**: SE3nv
- **RFdiffusion Location**: `/app/RFdiffusion`
- **Models Location**: `/app/RFdiffusion/models`
- **Git Commit**: e22092420281c644b928e64d490044dfca4f9175

## License

This Docker image packages RFdiffusion, which is licensed under its own terms. Please refer to the [RFdiffusion repository](https://github.com/RosettaCommons/RFdiffusion) for license information.

## References

- [RFdiffusion GitHub](https://github.com/RosettaCommons/RFdiffusion)
- [RFdiffusion Paper](https://www.nature.com/articles/s41586-023-06415-8)
