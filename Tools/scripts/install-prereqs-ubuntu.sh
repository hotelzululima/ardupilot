#!/bin/bash
set -e

BASE_PKGS="gawk make git arduino-core curl"
SITL_PKGS="g++"
PX4_PKGS="python-serial python-argparse openocd flex bison libncurses5-dev \
          autoconf texinfo build-essential libftdi-dev libtool zlib1g-dev \
          zip genromfs"
ASSUME_YES=false

function maybe_prompt_user() {
    if $ASSUME_YES; then
        return 0
    else
        read -p "$1"
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    fi
}


OPTIND=1  # Reset in case getopts has been used previously in the shell.
while getopts "y" opt; do
    case "$opt" in
        \?)
            exit 1
            ;;
        y)  ASSUME_YES=true
            ;;
    esac
done

if $ASSUME_YES; then
    APT_GET="sudo apt-get --assume-yes"
else
    APT_GET="sudo apt-get"
fi

$APT_GET update
$APT_GET install $BASE_PKGS $SITL_PKGS $PX4_PKGS

if [ ! -d ../PX4-Firmware ]; then
    git clone https://github.com/diydrones/PX4Firmware.git
fi

if [ ! -d ../PX4NuttX ]; then
    git clone https://github.com/diydrones/PX4NuttX.git
fi

if [ ! -d ~/gcc-arm-none-eabi-4_8-2013-q4-major ]; then
    #ARM_TARBALL=gcc-arm-none-eabi-4_8-2013-q4-major-20120614.tar.bz2
    ARM_TARBALL=gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2
    (
        cd ~;
        #curl -OL "https://launchpad.net/gcc-arm-embedded/4.6/4.8-2013-q4-major/+download/$ARM_TARBALL";

	curl -OL "https://launchpad.net/gcc-arm-embedded/4.8/4.8-2013-q4-major/+download/$ARM_TARBALL";
        tar xjf ${ARM_TARBALL};
        rm ${ARM_TARBALL};
    )
fi
exportline="export PATH=$HOME/gcc-arm-none-eabi-4_8-2013-q4-major/bin:\$PATH";
if ! grep -Fxq "$exportline" ~/.profile ; then
    if maybe_prompt_user "Add $HOME/gcc-arm-none-eabi-4_8-2013-q4-major/bin to your PATH [Y/n]?" ; then
        echo $exportline >> ~/.profile
    else
        echo "Skipping adding $HOME/gcc-arm-none-eabi-4_8-2013-q4-major/bin to PATH."
    fi
fi
