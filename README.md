# gke-multicluster-e2m-tf
Terraform sample to provision 2 GKE AP clusters, and enable all required features for a multi-cluster "edge to mesh" deployment.

- Multi-cluster gateway (or multi cluster ingress) for north-south traffic
- ASM (managed control plane) for east-west traffic
- Config sync for automatic apply of all MCG / MCS / ASM config as KRM YAML (update with your repo)

**NOTE:** You should create and save appropriate service account credentials (as `tf-sa.json`) with all requisite permissions.


