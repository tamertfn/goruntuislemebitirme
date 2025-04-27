# Open Images Dataset'ten otomatik veri indirip YOLOv8 icin hazirlayan script

# Gerekli kutuphaneler
# pip install openimages pandas tqdm

import os
import subprocess
import pandas as pd
from tqdm import tqdm

# 1. Ayarlar
items_file = 'items.txt'  # Nesne isimlerinin oldugu dosya
output_dir = 'smartdesk_dataset'  # Dataset cikis klasoru
train_count = 200  # Her class icin indirilecek egitim resim sayisi
val_count = 50     # Her class icin indirilecek dogrulama resim sayisi

# 2. Klasorleri olustur
os.makedirs(output_dir, exist_ok=True)
os.makedirs(os.path.join(output_dir, 'images/train'), exist_ok=True)
os.makedirs(os.path.join(output_dir, 'images/val'), exist_ok=True)
os.makedirs(os.path.join(output_dir, 'labels/train'), exist_ok=True)
os.makedirs(os.path.join(output_dir, 'labels/val'), exist_ok=True)

# 3. Items.txt dosyasini oku
with open(items_file, 'r') as f:
    classes = [line.strip() for line in f.readlines() if line.strip()]

print(f"Toplam {len(classes)} sinif bulunuyor.")

# 4. Veri indirme fonksiyonu (Open Images Toolkit kullaniyor)
def download_openimages(class_name, image_count, split='train'):
    cmd = [
        'python3', 'main.py', 'downloader',
        '--classes', f'"{class_name}"',
        '--type_csv', split,
        '--limit', str(image_count),
        '--yolo_bbox',
        '--dataset_version', 'v6',
        '--no_labels',
        '--folder', os.path.join(output_dir, split)
    ]
    try:
        subprocess.run(' '.join(cmd), shell=True, check=True)
    except subprocess.CalledProcessError:
        print(f"{class_name} icin veri indirilemedi!")

# 5. Verileri indir
for cls in tqdm(classes, desc="Siniflar indiriliyor"):
    download_openimages(cls, train_count, split='train')
    download_openimages(cls, val_count, split='validation')

# 6. Data.yaml dosyasini olustur
data_yaml = f"""
path: {output_dir}
train: images/train
val: images/val

nc: {len(classes)}
names: {classes}
"""

with open(os.path.join(output_dir, 'data.yaml'), 'w') as f:
    f.write(data_yaml)

print("\nDataset hazirlandi! smartdesk_dataset klasoru altinda.")
print("Egitime baslayabilirsin!")
