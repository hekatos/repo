#!/bin/bash
script_full_path=$(dirname "$0")
cd "$script_full_path" || exit 1
rm Packages Packages.bz2 Packages.xz Packages.zst Release Release.gpg

echo "[Repository] Generating Packages..."
apt-ftparchive packages ./pool > Packages
zstd -q -c19 Packages > Packages.zst
xz -c9 Packages > Packages.xz
bzip2 -c9 Packages > Packages.bz2

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
        release . > Release

echo "[Repository] Signing Release using GPG Key..."
gpg -abs -u DF9111724E146D6F2D08314A95352E56CAF54985 -o Release.gpg Release

echo "[Repository] Finished"
