#!/usr/bin/env bash
set -e

# ================= TIME =================
export TZ=Asia/Jakarta
export SOURCE_DATE_EPOCH=$(date +%s)

# ================= IDENTITY =================
export KBUILD_BUILD_USER=ryuzee
export KBUILD_BUILD_HOST=project
export KBUILD_BUILD_VERSION=1
export KBUILD_BUILD_TIMESTAMP="$(date '+%a %b %d %T %Z %Y')"

# ================= ARCH =================
export ARCH=arm64
export SUBARCH=arm64

WORK_DIR=$(pwd)
OUT_DIR=${WORK_DIR}/out
DEFCONFIG=surya_defconfig

# ================= TOOLCHAIN =================
export PATH=${WORK_DIR}/clang/bin:${PATH}
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# ================= LOCALVERSION =================
export LOCALVERSION=""

# ================= BUILD =================
mkdir -p ${OUT_DIR}

echo "==> Using ${DEFCONFIG}"
make O=${OUT_DIR} ${DEFCONFIG}

echo "==> Building kernel"
make -j$(nproc) O=${OUT_DIR} \
  CC=clang \
  LD=ld.lld \
  AR=llvm-ar \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  STRIP=llvm-strip \
  CROSS_COMPILE=${CROSS_COMPILE} \
  CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32}

# ================= OUTPUT =================
BOOT_DIR=${OUT_DIR}/arch/arm64/boot

[ -f ${BOOT_DIR}/Image.gz ] || { echo "❌ Image.gz missing"; exit 1; }

cat ${BOOT_DIR}/dts/qcom/*.dtb > ${BOOT_DIR}/dtb.img

echo "==> Build finished"
ls -lh ${BOOT_DIR}
