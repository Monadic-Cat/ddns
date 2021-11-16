# This Makefile depends on GNU Make of at least version 3.80, for order-only dependencies.

# Recursive wildcard function.
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
# Rust source code.
RS_SOURCES=Cargo.toml Cargo.lock .cargo/config.toml rust-toolchain.toml $(call rwildcard,src,*.rs)

OUT=build

.PHONY:
run: ddns
	sudo chroot "$(OUT)/mipsel" "$(shell pwd)/$(OUT)/ddns"

ddns: $(OUT)/lmips $(OUT)/.mipsel ${RS_SOURCES}
	OUT="$(OUT)" cargo build
	cp target/mipsel-unknown-linux-uclibc/debug/ddns "$(OUT)/ddns"

$(OUT)/lmips: lmips.c
	cc lmips.c -o "$(OUT)/lmips"

# We use an empty file to express readiness of the mipsel chroot.
$(OUT)/.mipsel: $(OUT)/root_fs_mipsel.ext2 | $(OUT)/mipsel
	OUT="$(OUT)" sh ensure_chroot.sh
	touch "$(OUT)/.mipsel"

# Resize the toolchain FS image so it has room to put stuff in it.
$(OUT)/root_fs_mipsel.ext2: $(OUT)/cache/root_fs_mipsel.ext2.bz2
	unar "$(OUT)/cache/root_fs_mipsel.ext2.bz2" -o "$(OUT)/"
	e2fsck -f -p "$(OUT)/root_fs_mipsel.ext2"
	resize2fs "$(OUT)/root_fs_mipsel.ext2" 200M

# Download the cross compiler toolchain root FS image from the uClibc site.
$(OUT)/cache/root_fs_mipsel.ext2.bz2: | $(OUT)
	cd "$(OUT)/cache" && curl --remote-name "https://uclibc.org/downloads/old-releases/root_fs_mipsel.ext2.bz2"

$(OUT):
	mkdir -p $(OUT)
$(OUT)/cache:
	mkdir -p $(OUT)/cache
$(OUT)/mipsel:
	mkdir -p $(OUT)/mipsel

# We don't delete the compressed FS image upon cleaning, since
# it never changes, and I'm not confident in that site's availability.
.PHONY:
clean:
	rm -f "$(OUT)/root_fs_mipsel.ext2"
	rm -f "$(OUT)/lmips"
	rm -f "$(OUT)/ddns"

# Cleanup the mipsel chroot as well as the other things.
.PHONY:
clean-sudo: clean
	sudo umount -l "$(OUT)/mipsel/"
	rm -f "$(OUT)/.mipsel"
	rm -fd "$(OUT)/mipsel"
