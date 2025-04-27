# Dockerfile: YOLOv8 + OpenImages Dataset icin ortam

# Base image: CUDA destekli Ubuntu
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Ortami guncelle
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    python3-venv \
    wget \
    unzip \
    git \
    nano \
    && apt-get clean

# Pip guncelle
RUN pip3 install --upgrade pip

# Gerekli Python paketlerini kur
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install ultralytics openimages pandas tqdm

# Calisma dizini
WORKDIR /workspace

# OpenImages main.py (veya gerekli toolkit) icin klasor yarat
RUN git clone https://github.com/EscVM/OIDv6_ToolKit.git /workspace/OIDv6_ToolKit

# Gerekirse eksik pip paketlerini kur (OpenImages icin lazim olabilir)
RUN pip3 install opencv-python pillow

# OIDv6 icinde calisacak
WORKDIR /workspace/OIDv6_ToolKit

# Starter bash scripti
RUN echo '#!/bin/bash\n\n# Items.txt dosyasini oku ve dataset indir\n\nmkdir -p /workspace/dataset\ncd /workspace/OIDv6_ToolKit\n\nif [ ! -f /workspace/items.txt ]; then\n  echo "items.txt bulunamadi!"\n  exit 1\nfi\n\nwhile read item; do\n  if [ ! -z "$item" ]; then\n    python3 main.py downloader --classes "$item" --type_csv train --limit 200 --yolo_bbox --dataset_version v6 --folder /workspace/dataset/train\n    python3 main.py downloader --classes "$item" --type_csv validation --limit 50 --yolo_bbox --dataset_version v6 --folder /workspace/dataset/val\n  fi\ndone < /workspace/items.txt\n\n# data.yaml dosyasi olustur\necho "path: /workspace/dataset" > /workspace/dataset/data.yaml\necho "train: images/train" >> /workspace/dataset/data.yaml\necho "val: images/val" >> /workspace/dataset/data.yaml\necho "" >> /workspace/dataset/data.yaml\necho "nc: $(wc -l < /workspace/items.txt)" >> /workspace/dataset/data.yaml\necho "names: [$(paste -sd, /workspace/items.txt | sed "s/,/, /g")]" >> /workspace/dataset/data.yaml\n\necho "\nDataset hazir!"' > /workspace/start.sh

# Starter scripti calistirilabilir yap
RUN chmod +x /workspace/start.sh

# Varsayilan komut
CMD ["/bin/bash"]