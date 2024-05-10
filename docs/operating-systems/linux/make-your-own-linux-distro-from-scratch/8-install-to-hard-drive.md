## Install to hard drive

At this stage, everything is basically complete, you have a complete live boot ISO. You may want to install it to hard drive and use as or normal Operating System.

### Make an early boot initramfs
First, we have to have a new fresh early-boot initramfs. This early-boot initramfs is different from live boot initramfs as after installed to hard disk, when you boot, the bootloader will load the kernel and this early-boot initramfs, it will mount the hard drive (the main root filesystem) to /mnt/.root, switch_root to it, and then call /sbin/init again. After that the system will be init from root file system from the hard disk

Boot Loader -> Load Kernel + Load initramfs -> switch_root to rootfs from hard disk

```bash
## Update initramfs for boot from hard drive, from your main PC:
# if not yet have the initramfs-boot
# cd ${WORKDIR}/source/busybox/
# make CONFIG_PREFIX=${WORKDIR}/build/amd64/initramfs-boot install
cd ${WORKDIR}/build/amd64/initramfs-boot
mkdir dev proc sys run

cat <<\EOF > init
#!/bin/sh

ROOT="/mnt/.root"
ROOT_DEV="/dev/sda2"

echo "init from initramfs"

# mount temporary filesystems
mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc     proc     /proc
mount -n -t sysfs    sysfs    /sys
mount -n -t tmpfs    tmpfs    /run

# mount new root
[ -d ${ROOT} ] || mkdir -p ${ROOT}
mount ${ROOT_DEV} ${ROOT}

# switch to new rootfs and exec init
cd ${ROOT}
exec switch_root . "/sbin/init" "$@"
EOF

chmod +x init

# rebuild initramfs
mkdir ../initramfs/boot/
sudo chown -R root:root * && find . | cpio -o -H newc | gzip -9 > ../initramfs/boot/initramfs.cpio.gz && sudo chown -R $USER:$(id -gn) *
cd ${WORKDIR}/build/amd64/initramfs
cp ${WORKDIR}/source/linux/arch/x86/boot/bzImage ${WORKDIR}/build/amd64/initramfs/boot/
cp -r ${WORKDIR}/build/amd64/kernel-modules/lib/modules ${WORKDIR}/build/amd64/initramfs/lib

### Build the iso again and start booting from it, proceed to the next step
cd ${WORKDIR}/build/amd64/initramfs

sudo chown -R root:root * && find . | cpio -o -H newc | gzip -9 > ${WORKDIR}/build/amd64/uefi/boot/initramfs.cpio.gz && sudo chown -R $USER:$(id -gn) *
grub-mkrescue -o ${WORKDIR}/build/amd64/tinilinux-amd64-uefi.iso ${WORKDIR}/build/amd64/uefi
```

