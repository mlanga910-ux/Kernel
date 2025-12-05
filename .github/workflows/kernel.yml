#!/bin/bash
set -euo pipefail
# path to built config (OUT/.config)
CONFIG="$1"
if [ ! -f "$CONFIG" ]; then
  echo "Missing config: $CONFIG"
  exit 1
fi

bad_items=(
CONFIG_BLK_DEV_NVME
CONFIG_SCSI
CONFIG_SCSI_SAS
CONFIG_SCSI_DMA
CONFIG_FB
CONFIG_DRM
)

for i in "${bad_items[@]}"; do
  if grep -E "^$i(=y|=m)" "$CONFIG" >/dev/null; then
    echo "ERROR: forbidden kernel feature enabled: $i"
    exit 2
  fi
done

echo "Config sanitized: OK"
