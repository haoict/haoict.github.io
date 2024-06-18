# WSL2 Guide

!!! note "This page is a WIP, check back later for more contents"

## Add USB Drive to WSL

Microsoft has a doccumentation of how to connect USB devices to WSL (https://learn.microsoft.com/en-us/windows/wsl/connect-usb), but it's essentially just passthrough usb bus, we can't mount the usb device yet because the WSL Linux kernel doesn't support USB mass storage. So we have to rebuild WSL Linux kernel, let's get started

### Rebuild the WSL Linux kernel

Go to WSL-Linux-Kernel github releases, download the latest source code (.tar.gz): https://github.com/microsoft/WSL2-Linux-Kernel/releases

From inside a WSL instance, run:
```bash
# First, install build dependencies
sudo apt install build-essential flex bison dwarves libssl-dev libelf-dev

# Download source code
wget https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/linux-msft-wsl-5.15.153.1.tar.gz
tar -zxvf linux-msft-wsl-5.15.153.1.tar.gz
cd WSL2-Linux-Kernel-linux-msft-wsl-5.15.153.1

# Get current kernel config
sudo cp /proc/config.gz .
sudo gunzip config.gz
sudo mv config .config

# update config to add USB Mass Storage support
make menuconfig
# Go to Device Drivers -> USB support -> USB Mass Storage support. Press y to build as built-in [*]
make -j$(nproc)

# Copy the built kernel image to Windows, change the path (/mnt/c/...) wherever you want
cp arch/x86_64/boot/bzImage /mnt/c/Users/Hao/.
```

### Update .wslconfig to use our kernel image

In Windows, go to your home folder (C:\Users\Hao), create a file named `.wslconfig` if not exist

Edit the file, add these line
```
[wsl2]
kernel = C:\\Users\\Hao\\bzImage
```

Note: other `.wslconfig` settings can be found here: https://learn.microsoft.com/en-us/windows/wsl/wsl-config#global-configuration-options-with-wslconfig

Now restart wsl, open powershell and run
```
wsl --shutdown
wsl
```

### Attach the USB drive to WSL
From here, you can follow the MS's documentation above (https://learn.microsoft.com/en-us/windows/wsl/connect-usb)

Basically run:
```bash
# install usbipd
winget install --interactive --exact dorssel.usbipd-win

# list usb
usbipd list

# You will see output like this, in this case, BUSID 2-3 is my connected usb
#Connected:
#BUSID  VID:PID    DEVICE                                                        STATE
#1-1    05ac:8233  NCM Composite Device                                          Not shared
#1-3    05ac:8262  USB Input Device                                              Not shared
#2-3    14cd:1212  USB Mass Storage Device                                       Not shared

# Bind the bus first
usbipd bind --busid 2-3

# Attach to WSL
usbipd attach --wsl --busid 2-3
```

Now inside WSL instance, you can use it, some example commands
```bash
lsusb
lsblk
mount -t ext4 /dev/sdb1 /mnt/usb
```

Once you are done using the device in WSL, you can detach it, run this command inside powershell
```bash
usbipd detach --busid 2-3
```