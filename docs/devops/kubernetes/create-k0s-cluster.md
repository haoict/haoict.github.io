# Install k0s cluster

K0s is a simple, standalone Kubernetes distribution focused on minimalism and flexibility. Provides essential Kubernetes components with a pluggable architecture. Suitable for development, testing, and production use cases.

K0s is more general-purpose and flexible, while K3s is tailored for edge computing and IoT deployments. Your choice depends on your specific use case and resource requirements.

```bash
sudo su -
curl -sSLf https://get.k0s.sh | sudo sh
sudo mkdir -p /etc/k0s
sudo k0s config create | sudo tee /etc/k0s/k0s.yaml
sudo nano /etc/k0s/k0s.yaml
--> Add externalAddress: https://docs.k0sproject.io/head/configuration/ (normally it should be the same with server's public IP)
sudo k0s install controller -c /etc/k0s/k0s.yaml --enable-worker
sudo k0s start
sudo k0s status
```

### Troubleshooting if errors
```bash
sudo nano /etc/systemd/system/k0scontroller.service
sudo systemctl daemon-reload
sudo systemctl status k0scontroller.service
sudo journalctl thô-u k0scontroller --follow
```

## Access cluster
### from k0s server
```bash
sudo k0s kubectl get nodes
```

### from local pc
```bash
# Get admin.conf from k0s server first
mkdir -p ${HOME}/.k0s
sudo cat /var/lib/k0s/pki/admin.conf


# From your local PC
nano ~/.k0s/kubeconfig
--> Paste the content of admin.conf

export KUBECONFIG="${HOME}/.k0s/kubeconfig"
kubectl get pods --all-namespaces
```

## Uninstall

```bash
sudo k0s stop
sudo k0s reset
## Clean up
sudo systemctl disable k0scontroller.service
sudo rm /etc/systemd/system/k0scontroller.service
sudo systemctl daemon-reload
```