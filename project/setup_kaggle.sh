#!/bin/bash
set -e
cd /kaggle/working

if [ ! -d "ml-cvnets" ]; then
    git clone https://github.com/msboralugoda/ml-cvnets.git
fi
cd ml-cvnets

grep -q '^#av$' requirements.txt || sed -i '/^av$/s/^/#/' requirements.txt
grep -q '^#pytorchvideo' requirements.txt || sed -i '/^pytorchvideo/s/^/#/' requirements.txt

if [ ! -d "/kaggle/working/miniconda" ]; then
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /kaggle/working/miniconda.sh
    bash /kaggle/working/miniconda.sh -b -p /kaggle/working/miniconda
    /kaggle/working/miniconda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
    /kaggle/working/miniconda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
fi

if [ ! -d "/kaggle/working/miniconda/envs/cvnets" ]; then
    /kaggle/working/miniconda/bin/conda create -n cvnets python=3.10.8 -y
fi

PYTHONPATH= /kaggle/working/miniconda/envs/cvnets/bin/pip install -r requirements.txt -c constraints.txt
PYTHONPATH= /kaggle/working/miniconda/envs/cvnets/bin/pip install av
PYTHONPATH= /kaggle/working/miniconda/envs/cvnets/bin/pip install --editable .

if [ ! -f "project/checkpoints/mobilevit_xs.pt" ]; then
    mkdir -p project/checkpoints
    wget -q https://docs-assets.developer.apple.com/ml-research/models/cvnets/classification/mobilevit_xs.pt -O project/checkpoints/mobilevit_xs.pt
fi

if [ ! -f "project/configs/mobilevit_xs_imagenet.yaml" ]; then
    mkdir -p project/configs
    wget -q https://docs-assets.developer.apple.com/ml-research/models/cvnets/classification/mobilevit_xs.yaml -O project/configs/mobilevit_xs_imagenet.yaml
fi

if [ ! -f "project/checkpoints/mobilevit_xs_no_head.pt" ]; then
    PYTHONPATH= /kaggle/working/miniconda/envs/cvnets/bin/python -c "
import torch
ckpt = torch.load('project/checkpoints/mobilevit_xs.pt', map_location='cpu')
for k in ['classifier.fc.weight', 'classifier.fc.bias']:
    ckpt.pop(k, None)
torch.save(ckpt, 'project/checkpoints/mobilevit_xs_no_head.pt')
"
fi

if [ ! -d "project/data/flowers102" ]; then
    PYTHONPATH= /kaggle/working/miniconda/envs/cvnets/bin/python project/scripts/prepare_flowers102.py
fi

echo "SETUP COMPLETE"
