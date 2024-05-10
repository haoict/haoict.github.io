## 4. Creating the initial ram filesystem (initramfs):

The find command is used to create a list of files within initramfs, and the cpio command archives them into a compressed image named initramfs.cpio.

```bash
cd ${WORKDIR}/build/amd64/initramfs/
sudo chown -R root:root *
find . | cpio -o -H newc | gzip -9 > ${WORKDIR}/build/amd64/uefi/boot/initramfs.cpio.gz
sudo chown -R $USER:$(id -gn) *
```

Test the built kernel and initramfs
```bash
sudo apt install qemu-system

qemu-system-x86_64 -kernel bzImage -initrd initramfs.cpio.gz
qemu-system-x86_64 -nographic -append console=ttyS0 -kernel bzImage -initrd initramfs.cpio.gz
```
