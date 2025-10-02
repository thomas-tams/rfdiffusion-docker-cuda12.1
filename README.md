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

### Interactive Shell

```bash
docker run --gpus all -it ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest
```

### Run RFdiffusion Inference

```bash
docker run --gpus all -v $(pwd)/output:/output \
  ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest \
  conda run --no-capture-output -n SE3nv python /app/RFdiffusion/scripts/run_inference.py \
  --config-name=base \
  inference.output_prefix=/output/test \
  inference.num_designs=1
```

### Use in Nextflow

```groovy
process RFDIFFUSION {
    container 'ghcr.io/YOUR_USERNAME/rfdiffusion-docker-cuda12.4:latest'

    input:
    // your inputs

    script:
    """
    python /app/RFdiffusion/scripts/run_inference.py \\
      --config-name=base \\
      inference.output_prefix=output \\
      inference.num_designs=1
    """
}
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
