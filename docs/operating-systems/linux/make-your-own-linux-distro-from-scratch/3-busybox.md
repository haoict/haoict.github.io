## 3. Compile Busybox:

BusyBox combines tiny versions of many common UNIX utilities into a single small executable.

```bash
cd ${WORKDIR}/source

git clone --depth=1 https://git.busybox.net/busybox

cd busybox
make menuconfig
# Now, enter the first sub-menu (Settings). Go down until you reach the section Build options. Select the Build static binary (no shared libs)
# Optional: Go back to main menu. Scroll down until you find the Shells section. Two first options should be Choose which shell is aliased to 'sh' name and Choose which shell is aliased to 'bash' name. Choose each and tell BusyBox to alias sh to Ash and bash to Hush. You might also want to tweak some options but they are not required
# Exit then save
make -j $(nproc)
make CONFIG_PREFIX=${WORKDIR}/build/amd64/initramfs install
```

The built Busybox binaries are installed into the `build/amd64/initramfs` directory.
Now create a init script within initramfs to launch Busybox upon boot:

```bash
cd ${WORKDIR}/build/amd64/initramfs

cat <<EOF > init
#!/bin/sh
/bin/sh
EOF

chmod +x init
```

### 3.1. Advance (advanced init and login)

```bash
cd ${WORKDIR}/build/amd64/initramfs

# create some directories to give it a minimal Linux-like look
mkdir -p {etc,dev,mnt,root,sys,proc,dev,run,tmp,var,home,etc/init.d}

# /etc : We need to fill in a couple of files here

cat <<EOF > etc/inittab
# https://github.com/brgl/busybox/blob/master/examples/inittab
::sysinit:/etc/init.d/rcS

tty1::respawn:/sbin/getty 0 tty1
tty2::respawn:/sbin/getty 0 tty2
tty3::respawn:/sbin/getty 0 tty3
tty4::respawn:/sbin/getty 0 tty4
tty5::respawn:/sbin/getty 0 tty5
tty6::respawn:/sbin/getty 0 tty6

# Enable these ttyS if you want to use serial (qemu -serial stdio)
#ttyS0::respawn:/sbin/getty -L ttyS0 9600 vt100

::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a
EOF


cat <<\EOF > etc/init.d/rcS
#!/bin/sh

mount -t sysfs    sysfs     -o nosuid,noexec,nodev    /sys
mount -t proc     proc      -o nosuid,noexec,nodev    /proc
mount -t devtmpfs devtmpfs  -o nosuid,mode=0755       /dev
mount -t tmpfs    tmpfs     -o nosuid,nodev,mode=755  /run
mkdir -p /dev/pts
mount -t devpts   devpts    -o nosuid,gid=5,mode=620  /dev/pts

mount -a
mdev -s

hostname tinilinux
ip link set lo up
echo 5 > /proc/sys/kernel/printk
syslogd

cat <<!

Boot took $(cut -d' ' -f1 /proc/uptime) seconds

  _____ _       _ _     _                  
 |_   _(_)_ __ (_) |   (_)_ __  _   ___  __
   | | | | '_ \| | |   | | '_ \| | | \ \/ /
   | | | | | | | | |___| | | | | |_| |>  < 
   |_| |_|_| |_|_|_____|_|_| |_|\__,_/_/\_\\
                                           


Welcome to TiniLinux

!
EOF


chmod +x etc/init.d/rcS


cat <<EOF > etc/hostname
tinilinux
EOF


cat <<EOF > etc/passwd
root::0:0:root:/root:/bin/bash
EOF


cat <<EOF > etc/group
root:x:0:root
EOF


cat <<EOF > etc/fstab
# https://www.linuxfromscratch.org/lfs/view/10.0/chapter10/fstab.html
# file system  mount-point  type     options                dump   fsck order

# sysfs          /sys         sysfs    nosuid,noexec,nodev    0      0
# proc           /proc        proc     nosuid,noexec,nodev    0      0
# devtmpfs       /dev         devtmpfs nosuid,mode=0755       0      0
# tmpfs          /run         tmpfs    nosuid,nodev,mode=755  0      0
# devpts         /dev/pts     devpts   nosuid,gid=5,mode=620  0      0

# /dev/sda2      /            ext4     defaults               0      1
# /dev/sda1      /boot/efi    vfat     umask=0077             0      1
EOF


cat <<EOF > init
#!/bin/sh
exec /linuxrc
EOF


chmod +x init
```

