#!/usr/bin/env bash

# Inlined function to post a message
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"
tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$TG_CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="$1"

}
tg_post_build() {
        curl --progress-bar -F document=@"$1" "$BOT_MSG_URL" \
        -F chat_id="$TG_CHAT_ID"  \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3"
}

# Build Info
rel_date="$(date "+%Y%m%d")" # ISO 8601 format
rel_friendly_date="$(date "+%B %-d, %Y")" # "Month day, year" format

# Send a notificaton to TG
tg_post_msg "<b>$LLVM_NAME: Toolchain HosuseKeeping Started</b>%0A<b>Date : </b><code>$rel_friendly_date</code>"

# Setup
git config --global user.name $GH_USERNAME
git config --global user.email $GH_EMAIL
git config --global http.postBuffer 15728640
git config --global init.defaultBranch main

# Housekeeping
git clone anggar96s@git.osdn.net:/gitroot/gengkapak/clang-GengKapak.git -b main rel_repo
name="Clang-GengKapak-17-$rel_date.zip"
cd rel_repo
zip -r9 $name *

# Backup
echo "Upload to OSDN"
rsync -avP -e ssh $name anggar96s@storage.osdn.net:/storage/groups/g/ge/gengkapak/Clang
sleep 10
rm $name

# Push
rm -rf .git
git init .
git add .
git commit -asm "Housekeeping $rel_date build"
git remote add origin anggar96s@git.osdn.net:/gitroot/gengkapak/clang-GengKapak.git
git push --set-upstream origin main -f

# Send a notificaton to TG
tg_post_msg "<b>$LLVM_NAME: Toolchain HosuseKeeping Complete</b>%0A<b>Date : </b><code>$rel_friendly_date</code>"
