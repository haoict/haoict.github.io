# Appendix

## Cross compilation (arm64)

```bash
sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
#make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j 8
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CONFIG_PREFIX=${WORKDIR}/build/arm64/initramfs install

# follow the same steps to create initramfs.cpio.gz
cd ${WORKDIR}/build/arm64/initramfs

sudo chown -R root:root * && find . | cpio -o -H newc | gzip -9 > ${WORKDIR}/build/arm64/uefi/boot/initramfs.cpio.gz && sudo chown -R $USER:$(id -gn) * 

# test
## ref: https://gist.github.com/billti/d904fd6124bf6f10ba2c1e3736f0f0f7
## list cpu: qemu-system-aarch64 -M virt -cpu help
qemu-system-aarch64 -m 2048 -cpu cortex-a72 -smp 4 -M virt -nographic -kernel Image -initrd initramfs.cpio.gz
```

Make the iso and boot?? TBD (I haven't figured out yet, beside a Raspberry Pi which is running well and I don't want to mess with it, I don't have any spare arm64 board)


## Install GUI (X11)
```bash
apk add alpine-conf
# setup mdev: https://wiki.alpinelinux.org/wiki/Mdev
setup-devd udev # or apk add busybox-mdev-openrc

setup-desktop xfce
rc-update del lightdm
rc-status # check openrc

apk add xterm
apk add xf86-video-vmware xf86-video-fbdev xf86-video-vesa

/sbin/openrc sysinit
/sbin/openrc boot

startx # or startxfce4 or xinit xfce4-session
# for gnome: xinit gnome-session
# for mate: xinit mate-session
# for plasma: xinit plasma_session

# extra
apk add open-vm-tools xf86-input-vmmouse
/etc/init.d/open-vm-tools start
startx
```


## All in one command for built & test
```bash
cd ${WORKDIR}/build/amd64/initramfs

sudo chown -R root:root * && find . | cpio -o -H newc | gzip -9 > ${WORKDIR}/build/amd64/uefi/boot/initramfs.cpio.gz && sudo chown -R $USER:$(id -gn) *
grub-mkrescue -o ${WORKDIR}/build/amd64/tinilinux-amd64-uefi.iso ${WORKDIR}/build/amd64/uefi
```
