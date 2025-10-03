FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-runtime

# Set working directory
WORKDIR /app

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies from environment.yml
RUN pip install --no-cache-dir \
    hydra-core==1.3.2 \
    pyrsistent==0.20.0 \
    e3nn==0.3.3 \
    wandb==0.12.0 \
    pynvml==11.0.0 \
    decorator==5.1.0 \
    opt-einsum==3.4.0 \
    opt-einsum-fx==0.1.4 \
    scipy==1.13.1 \
    pandas>=2.0.0 \
    pydantic>=2.0.0 \
    git+https://github.com/NVIDIA/dllogger#egg=dllogger

# Install DGL with CUDA 12.1 support matching PyTorch 2.3
RUN pip install --no-cache-dir dgl -f https://data.dgl.ai/wheels/torch-2.3/cu121/repo.html

# Clone RFdiffusion repository
RUN git clone https://github.com/RosettaCommons/RFdiffusion.git /app/RFdiffusion && \
    cd /app/RFdiffusion && \
    git checkout e22092420281c644b928e64d490044dfca4f9175

# Install SE3Transformer (using python setup.py install to match original)
RUN cd /app/RFdiffusion/env/SE3Transformer && \
    python setup.py install

# Install RFdiffusion
RUN cd /app/RFdiffusion && \
    pip install --no-cache-dir -e .

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

# Set working directory to RFdiffusion
WORKDIR /app/RFdiffusion

# Default command runs Python with run_inference.py
CMD ["python", "/app/RFdiffusion/scripts/run_inference.py"]
