#!/bin/bash
GPG_KEY="DF9111724E146D6F2D08314A95352E56CAF54985"
OUTPUT_DIR="publish"

script_full_path=$(dirname "$0")
cd "$script_full_path" || exit 1
rm $OUTPUT_DIR/Packages* $OUTPUT_DIR/*Release*
mkdir $OUTPUT_DIR/

echo "[Repository] Generating Packages..."
apt-ftparchive packages ./pool > $OUTPUT_DIR/Packages
zstd -q -c19 Packages > $OUTPUT_DIR/Packages.zst
xz -c9 Packages > $OUTPUT_DIR/Packages.xz
bzip2 -c9 Packages > $OUTPUT_DIR/Packages.bz2
gzip -nc9 Packages > $OUTPUT_DIR/Packages.gz
lzma -c9 Packages > $OUTPUT_DIR/Packages.lzma

echo "[Repository] Generating Release..."
apt-ftparchive \
        -o APT::FTPArchive::Release::Origin="Hekatos" \
        -o APT::FTPArchive::Release::Label="Hekatos" \
        -o APT::FTPArchive::Release::Suite="stable" \
        -o APT::FTPArchive::Release::Version="1.0" \
        -o APT::FTPArchive::Release::Codename="hekatos" \
        -o APT::FTPArchive::Release::Architectures="iphoneos-arm" \
        -o APT::FTPArchive::Release::Components="main" \
        -o APT::FTPArchive::Release::Description="Combatting jailbreak detection, one tweak at a time" \
        release . > $OUTPUT_DIR/Release

echo "[Repository] Signing Release using GPG Key..."
if ! gpg -vabs -u $GPG_KEY -o $OUTPUT_DIR/Release.gpg $OUTPUT_DIR/Release; then
        echo "[Repository] Generated detached signature for Release"
else
        echo "Detached signature signing failed."
fi

if ! gpg --clearsign -u $GPG_KEY -o $OUTPUT_DIR/InRelease $OUTPUT_DIR/Release; then
        echo "[Repository] Generated in-line signature for Release"
else
        echo "In-line signature signing failed."
fi

mv pool "$OUTPUT_DIR"
