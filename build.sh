#!/usr/bin/env bash
set -e

# timezone build
export TZ=Asia/Jakarta
export SOURCE_DATE_EPOCH=$(date +%s)

# kernel version
KERNEL_NAME="UranusKernel"
KERNEL_CODENAME="Uranus ⚜️"
KERNEL_VERSION="$(date +%Y%m%d)"
ZIP_NAME="${KERNEL_NAME}-${KERNEL_VERSION}"
export KERNEL_NAME KERNEL_VERSION ZIP_NAME
[ -n "${GITHUB_ENV}" ] && echo "ZIP_NAME=${ZIP_NAME}" >> "${GITHUB_ENV}"

# build identity
export KBUILD_BUILD_USER=ryuzee
export KBUILD_BUILD_HOST=project

# arch & path
export ARCH=arm64
export SUBARCH=arm64

WORK_DIR=$(pwd)
OUT_DIR=${WORK_DIR}/out
DEFCONFIG=surya_defconfig

# ========== TOOLCHAIN FIX ==========
# AOSP Clang (ARM64)
export PATH=${WORK_DIR}/clang/bin:${PATH}

# ARM32 cross toolchain (gcc + binutils)
export PATH=${WORK_DIR}/gcc32/bin:${PATH}
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# ARM64 cross toolchain prefix (clang will handle)
export CROSS_COMPILE=aarch64-linux-gnu-

export LOCALVERSION="-Uranus"

# backup defconfig
BACKUP_DIR=${WORK_DIR}/defconfig_backup
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
mkdir -p ${BACKUP_DIR}
cp arch/arm64/configs/${DEFCONFIG} ${BACKUP_DIR}/${DEFCONFIG}.${TIMESTAMP}.bak

# compile
mkdir -p ${OUT_DIR}
echo "==> Using ${DEFCONFIG}"
make O=${OUT_DIR} ARCH=arm64 ${DEFCONFIG}

echo "==> Building kernel ${KERNEL_CODENAME}"
make -j$(nproc) O=${OUT_DIR} ARCH=arm64 \
  CC=clang \
  LD=ld.lld \
  AR=llvm-ar \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  STRIP=llvm-strip \
  CROSS_COMPILE=aarch64-linux-gnu- \
  CROSS_COMPILE_ARM32=arm-linux-gnueabi-
  
# validate
BOOT_DIR="${OUT_DIR}/arch/arm64/boot"
IMAGE="${BOOT_DIR}/Image.gz"
DTB_DIR="${BOOT_DIR}/dts/qcom"
DTB_IMG="${BOOT_DIR}/dtb.img"

[ -f "${IMAGE}" ] || { echo "❌ Image.gz missing"; exit 1; }

echo "==> Creating dtb.img"
if ls ${DTB_DIR}/*.dtb 1> /dev/null 2>&1; then
  cat ${DTB_DIR}/*.dtb > ${DTB_IMG}
else
  echo "❌ No DTB files found"; exit 1
fi

[ -f "${DTB_IMG}" ] || { echo "❌ dtb.img failed"; exit 1; }
echo "==> Build finished ${ZIP_NAME}"
ls -lh ${BOOT_DIR}
