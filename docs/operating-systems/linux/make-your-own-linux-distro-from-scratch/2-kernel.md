## 2. Compile the kernel:

Clone the Linux kernel source code:

```bash
cd ${WORKDIR}/source

git clone --depth=1 https://github.com/torvalds/linux.git

cd linux
make defconfig
make menuconfig
# Exit then save. The default config is good enough. (but nothing is stopping you from messing around it!)
# NOTE: Fix Black Screen After Grub When Booting in UEFI
# When booting in UEFI, after choosing your OS in grub, your screen might go blank and stay blank. This might indicate a problem in your kernel config
# make menuconfig -> press "/" button to search for config
# Search for "FB_EFI" -> Press "1" (the small number on the left of search result to quickly go to the config) -> Press "y" -> "Esc Esc" -> "1" -> "y"
# Search for "FRAMEBUFFER_CONSOLE" -> Press 1 -> Press "y"

# Some other recommended config to turn on:
# IKCONFIG, IKCONFIG_PROC: read kernel .config through /proc/config.gz
# EFIVAR_FS: mount EFI vars
# OVERLAY_FS, BRIDGE, BRIDGE_NETFILTER, IP_NF_NAT, IP_NF_TARGET_MASQUERADE, VETH, IP_VS, NETFILTER_XT_MATCH_ADDRTYPE, NETFILTER_XT_MATCH_IPVS... (check more in docker section): to enable docker
# HYPERV, HYPERV_KEYBOARD, HYPERV_NET, HYPERV_STORAGE, HYPERV_UTILS, (INPUT_MOUSEDEV, HID_HYPERV_MOUSE if enable GUI)
# Save

# to compile the kernel with all of your cores
make -j $(nproc)

cp arch/x86/boot/bzImage ${WORKDIR}/build/amd64/uefi/boot/
# cp arch/x86/boot/bzImage ${WORKDIR}/build/amd64/bios/boot/
```
The compiled kernel image is copied to a directory named bootfiles.


### Kernel modules
bzImage is the core of the kernel, which will be loaded to the memory from system boot to shutdown. Linux kernel support many features and drivers, you may not want to add them as built-in `[*]`, instead make them modules `[M]`, these can be loaded or unloaded after boot as hot plug when needed
```bash
# Copy compiled modules to a directory
make modules_install INSTALL_MOD_PATH=${WORKDIR}/build/amd64/kernel-modules/
```
