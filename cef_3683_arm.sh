#!/bin/bash
# see also: https://bitbucket.org/chromiumembedded/cef/wiki/MasterBuildQuickStart.md#markdown-header-linux-setup


export BRANCH=3683

mkdir ~/code
mkdir ~/code/automate
mkdir ~/code/chromium_git

sudo apt-get install curl
sudo apt-get install libgtkglext1-dev
sudo apt-get install gcc-arm-linux-gnueabihf
sudo apt-get install g++-multilib-arm-linux-gnueabihf
cd ~/code

curl 'https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT' | base64 -d > install-build-deps.sh
chmod 755 install-build-deps.sh
sudo ./install-build-deps.sh --arm --no-chromeos-fonts --no-nacl

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git -b master
export PATH=~/code/depot_tools:$PATH

cd ~/code/automate
wget https://bitbucket.org/chromiumembedded/cef/raw/master/tools/automate/automate-git.py

cd ~/code
export GYP_GENERATORS=ninja
export GYP_CROSSCOMPILE=1
export GYP_DEFINES="target_arch=arm embedded=1 arm_float_abi=hard component=shared_library"
export GN_DEFINES="use_jumbo_build=true proprietary_codecs=true ffmpeg_branding=Chrome is_debug=false is_official_build=true use_sysroot=true use_allocator=none symbol_level=1 arm_float_abi=hard"
python automate/automate-git.py --force-clean --arm-build --download-dir=chromium_git --depot-tools-dir=depot_tools --no-distrib --build-target=cefsimple --branch=$BRANCH

cd ~/code/chromium_git/chromium/src
./build/linux/sysroot_scripts/install-sysroot.py --arch=arm
curl -s "https://raw.githubusercontent.com/RPi-Distro/chromium-browser/master/debian/checkout-orig-source.mk" | grep "STRIPPED_DIRS " | cut -b 28- | xargs rm -rf

cd ~/code
python automate/automate-git.py --force-clean --arm-build --download-dir=chromium_git --depot-tools-dir=depot_tools --no-distrib --build-target=cefsimple --branch=$BRANCH



cd ~/code/chromium_git/chromium/src
./cef_create_projects.sh



export cef_pack=cef_binary_3.$(BRANCH)_linuxarm_client
mkdir ~/code/$cef_pack
mkdir ~/code/$cef_pack/Release
mkdir ~/code/$cef_pack/Release/locales

cd ~/code/chromium_git/chromium/src/out/Release_GN_arm
cp cef_100_percent.pak ~/code/$cef_pack/Release
cp cef_extensions.pak ~/code/$cef_pack/Release
cp cefsimple ~/code/$cef_pack/Release
cp devtools_resources.pak ~/code/$cef_pack/Release
cp libcef.so ~/code/$cef_pack/Release
cp libGLESv2.so ~/code/$cef_pack/Release
cp natives_blob.bin ~/code/$cef_pack/Release
cp snapshot_blob.bin ~/code/$cef_pack/Release
cp cef_200_percent.pak ~/code/$cef_pack/Release
cp cef.pak ~/code/$cef_pack/Release
cp chrome_sandbox ~/code/$cef_pack/Release
cp icudtl.dat ~/code/$cef_pack/Release
cp libEGL.so ~/code/$cef_pack/Release
cp locales/* ~/code/$cef_pack/Release/locales
cp v8_context_snapshot.bin ~/code/$cef_pack/Release

tar cfvj $cef_pack.tar.bz2 $cef_pack/
zip -r $cef_pack.zip $cef_pack/
