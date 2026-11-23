"""
Convert Oxford Flowers-102 into an ImageFolder-compatible structure for ml-cvnets.

Official splits: train (1020 imgs, 10/class), val (1020 imgs, 10/class), test (6149 imgs).
We combine official train+val as our training set (2040 imgs, 20/class) and use the
official test split as our evaluation set (6149 imgs) -- standard practice for
transfer-learning benchmarks using this dataset, since the official train/val splits
alone are too small to fine-tune on meaningfully.
"""
import os
from torchvision.datasets import Flowers102

RAW_DIR = "project/data/flowers102_raw"
OUT_DIR = "project/data/flowers102"


def save_split(torch_split, out_split):
    ds = Flowers102(root=RAW_DIR, split=torch_split, download=True)
    for idx in range(len(ds)):
        img, label = ds[idx]
        class_dir = os.path.join(OUT_DIR, out_split, f"class_{label:03d}")
        os.makedirs(class_dir, exist_ok=True)
        out_path = os.path.join(class_dir, f"{torch_split}_{idx:05d}.jpg")
        if not os.path.exists(out_path):
            img.save(out_path)
    print(f"{torch_split} -> {out_split}: {len(ds)} images")


if __name__ == "__main__":
    if os.path.isdir(OUT_DIR):
        print(f"{OUT_DIR} already exists, skipping conversion.")
    else:
        save_split("train", "train")
        save_split("val", "train")
        save_split("test", "val")
        print("Conversion complete.")
