# Recursive wildcard function.
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
# Rust source code.
RS_SOURCES=Cargo.toml Cargo.lock .cargo/config.toml rust-toolchain.toml $(call rwildcard,src,*.rs)

.PHONY:
run: ddns
	sudo chroot mipsel $(shell pwd)/ddns

ddns: lmips .mipsel ${RS_SOURCES}
	cargo build
	cp target/mipsel-unknown-linux-uclibc/debug/ddns ddns

lmips: lmips.c
	cc lmips.c -o lmips

# We use an empty file to express readiness of the mipsel chroot.
.mipsel: root_fs_mipsel.ext2
	mkdir -p mipsel
	sh ensure_chroot.sh
	touch .mipsel

# Resize the toolchain FS image so it has room to put stuff in it.
root_fs_mipsel.ext2: root_fs_mipsel.ext2.bz2
	unar root_fs_mipsel.ext2.bz2
	e2fsck -f -p root_fs_mipsel.ext2
	resize2fs root_fs_mipsel.ext2 200M

# Download the cross compiler toolchain root FS image from the uClibc site.
root_fs_mipsel.ext2.bz2:
	curl --remote-name "https://uclibc.org/downloads/old-releases/root_fs_mipsel.ext2.bz2"

# We don't delete the compressed FS image upon cleaning, since
# it never changes, and I'm not confident in that site's availability.
.PHONY:
clean:
	rm -f root_fs_mipsel.ext2
	rm -f lmips

# Cleanup the mipsel chroot as well as the other things.
.PHONY:
clean-sudo: clean
	sudo umount -l mipsel/
	rm .mipsel
