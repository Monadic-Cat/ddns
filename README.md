# DDNS
Going to be a hacky program for doing dynamic DNS with Cloudflare's API,
on my home router, which is an old MIPS machine.

Initial work is just on getting Rust working on it.

# External Dependencies Downloaded
- https://uclibc.org/downloads/old-releases/root_fs_mipsel.ext2.bz2

# Dirty Hacks
## Bind Mount Inside `mipsel` Chroot
I created a bind mount with a matching path to the project directory
from my real root, inside the `mipsel` chroot, to the project directory,
so we can feed linker commands into the chroot's `gcc` without fixing argument paths.
```
sudo mkdir -p mipsel/path/to/project/ddns
sudo mount --bind /path/to/project/ddns mipsel/path/to/project/ddns
```

This leads to needing to enter your `sudo` password at the link step. Do that.

## Linker Flag Fix-up
I wrote a little C wrapper (`lmips.c`) to perform the `chroot` invocation and replace `-lutil`
in the linker flags with `-lc`, since the Rust tooling tries to link against a library
called `libutil.so` whose functions are part of `libc.so` on the target system.
(i.e., at least `puts` and `exit` are in there.)

This wrapper is itself wrapped by a shell program that performs the `sudo` invocation
necessary for using `chroot`.
