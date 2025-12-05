# arubacloud-resource-operator

A Helm chart to install and configure the Aruba Cloud Resource Operator for managing Aruba Cloud infrastructure resources through Kubernetes CRDs.

## Features
- Manages Aruba Cloud resources as Kubernetes custom resources
- Infrastructure automation (CloudServer, BlockStorage, ElasticIP, KeyPair, Project)
- Network management (VPC, Subnet, SecurityGroup, SecurityRule)
- Integration with HashiCorp Vault for secure credential management
- Support for multiple Aruba Cloud projects and tenants

## Requirements
- Kubernetes >= 1.21
- Helm >= 3.0
- CRDs must be installed first (see Prerequisites)

[![GitHub release](https://img.shields.io/github/tag/arubacloud/arubacloud-resource-operator.svg?label=release)](https://github.com/arubacloud/arubacloud-resource-operator/releases/latest)

⚠️ **Development Status**: Not production-ready yet. APIs may change.

## Installation

### Prerequisites

**Important:** You must install the CRDs before installing this operator. The operator will not work unless CRDs are present in your cluster.

#### Option 1: Automatic CRD Installation (Recommended)

By default, this chart automatically installs the required CRDs as a dependency. Simply install the operator and CRDs will be installed together:

```bash
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update
helm install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system --create-namespace
```

#### Option 2: Manual CRD Installation

If you prefer to manage CRDs separately or they are already installed, you can disable automatic CRD installation:

```bash
helm install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system --create-namespace \
  --set crds.enabled=false
```

To install CRDs manually:
```bash
helm install arubacloud-operator-crd arubacloud/arubacloud-resource-operator-crd
```

Verify CRDs are installed:
```bash
kubectl get crds | grep arubacloud.com
```

### Install the chart

Add the arubacloud Helm repository (if not already added):
```bash
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update
```

Install the operator with automatic CRD installation (default):
```bash
helm install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system --create-namespace
```

Or install without CRDs (if managing them separately):
```bash
helm install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system --create-namespace \
  --set crds.enabled=false
```

## Configuration

### Required Secrets and ConfigMaps

The operator requires authentication credentials and API endpoints to communicate with Aruba Cloud services.

#### Create Vault AppRole Secret

The operator uses HashiCorp Vault AppRole authentication to securely access Aruba Cloud credentials:

```bash
kubectl create secret generic controller-manager \
  --from-literal=role-id=YOUR_ROLE_ID \
  --from-literal=role-secret=YOUR_ROLE_SECRET \
  --namespace aruba-system
```

Replace `YOUR_ROLE_ID` and `YOUR_ROLE_SECRET` with your Vault AppRole credentials.

#### Create API Configuration

Configure API endpoints and Vault settings:

```bash
kubectl create configmap controller-manager \
  --from-literal=api-gateway=https://api.arubacloud.com \
  --from-literal=keycloak-url=https://login.aruba.it/auth \
  --from-literal=realm-api=cmp-new-apikey \
  --from-literal=vault-address=http://vault0.default.svc.cluster.local:8200 \
  --from-literal=role-path=approle \
  --from-literal=kv-mount=kv \
  --namespace aruba-system
```

Adjust the values according to your environment, particularly:
- `api-gateway`: Aruba Cloud API endpoint
- `keycloak-url`: Authentication service URL
- `vault-address`: Your Vault instance address
- `kv-mount`: Key-Value mount path in Vault

## Parameters

| Name                | Description                                      | Default                        |
|---------------------|--------------------------------------------------|--------------------------------|
| `crds.enabled`      | Install CRDs as a dependency (set to false if managing CRDs separately) | `true` |
| `namespace`         | Namespace where operator will be deployed        | `aruba-system`                 |
| `replicaCount`      | Number of operator replicas                      | `1`                            |
| `image.repository`  | Operator image repository                        | (from values.yaml)             |
| `image.tag`         | Operator image tag                               | (from values.yaml)             |
| `resources`         | Resource limits and requests                     | (from values.yaml)             |

Refer to the [values.yaml](values.yaml) file for a complete list of configurable parameters.

## Usage Example

After installing the operator and configuring credentials, you can create Aruba Cloud resources using Kubernetes manifests.

### Example: Create a VPC

```yaml
apiVersion: arubacloud.com/v1alpha1
kind: Vpc
metadata:
  name: my-vpc
  namespace: default
spec:
  tenant: my-tenant
  location:
    value: ITBG-Bergamo
  projectReference:
    name: my-project
    namespace: default
```

Apply the VPC resource:
```bash
kubectl apply -f vpc.yaml
```

Check the VPC status:
```bash
kubectl get vpc my-vpc -o yaml
```

### Example: Create a CloudServer

```yaml
apiVersion: arubacloud.com/v1alpha1
kind: CloudServer
metadata:
  name: my-server
  namespace: default
spec:
  tenant: my-tenant
  location:
    value: ITBG-Bergamo
  projectReference:
    name: my-project
    namespace: default
  flavor: small
  image: ubuntu-22.04
  keyPairReference:
    name: my-keypair
    namespace: default
  vpcReference:
    name: my-vpc
    namespace: default
```

### Example: Create a SecurityGroup

```yaml
apiVersion: arubacloud.com/v1alpha1
kind: SecurityGroup
metadata:
  name: my-secgroup
  namespace: default
spec:
  tenant: my-tenant
  location:
    value: ITBG-Bergamo
  projectReference:
    name: my-project
    namespace: default
  vpcReference:
    name: my-vpc
    namespace: default
  description: "Security group for my application"
```

## Available Resources

The operator manages the following Aruba Cloud resource types:

### Infrastructure Resources
- **BlockStorage**: Persistent block storage volumes for CloudServer instances
- **CloudServer**: Virtual machine instances with customizable compute, memory, and storage
- **ElasticIP**: Static public IP addresses that can be assigned to resources
- **KeyPair**: SSH key pairs for secure server access
- **Project**: Aruba Cloud projects for resource organization and isolation

### Network Resources
- **VPC**: Virtual Private Cloud networks for isolated network environments
- **Subnet**: Network subnets defining IP address ranges within VPCs
- **SecurityGroup**: Network security groups with firewall rules
- **SecurityRule**: Individual firewall rules for controlling network traffic

## Verification

Check that the operator is running:

```bash
kubectl get pods -n aruba-system
```

You should see the operator pod in a `Running` state.

View operator logs:

```bash
kubectl logs -n aruba-system -l control-plane=controller-manager -f
```

## Troubleshooting

- **Operator pod not starting**: Check that CRDs are installed and that the namespace exists. If `crds.enabled=true`, ensure Helm can reach the chart repository.
- **Authentication errors**: Verify that Vault AppRole credentials are correct and that the Vault instance is accessible.
- **Resource creation failures**: Check operator logs for detailed error messages. Ensure API endpoints are correct and accessible.
- **Missing CRDs**: If you disabled automatic CRD installation (`crds.enabled=false`), ensure you've manually installed the `arubacloud-resource-operator-crd` chart.
- **CRD version mismatch**: If CRDs were installed separately, ensure they match the version expected by the operator.

## Uninstall

To uninstall the operator:

```bash
helm uninstall arubacloud-operator --namespace aruba-system
```

**Note:** If CRDs were installed as a dependency (`crds.enabled=true`), they will be automatically removed when uninstalling the operator.

To uninstall CRDs manually (if they were installed separately):

```bash
helm uninstall arubacloud-operator-crd
```

⚠️ **Warning**: Uninstalling CRDs will delete all associated Aruba Cloud resources defined in your cluster. Ensure you have backed up or migrated any important resources before proceeding.

To remove the namespace:

```bash
kubectl delete namespace aruba-system
```

## Support

For issues with this chart, open an issue in the [helm-charts repository](https://github.com/Arubacloud/helm-charts).

For operator-specific documentation, examples, and API reference, visit the [arubacloud-resource-operator repository](https://github.com/Arubacloud/arubacloud-resource-operator).

## License

Copyright 2024 Aruba S.p.A. - Licensed under Apache License 2.0
