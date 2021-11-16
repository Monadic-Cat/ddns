#!/bin/sh
# This script ensures the mipsel chroot is setup correctly.
# Made to be idempotent, since our use of the mipsel chroot can cause
# spurious reruns via Make checking timestamps on the backing FS image.

if mountpoint -q -- "$OUT/mipsel/" ; then
    # Already mounted. Assume correct setup from there.
    return 0
else
    sudo mount "$OUT/root_fs_mipsel.ext2" "$OUT/mipsel" &&
        sudo mkdir -p "$OUT/mipsel$(pwd)" &&
        sudo mount --bind "$(pwd)" "$OUT/mipsel$(pwd)"
fi
