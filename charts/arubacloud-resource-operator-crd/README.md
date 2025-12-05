# arubacloud-resource-operator-crd

A Helm chart to install Custom Resource Definitions (CRDs) for the Aruba Cloud Resource Operator.

## Features
- Installs all required CRDs for Aruba Cloud resource management
- Infrastructure resource definitions (CloudServer, BlockStorage, ElasticIP, KeyPair, Project)
- Network resource definitions (VPC, Subnet, SecurityGroup, SecurityRule)
- Version-controlled CRD lifecycle management

## Requirements
- Kubernetes >= 1.21
- Helm >= 3.0

[![GitHub release](https://img.shields.io/github/tag/arubacloud/arubacloud-resource-operator.svg?label=release)](https://github.com/arubacloud/arubacloud-resource-operator/releases/latest)

⚠️ **Development Status**: Not production-ready yet. APIs may change.

## Installation

### Prerequisites

**Important:** CRDs must be installed before installing the operator. The operator will not work unless CRDs are present in your cluster.

### Install the chart

Add the arubacloud Helm repository:
```bash
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update
```

Install the CRDs:
```bash
helm install arubacloud-operator-crd arubacloud/arubacloud-resource-operator-crd
```

## Installed CRDs

This chart installs the following Custom Resource Definitions:

### Infrastructure Resources

- `blockstorages.arubacloud.com` - Persistent block storage volumes
  - **Kind**: BlockStorage
  - **Purpose**: Manage persistent storage volumes for CloudServer instances
  
- `cloudservers.arubacloud.com` - Virtual machine instances
  - **Kind**: CloudServer
  - **Purpose**: Create and manage virtual machines in Aruba Cloud
  
- `elasticips.arubacloud.com` - Static public IP addresses
  - **Kind**: ElasticIP
  - **Purpose**: Allocate and assign static public IPs to resources
  
- `keypairs.arubacloud.com` - SSH key pairs
  - **Kind**: KeyPair
  - **Purpose**: Manage SSH keys for secure server access
  
- `projects.arubacloud.com` - Aruba Cloud projects
  - **Kind**: Project
  - **Purpose**: Organize and isolate cloud resources by project

### Network Resources

- `vpcs.arubacloud.com` - Virtual Private Cloud networks
  - **Kind**: Vpc
  - **Purpose**: Create isolated network environments
  
- `subnets.arubacloud.com` - Network subnets
  - **Kind**: Subnet
  - **Purpose**: Define IP address ranges within VPCs
  
- `securitygroups.arubacloud.com` - Network security groups
  - **Kind**: SecurityGroup
  - **Purpose**: Control network traffic with firewall rules
  
- `securityrules.arubacloud.com` - Security group rules
  - **Kind**: SecurityRule
  - **Purpose**: Define individual firewall rules for security groups

## Verification

After installation, verify that all CRDs are installed correctly:

```bash
kubectl get crds | grep arubacloud.com
```

You should see all 9 CRDs listed:
```
blockstorages.arubacloud.com
cloudservers.arubacloud.com
elasticips.arubacloud.com
keypairs.arubacloud.com
projects.arubacloud.com
securitygroups.arubacloud.com
securityrules.arubacloud.com
subnets.arubacloud.com
vpcs.arubacloud.com
```

## Next Steps

After installing the CRDs, install the operator controller:

```bash
helm install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system --create-namespace
```

See the [arubacloud-resource-operator chart documentation](../arubacloud-resource-operator/README.md) for detailed operator configuration.

## Uninstalling

To uninstall the CRDs:

```bash
helm uninstall arubacloud-operator-crd
```

⚠️ **Warning**: Uninstalling will delete all CRD definitions and associated custom resources. Ensure you have backed up any important resources before uninstalling!

## Troubleshooting

- **CRDs already exist**: If you see errors about existing CRDs, they may have been installed previously. You can safely skip this installation or use `helm upgrade` instead.
- **Operator not working**: Ensure CRDs are installed before the operator. The operator depends on these definitions to function.
- **Invalid ownership metadata**: If you see ownership errors, it means CRDs are managed outside of Helm. This is expected; CRDs can be managed independently.

## Support

For issues with this chart, open an issue in the [helm-charts repository](https://github.com/Arubacloud/helm-charts).

For operator-specific documentation and examples, visit the [arubacloud-resource-operator repository](https://github.com/Arubacloud/arubacloud-resource-operator).

## License

Copyright 2024 Aruba S.p.A. - Licensed under Apache License 2.0
