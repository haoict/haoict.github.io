
## 1. Setting up the environment:

Update the package list and install necessary tools:

```bash
sudo apt update
sudo apt install build-essential git flex bison bc cpio libncurses5-dev libssl-dev libelf-dev

export WORKDIR=/home/${USER}/TiniLinux

mkdir -p ${WORKDIR}/source                        # for linux kernel & busybox source code
mkdir -p ${WORKDIR}/build/amd64/initramfs         # for built kernel & busybox
mkdir -p ${WORKDIR}/build/amd64/uefi/boot/grub    # for making boot iso image
```
