## Install docker

### Check kernel config
In order to run docker, some kernel modules needs to be enabled. If you already enabled them, skip this part
```
# script to check kernel config for docker support (note: enable CONFIG_IKCONFIG + CONFIG_IKCONFIG_PROC from kernel make menuconfig first)
# wget https://github.com/moby/moby/raw/master/contrib/check-config.sh
# chmod +x check-config.sh
# ./check-config.sh
```

### Install by package manager (apk)
```bash
mkdir -p /lib/modules

apk add docker iptables-legacy
rm /sbin/iptables
cp /sbin/iptables-legacy /sbin/iptables
rm /sbin/iptables-save
cp /sbin/iptables-legacy-save /sbin/iptables-save
rm /sbin/iptables-restore
cp /sbin/iptables-legacy-restore /sbin/iptables-restore
```

### Or: Install by binary
TODO: add guide to install iptables 
```bash
wget https://download.docker.com/linux/static/stable/x86_64/docker-26.0.0.tgz
tar xzvf docker-26.0.0.tgz
cp docker/* /usr/bin/
```

### Use docker
Before running dockerd, cgroupfs needs to be mounted
```bash
# copy the cgroup2-mount.sh from hack/docker
wget https://gist.githubusercontent.com/haoict/770e65bb718ddac6d10cbd7e0d39fcf7/raw/7d40ced18bb202cf82f25765547581224c5d609d/cgroup2-mount.sh
chmod +x cgroup2-mount.sh
./cgroup2-mount.sh
```

Start dockerd
```bash
DOCKER_RAMDISK=true dockerd & #(if run with live boot) OR
dockerd & #(if installed to hard disk)
```

Now you can use docker normally
```bash
docker run -d --rm -p 8000:8000 haoict/hello-world
```