### Start installing to hard drive
Now boot using the iso, after booted from the iso:
```bash
apk add --allow-untrusted --no-cache ca-certificates alpine-keys
apk add --no-cache bash wget lsblk cfdisk grub grub-bios grub-efi dosfstools e2fsprogs rsync efibootmgr


cat <<EOF > /etc/group
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:syslog
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:
fax:x:21:
voice:x:22:
cdrom:x:24:
floppy:x:25:
tape:x:26:
sudo:x:27:
audio:x:29:
dip:x:30:
www-data:x:33:
backup:x:34:
operator:x:37:
list:x:38:
irc:x:39:
src:x:40:
gnats:x:41:
shadow:x:42:
utmp:x:43:
video:x:44:
sasl:x:45:
plugdev:x:46:
staff:x:50:
games:x:60:
users:x:100:
nogroup:x:65534:
EOF


# create partition
# /dev/sda1: for boot   (must be vfat or fat32), 100MB is ok
# /dev/sda2: for rootfs (can be ext4), the rest of disk storage
cfdisk
# choose GPT for UEFI or dos for BIOS boot
# type can be default: Linux filesystem
# remember to [Write] all /dev/sda* before [Quit]

mdev -s

# format partition with the correct type
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# mount disk and install grub
mount /dev/sda2 /mnt

## use rsync to copy the entire root filesystem to another location
rsync -aAXv /* /mnt --exclude={/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found}

mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

mount --bind /dev/ /mnt/dev/
mount --bind /proc/ /mnt/proc/
mount --bind /sys/ /mnt/sys/

chroot /mnt

mount -t efivarfs efivarfs /sys/firmware/efi/efivars

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=TiniLinux-UEFI #--bootloader-id=GRUB --no-nvram --removable

# then add this line to /etc/default/grub
cat <<\EOF > /etc/default/grub
GRUB_DISTRIBUTOR="TiniLinux"
GRUB_TIMEOUT=2
GRUB_DISABLE_SUBMENU=y
GRUB_DISABLE_RECOVERY=true
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
EOF


#check disk id: blkid
#/dev/sda2: UUID="4c8d1658-283e-4a07-9ab6-7efd4623e094" TYPE="ext4"
#/dev/sda1: UUID="8CE4-73DF" TYPE="vfat"

# then add this line to /etc/grub.d/40_custom
cat <<\EOF >> /etc/grub.d/40_custom
menuentry "TiniLinux" {
  set root=(hd0,gpt2)
  echo "Loading kernel..."
  linux /boot/bzImage root=/dev/sda2 ro quiet splash
  echo "Loading initramfs..."
  initrd /boot/initramfs.cpio.gz
}
EOF


mv /etc/grub.d/30_uefi-firmware /etc/grub.d/50_uefi-firmware


update-grub

# check grub.cfg for the added menuentry
cat /boot/grub/grub.cfg

exit
umount /mnt/proc /mnt/sys/firmware/efi/efivars /mnt/sys /mnt/dev
mkdir -p /mnt/dev/pts
umount /dev/sda1
umount /dev/sda2
exit
```

Remove live boot CD or USB
Now try boot from hard disk
if it fail, from grub menu press e to edit the entry or press c to enter command line
```
ls
set root=(hd0,gpt2)
linux /boot/bzImage root=/dev/sda2
initrd /boot/initramfs.cpio.gz
boot
```
Now we can boot, after booted, run update-grub again
Done


## Post installation
After installation, you can do these steps to make your OS more Linux-like OS

### rdD
Contrary with rcS, this script will be excecuted when the system shutdown or restart
```bash
# add this line before any ::shutdown lines in /etc/inittab
::shutdown:/etc/rcD

cat <<\EOF >> /etc/rcD
#!/bin/sh
ifdown eth0
EOF
chmod +x /etc/rcD
```

### Enable syslogd
```bash
# Add to /etc/init.d/rcS
syslogd

# Now you can view system log
cat /var/log/messages
```

### Users
Create normal users
```bash
apk add shadow
touch /etc/shadow
chmod 640 /etc/shadow

addgroup haoict
adduser haoict -G haoict

addgroup -g 27 sudo
apk add sudo
vi /etc/sudoers
# uncomment %sudo   ALL=(ALL:ALL) ALL
addgroup haoict sudo

sudo chmod 666 /dev/urandom
sudo chmod 666 /dev/null
sudo chmod -R 777 /tmp
```


### Disable ipv6
```bash
echo 0 > /proc/sys/net/ipv6/conf/all/autoconf
echo 0 > /proc/sys/net/ipv6/conf/all/accept_ra
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
```

### Patch the kernel
Sometimes you may want to add some features or driver modules, you can compile the kernel again and copy it to `/boot/` and `/lib/modules`

```bash
cd ${WORKDIR}/source/linux
make menuconfig
make -j $(nproc)
make modules_install INSTALL_MOD_PATH=${WORKDIR}/build/amd64/kernel-modules/

rsync -lr ${WORKDIR}/build/amd64/kernel-modules/lib/modules root@192.168.1.131:/lib/
scp ${WORKDIR}/source/linux/arch/x86/boot/bzImage root@192.168.1.131:/boot/

# to load kernel module
modprobe <module_name>

# list loadable modules
find /lib/modules/$(uname -r) -type f -name '*.ko' 
cat /lib/modules/$(uname -r)/modules.alias #  (with alias)

# list loaded modules
lsmod
```