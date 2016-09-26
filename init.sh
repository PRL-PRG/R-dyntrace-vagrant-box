#!/bin/sh -x
set -e

SRC="/vagrant/R-dyntrace"
USER="vagrant"
BASHRC="/home/$USER/.bashrc"

# requirements
pkg install -y \
    bash \
    vim-lite \
    autoconf \
    automake \
    libtool \
    gmake \
    gcc \
    git

# usable shell
chsh -s /usr/local/bin/bash vagrant

# checkout and build R
if ! test -d "$SRC"; then
    git clone https://github.com/PRL-PRG/R-dyntrace.git "$SRC"
    cd "$SRC"
    ./configure --without-recommended-packages --disable-java --enable-dtrace
    make
fi

# set environemnt
touch "$BASHRC"
chown $USER:$USER "$BASHRC"
grep R_HOME "$BASHRC" || echo "export R_HOME=$SRC" >> "$BASHRC"
grep LD_LIBRARY_PATH "$BASHRC" || echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\":$SRC/lib" >> "$BASHRC"
