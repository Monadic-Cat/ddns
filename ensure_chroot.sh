#!/bin/sh
# This script ensures the mipsel chroot is setup correctly.
# Made to be idempotent, since our use of the mipsel chroot can cause
# spurious reruns via Make checking timestamps on the backing FS image.

if mountpoint -q -- mipsel/ ; then
    # Already mounted. Assume correct setup from there.
    return 0
else
    sudo mount root_fs_mipsel.ext2 mipsel &&
        sudo mkdir -p "mipsel$(pwd)" &&
        sudo mount --bind "$(pwd)" "mipsel$(pwd)"
fi
