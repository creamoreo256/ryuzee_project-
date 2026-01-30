#!/usr/bin/env bash
set -e

ZIP_NAME="$1"
BOT_TOKEN="$2"
CHAT_ID="$3"

DATE=$(date "+%d %B %Y")
TIME=$(date "+%H:%M WIB")

CAPTION=" UranusKernel — Build Success ✅

📱 Device      : surya
🤖 Android     : 13 - 16
📅 Date        : ${DATE}
⏰ Time        : ${TIME}
🛠 Clang       : 21.0.0


#UranusKernel #Uranus #surya #kernel"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument" \
  -F chat_id="${CHAT_ID}" \
  -F document=@"${ZIP_NAME}" \
  -F caption="${CAPTION}"
