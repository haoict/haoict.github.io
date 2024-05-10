## 5. Configuring the bootloader:

### 5.1. Use grub (recommend)

We will use grub-mkrescue to create our bootable ISO. But before doing so, we have to know if our current host is booted with UEFI or BIOS. To do so, check if the folder /sys/firmware/efi exists on your system or not. If it does, your computer uses UEFI otherwise it’s BIOS.

So why knowing this is important? The grub-mkrescue uses the currently installed grub stuff to create the ISO image. This means that if your operating system is booted in BIOS, the chances are that the ISO created from grub-mkrescue does not support UEFI at all. In some cases, UEFI motherboards support booting BIOS images using CMS. But that’s not always the case. If you want to make images for BIOS from UEFI host or vice versa, I suggest you to create a Debian virtual machine in VirtualBox. VirtualBox supports both BIOS and UEFI in it’s motherboard settings. After choosing the appropriate one, install Debian (net install is sufficient) and move the folder which contains boot and grub folders to virtual machine

If you use grub in wsl2: https://github.com/Microsoft/WSL/issues/807#issuecomment-356697269

Create a folder somewhere with any name you want. I name it iso. Then create a folder called boot in it and inside boot create a folder called grub. Then copy bzImage and initramfs.cpio.gz into boot folder.

```bash
sudo apt install xorriso mtools
cd ${WORKDIR}/build/amd64/
```


UEFI
```bash
cat <<EOF > uefi/boot/grub/grub.cfg
set default=0
set timeout=2
# Load EFI video drivers. This device is EFI so keep the video mode while booting the linux kernel.
insmod efi_gop
insmod font
if loadfont /boot/grub/fonts/unicode.pf2
then
  insmod gfxterm
  set gfxmode=auto
  set gfxpayload=keep
  terminal_output gfxterm
fi
menuentry 'TiniLinux' --class os {
  insmod gzio
  insmod part_msdos
  linux /boot/bzImage
  initrd /boot/initramfs.cpio.gz
}
EOF

grub-mkrescue -o tinilinux-amd64-uefi.iso uefi
```


BIOS
```bash
cat <<EOF > bios/boot/grub/grub.cfg
set default=0
set timeout=2
menuentry 'TiniLinux' --class os {
  insmod gzio
  insmod part_msdos
  linux /boot/bzImage
  initrd /boot/initramfs.cpio.gz
}
EOF

grub-mkrescue -o tinilinux-bios-uefi.iso bios/
```

Note: uefi iso can boot with both uefi and bios




### 5.2. Use syslinux
The syslinux package is installed to provide the bootloader.
A blank disk image is created and formatted with a FAT filesystem.
The kernel image and initramfs are copied to the disk image.

```bash
# using syslinux
sudo apt install syslinux dosfstools
dd if=/dev/zero of=boot bs=1M count=50
mkfs -t fat boot
syslinux boot
mkdir m
sudo mount boot m
cp bzImage init.cpio m
umount m
```

Test:
```bash
qemu-system-x86_64 boot
```


### Booting the distro:

The iso file now can be used with VirtualBox or VMWare or burn to USB/CD

From here, the basic steps of making a Linux distro from scatch are complete