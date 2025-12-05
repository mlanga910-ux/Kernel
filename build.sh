#!/bin/bash
set -euo pipefail

# env
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
OUT=$(pwd)/kernel/out

# 1) enter kernel dir (CI clone places kernels into ./kernel)
cd kernel || { echo "kernel dir missing"; exit 1; }

echo ">>> Loading device defconfig (angelican/dandelion)"
# many Xiaomi kernels have target defconfig names; attempt common names
make O=$OUT ARCH=arm64 angelican_defconfig || make O=$OUT ARCH=arm64 dandelion_defconfig || make O=$OUT ARCH=arm64 defconfig

echo ">>> Append user patch"
# copy back to repo root location for record
cat ../patches/extra_config.patch >> $OUT/.config

echo ">>> Finalize config"
make O=$OUT ARCH=arm64 olddefconfig

echo ">>> Building kernel (only Image.gz)"
make -j$(nproc) O=$OUT ARCH=arm64 Image.gz

# sanity check
if [ ! -f "$OUT/arch/arm64/boot/Image.gz" ]; then
  echo "Image.gz not found — build failed"
  exit 1
fi

echo ">>> Copying to anykernel"
cp $OUT/arch/arm64/boot/Image.gz ../anykernel/Image.gz

cd ../anykernel
# Prepare a small metadata for AnyKernel3
cat > updater-script <<'UP'
# Placeholder — AnyKernel3 will use Image.gz placed in root
UP

zip -r9 AngelicanKernel.zip * -x .git || true
mv AngelicanKernel.zip ../AngelicanKernel.zip

echo ">>> Done. Artifact: AngelicanKernel.zip"
