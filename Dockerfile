# Dockerfile: YOLOv8 + OpenImages ortamı (manuel kütüphane kurulumu)

# Base image: CUDA destekli Ubuntu
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Ortamı güncelle ve temel araçları yükle
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    python3-venv \
    wget \
    unzip \
    git \
    nano \
    && apt-get clean

# Pip güncelle
RUN pip3 install --upgrade pip

# Gerekli Python paketlerini kur
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install ultralytics openimages tqdm
RUN pip3 install requests numpy pandas progressbar2 opencv-contrib-python awscli

# Çalışma dizini
WORKDIR /workspace

# OpenImages aracı: GÜNCEL REPO'dan clone
RUN git clone https://github.com/DmitryRyumin/OIDv6.git /workspace/OIDv6_ToolKit

# OIDv6 içinde çalışacak
WORKDIR /workspace/OIDv6_ToolKit

# Starter bash scripti
RUN echo '#!/bin/bash\n\n# Items.txt dosyasını oku ve dataset indir\n\nmkdir -p /workspace/dataset\ncd /workspace/OIDv6_ToolKit\n\nif [ ! -f /workspace/items.txt ]; then\n  echo "items.txt bulunamadı!"\n  exit 1\nfi\n\nwhile read item; do\n  if [ ! -z \"$item\" ]; then\n    python3 main.py downloader --classes \"$item\" --type_csv train --limit 200 --yolo_bbox --dataset_version v6 --folder /workspace/dataset/train\n    python3 main.py downloader --classes \"$item\" --type_csv validation --limit 50 --yolo_bbox --dataset_version v6 --folder /workspace/dataset/val\n  fi\ndone < /workspace/items.txt\n\n# data.yaml dosyası oluştur\necho \"path: /workspace/dataset\" > /workspace/dataset/data.yaml\necho \"train: images/train\" >> /workspace/dataset/data.yaml\necho \"val: images/val\" >> /workspace/dataset/data.yaml\necho \"\" >> /workspace/dataset/data.yaml\necho \"nc: $(wc -l < /workspace/items.txt)\" >> /workspace/dataset/data.yaml\necho \"names: [$(paste -sd, /workspace/items.txt | sed \"s/,/, /g\")]\" >> /workspace/dataset/data.yaml\n\necho \"\\nDataset hazır!\"' > /workspace/start.sh

# Starter scripti çalıştırılabilir yap
RUN chmod +x /workspace/start.sh

# Varsayılan komut
CMD ["/bin/bash"]
