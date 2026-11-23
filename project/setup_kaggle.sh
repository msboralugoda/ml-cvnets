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
PYTHONPATH= /kaggle/working/miniconda/envs/cvnets/bin/pip install --editable .
echo "SETUP COMPLETE"
