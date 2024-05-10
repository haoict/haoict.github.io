## Install a package manager (apk)

We will use `apk` ([Alpine package manager](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper)) from Alpine Linux because it's very lightweight and designed to run on RAM (as Alpine Linux)

### Pre-install in the iso file
```bash
cd ${WORKDIR}/build/amd64/initramfs

wget https://gitlab.alpinelinux.org/api/v4/projects/5/packages/generic//v2.14.0/x86_64/apk.static

sudo chroot .

cp /bin/busybox /bin/busybox-bak # backup original busybox as apk add will replace it
cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
EOF
mv apk.static apk
chmod +x apk
mv apk /usr/bin/apk
mkdir -p /lib/apk/db/
mkdir -p /etc/apk/
touch /etc/apk/world
cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/v3.19/main
http://dl-cdn.alpinelinux.org/alpine/v3.19/community
EOF
apk add --allow-untrusted --no-cache ca-certificates alpine-keys
cat <<EOF > /etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/v3.19/main
https://dl-cdn.alpinelinux.org/alpine/v3.19/community
EOF
mv -f /bin/busybox-bak /bin/busybox
rm -rf /lib/apk/exec
rm -rf /lib/apk/db/lock
rm -rf /var/cache/apk/*

exit

sudo rm -rf root/.bash_history
sudo rm -rf root/.hush_history
```

### Use apk
After booted from the iso, we can use apk normally
```bash
apk update

apk add bash wget coreutils
apk add python3
```


### Alpine Linux utilities
Since we're using apk, it comes with a lot of useful utilities thanks to Alpine Linux
```bash
apk add alpine-conf
# https://wiki.alpinelinux.org/wiki/Alpine_setup_scripts

setup-sshd
setup-desktop
```

