# Install Kind

!!! note "This page is a WIP, check back later for more contents"

There are quite a few ways to get Kubernetes up and running on your machine. On Rancher Desktop, you simply click a Kubernetes checkbox in the settings. With a WSL2 backend this is pretty good, except you need a special distro running just for Kubernetes. It's also not compatible with ARM. Without using Rancher Desktop, we'll be looking for a Linux solution, some come to mind, including:

* minikube
* microk8s (requires snap, which is a bit of a pain on WSL2)
* k3s (does some things on the OS level which are not ideal)
* k3d
* kind

kind is my favourite because of how isolated it is inside docker, which makes it very easy to get going, and just as easy to remove. k3d is very similar, but not a certified distribution, so you'll probably have higher chance of success with kind.

https://www.guide2wsl.com/kubernetes/
https://kind.sigs.k8s.io/docs/user/quick-start/

```bash
kind create cluster --config cluster.yaml
kind delete cluster
```


```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
  - containerPort: 443
    hostPort: 8443
# - role: worker
```