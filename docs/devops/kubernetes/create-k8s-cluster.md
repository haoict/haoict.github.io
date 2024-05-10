# Install kubernetes official way

Docs:

* https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
* https://www.webhi.com/how-to/setup-configure-kubernetes-on-ubuntu-debian-and-centos-rhel/
* https://serverfault.com/a/1118760

## Disable swap
Kubernetes performs best when swap is disabled. Disable it with the following commands:

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

the swap patition will be unused, you may want to reclaim it and merge it to the root patition
```bash
# extend disk
sudo cfdisk /dev/sda

# check
lsblk
lsblk --fs
df -h

# resize fs
resize2fs /dev/sda1

# check again
```

## Install containerd (by docker engine)
```bash
# Set up Docker's apt repository. (https://docs.docker.com/engine/install/debian/)
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install containerd.io 
sudo apt-get install containerd.io

# Create containerd configuration
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo nano /etc/containerd/config.toml # set SystemdCgroup = true
sudo systemctl restart containerd
```

## Install Kubernetes Components

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list # for other Kubernetes minor versions, you need to change the Kubernetes minor version in the URL to match your desired minor version
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# fix kubeadm init preflight issues
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# init cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# post initialization
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Configure Pod Network
Select a Pod network add-on and install it. For instance, you can choose to install Calico:
```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```
or Flannel
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
```

## Verify
All should be running now:
```bash
kubectl get pods --all-namespaces
```


## Join worker nodes (if there are)
After step "fix kubeadm init preflight issues", instead of running "kubeadm init", we run:
(this command should be printed out after master node kubeadm init)
```bash
kubeadm join 192.168.195.130:6443 --token $TOKEN --discovery-token-ca-cert-hash $HASH
```

# Delete cluster
```bash
kubeadm reset
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
```