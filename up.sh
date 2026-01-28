#!/usr/bin/env bash
set -e

ZIP="$1"
BOT_TOKEN="$2"
CHAT_ID="$3"

DATE=$(date '+%d %B %Y')
TIME=$(date '+%H:%M WIB')

CAPTION="🔥 *UranusKernel Build Success*

📱 *Device* : surya
📦 *File* : ${ZIP}
📅 *Date* : ${DATE}
⏰ *Time* : ${TIME}
🔧 *Clang* : AOSP 13289611
⚙️ *CI* : GitHub Actions
👤 *Builder* : ryuzee_project

#UranusKernel #surya #kernel"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument" \
  -F chat_id="${CHAT_ID}" \
  -F document=@"${ZIP}" \
  -F parse_mode=Markdown \
  -F caption="${CAPTION}"
