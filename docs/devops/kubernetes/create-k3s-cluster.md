# Install k3s cluster

K3s is a ightweight Kubernetes distribution optimized for edge computing, IoT, and resource-constrained environments. Includes additional features like lightweight container runtime, built-in load balancer, and integrated storage solutions. Designed for devices with limited memory and CPU resources.

K0s is more general-purpose and flexible, while K3s is tailored for edge computing and IoT deployments. Your choice depends on your specific use case and resource requirements.

Docs:

* https://docs.k3s.io/quick-start
* https://0to1.nl/post/k3s-kubectl-permission/

Quick way:
```bash
# install control-plane node (with disable traefik and custom token)
curl -sfL https://get.k3s.io | sh -s - --disable=traefik --kube-apiserver-arg service-node-port-range=30000-39999 --token 12345

# install worker nodes (optional)
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.195.151:6443 K3S_TOKEN=12345 sh -s -

# optional: copy kubeconfig to user .kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && chown $USER ~/.kube/config && chmod 600 ~/.kube/config && export KUBECONFIG=~/.kube/config
## You probably want to store that export to your bashrc or bash_profile. After you changed this you can use kubectl in a new terminal.

# optional: taint control-plane node
kubectl taint node k3s-01 node-role.kubernetes.io/control-plane:NoSchedule
```



# Delete cluster
```bash
# Uninstalling Servers
/usr/local/bin/k3s-uninstall.sh

# Uninstalling Agents
/usr/local/bin/k3s-agent-uninstall.sh
```
