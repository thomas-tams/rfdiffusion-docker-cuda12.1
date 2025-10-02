FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Set working directory
WORKDIR /app

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    conda clean -afy

# Copy environment file from GitHub repo context
COPY environment.yml /tmp/environment.yml

# Accept Conda Terms of Service and create conda environment
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda env create -f /tmp/environment.yml && \
    conda clean -afy

# Make RUN commands use the conda environment
SHELL ["conda", "run", "-n", "SE3nv", "/bin/bash", "-c"]

# Install PyTorch with CUDA 12.1 support via pip (better compatibility with driver 550)
RUN pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cu121

# Install DGL with CUDA 12.1 support matching PyTorch 2.3
RUN pip install dgl -f https://data.dgl.ai/wheels/torch-2.3/cu121/repo.html

# Clone RFdiffusion repository
RUN git clone https://github.com/RosettaCommons/RFdiffusion.git /app/RFdiffusion && \
    cd /app/RFdiffusion && \
    git checkout e22092420281c644b928e64d490044dfca4f9175

# Install SE3Transformer
RUN cd /app/RFdiffusion/env/SE3Transformer && \
    python setup.py install

# Install RFdiffusion
RUN cd /app/RFdiffusion && \
    pip install -e .

# Create models directory
RUN mkdir -p /app/RFdiffusion/models

# Download model checkpoints
RUN cd /app/RFdiffusion/models && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/6f5902ac237024bdd0c176cb93063dc4/Base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/e29311f6f1bf1af907f9ef9f44b8328b/Complex_base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/60f09a193fb5e5ccdc4980417708dbab/Complex_Fold_base_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/74f51cfb8b440f50d70878e05361d8f0/InpaintSeq_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/76d00716416567174cdb7ca96e208296/InpaintSeq_Fold_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/5532d2e1f3a4738decd58b19d633b3c3/ActiveSite_ckpt.pt && \
    wget http://files.ipd.uw.edu/pub/RFdiffusion/12fc204edeae5b57713c5ad7dcb97d39/Base_epoch8_ckpt.pt && \
    echo "Downloaded models:" && \
    ls -lh /app/RFdiffusion/models/*.pt

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory to RFdiffusion
WORKDIR /app/RFdiffusion

# Set entrypoint to activate conda environment
ENTRYPOINT ["/entrypoint.sh"]

# Default command runs Python with run_inference.py
CMD ["python", "/app/RFdiffusion/scripts/run_inference.py"]
