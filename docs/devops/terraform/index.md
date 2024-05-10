# Install Terraform

Docs:

https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

## Destroy Terraform
```bash
terraform destroy

# remove stuck resources
NS=`kubectl get ns |grep Terminating | awk 'NR==1 {print $1}'` && kubectl get namespace "$NS" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
```

!!! note "This page is a WIP, check back later for more contents"