### 3.2. Advance (network)

```bash
mkdir -p etc/network/if-up.d
mkdir -p etc/network/if-pre-up.d
mkdir -p etc/network/if-down.d
mkdir -p etc/network/if-post-down.d
mkdir -p var/run
mkdir -p usr/share/udhcpc


cat <<EOF > etc/hosts
127.0.0.1       localhost
127.0.1.1       tinilinux
EOF


cat <<EOF > etc/network/interfaces
# enable dhcp for eth0 interface: https://wiki.alpinelinux.org/wiki/Udhcpc
auto eth0
iface eth0 inet dhcp
  hostname tinilinux
EOF


cat <<\EOF > usr/share/udhcpc/default.script
#!/bin/ash

# https://github.com/mschlenker/TinyCrossLinux/blob/master/patches/usr-share-udhcpc-default.script

PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1

RESOLV_CONF="/etc/resolv.conf"
[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"

case "$1" in
  deconfig)
    ifconfig $interface 0.0.0.0
    ;;

  renew|bound)
    ifconfig $interface $ip $BROADCAST $NETMASK

    if [ -n "$router" ] ; then
      echo "deleting routers"
      while route del default gw 0.0.0.0 dev $interface ; do
        :
      done

      for i in $router ; do
        route add default gw $i dev $interface
      done
    fi

    echo -n > $RESOLV_CONF
    [ -n "$domain" ] && echo search $domain >> $RESOLV_CONF
    for i in $dns ; do
      echo adding dns $i
      echo nameserver $i >> $RESOLV_CONF
    done
    ;;
esac

exit 0
EOF


chmod +x usr/share/udhcpc/default.script

# add line "ifup eth0" after "ip link set lo up":
sed -i 's/ip link set lo up/ip link set lo up\nifup eth0/g' etc/init.d/rcS
```


### 3.3. SSH (dropbear)

Build dropbear binary from source
```bash
cd ${WORKDIR}/source
git clone --depth=1 https://github.com/mkj/dropbear.git
cd dropbear
./configure --enable-static
cp src/default_options.h localoptions.h # update options if you want
make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" MULTI=1 STATIC=1 strip
```

Copy dropbear binary to initramfs
```bash
cp ${WORKDIR}/source/dropbear/dropbearmulti ${WORKDIR}/build/amd64/initramfs/usr/bin/
cd ${WORKDIR}/build/amd64/initramfs/usr/bin/
ln -s dropbearmulti scp
ln -s dropbearmulti dropbearkey
ln -s dropbearmulti dropbearconvert
ln -s dropbearmulti dropbear
ln -s dropbearmulti ssh
ln -s dropbearmulti dbclien

cd ${WORKDIR}/build/amd64/initramfs/
mkdir -p {var/log,etc/default,etc/dropbear}
touch var/log/lastlog

cat <<EOF > etc/shells
/bin/bash
/bin/sh
EOF
```


After boot, start dropbear with
```bash
dropbear -EBR # log error on std error, allow blank password, create hostkey if required
```

or add to rcS
```bash
sed -i 's/ifup eth0/ifup eth0 && dropbear -RB/g' etc/init.d/rcS
```


### 3.4. curl

I prefer curl over wget, so if you want to use curl
```bash
# check version and arch here: https://github.com/stunnel/static-curl/releases
curl -LO https://github.com/stunnel/static-curl/releases/download/8.6.0-1/curl-linux-x86_64-8.6.0.tar.xz
tar -xvf curl-linux-x86_64-8.6.0.tar.xz
rm curl-linux-x86_64-8.6.0.tar.xz

# you may want to compress the binary: $ upx --brute curl

mv curl usr/bin
```
