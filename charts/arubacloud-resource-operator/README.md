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
- HashiCorp Vault with AppRole authentication enabled
- CRDs must be installed first (see Prerequisites)

[![GitHub release](https://img.shields.io/github/tag/arubacloud/arubacloud-resource-operator.svg?label=release)](https://github.com/arubacloud/arubacloud-resource-operator/releases/latest)

⚠️ **Development Status**: Not production-ready yet. APIs may change.

## Installation

### Prerequisites

#### 1. HashiCorp Vault Setup

**Important:** The operator requires a running HashiCorp Vault instance that is reachable from the Kubernetes cluster. Vault is used to securely store and retrieve Aruba Cloud API credentials (clientId and clientSecret).

**Vault Requirements:**
- Vault must be accessible from the operator pod (network connectivity required)
- AppRole authentication method must be enabled
- A Key-Value (KV) secrets engine must be mounted
- Aruba Cloud API credentials must be stored in Vault

**Configuration Parameters:**

When installing the operator, you need to provide Vault connection details:

- `controllerManager.vaultAddress`: The full URL of your Vault instance
  - Example: `http://vault-active.vault.svc.cluster.local:8200`
  - Must be reachable from the operator pod

- `controllerManager.roleId`: The AppRole Role ID for authentication
  - This is the identifier for the AppRole used by the operator
  - Example: `6377c3da-9db4-6fcc-63c2-1f4420c3f9ba`

- `controllerManager.roleSecret`: The AppRole Secret ID for authentication
  - This is the secret credential paired with the Role ID
  - Example: `219c8e15-c9ac-8817-c7a1-58f5764d5128`
  - ⚠️ Keep this value secure and rotate it regularly

- `controllerManager.rolePath`: The path where AppRole is mounted in Vault
  - Default: `approle`
  - Only change if you've customized your Vault AppRole mount path

**What the operator fetches from Vault:**
- Aruba Cloud API `clientId` (OAuth2 client identifier)
- Aruba Cloud API `clientSecret` (OAuth2 client secret)

These credentials are used to authenticate with the Aruba Cloud API to manage resources.

#### 2.Installation

#### Option 1: Automatic CRD Installation (Recommended)

By default, this chart automatically installs the required CRDs as a dependency. Simply install the operator and CRDs will be installed together:

```bash
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update

helm install -n aruba-system arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system \
  --create-namespace \
  --set controllerManager.roleId="YOUR_ROLE_ID" \
  --set controllerManager.rolePath=approle \
  --set controllerManager.roleSecret="YOUR_ROLE_SECRET" \
  --set controllerManager.vaultAddress="YOUR_VAULT_ADDRESS"

```

#### Option 2: Manual CRD Installation

If you prefer to manage CRDs separately or they are already installed, you can disable automatic CRD installation:

```bash
helm install -n aruba-system arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system \
  --create-namespace \
  --set controllerManager.roleId="6377c3da-9db4-6fcc-63c2-1f4420c3f9ba" \
  --set controllerManager.rolePath=approle \
  --set controllerManager.roleSecret="219c8e15-c9ac-8817-c7a1-58f5764d5128" \
  --set controllerManager.vaultAddress="http://vault-active.vault.svc.cluster.local:8200" \  
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

## Parameters

### Global Parameters

| Name                           | Description                                      | Default                        |
|--------------------------------|--------------------------------------------------|--------------------------------|
| `crds.enabled`                 | Install CRDs as a dependency (set to false if managing CRDs separately) | `true` |
| `kubernetesClusterDomain`      | Kubernetes cluster domain                        | `cluster.local`                |

### Controller Manager Parameters

| Name                                              | Description                                      | Default                        |
|---------------------------------------------------|--------------------------------------------------|--------------------------------|
| `controllerManager.replicas`                      | Number of operator replicas                      | `1`                            |
| `controllerManager.apiGateway`                    | Aruba Cloud API endpoint URL                     | `https://api.arubacloud.com`   |
| `controllerManager.keycloakUrl`                   | Keycloak authentication service URL              | `https://login.aruba.it/auth`  |
| `controllerManager.realmApi`                      | Keycloak realm for API authentication            | `cmp-new-apikey`               |
| `controllerManager.vaultAddress`                  | HashiCorp Vault server URL (must be reachable)   | `http://vault0.default.svc.cluster.local:8200` |
| `controllerManager.roleId`                        | Vault AppRole Role ID (required)                 | `""`                           |
| `controllerManager.roleSecret`                    | Vault AppRole Secret ID (required)               | `""`                           |
| `controllerManager.rolePath`                      | Vault AppRole mount path                         | `approle`                      |
| `controllerManager.kvMount`                       | Vault KV secrets engine mount path               | `kv`                           |
| `controllerManager.manager.image.repository`      | Operator container image repository              | (from values.yaml)             |
| `controllerManager.manager.image.tag`             | Operator container image tag                     | `latest`                       |
| `controllerManager.manager.resources.limits.cpu`    | CPU limit for operator container               | `500m`                         |
| `controllerManager.manager.resources.limits.memory` | Memory limit for operator container            | `128Mi`                        |
| `controllerManager.manager.resources.requests.cpu`  | CPU request for operator container             | `10m`                          |
| `controllerManager.manager.resources.requests.memory` | Memory request for operator container        | `64Mi`                         |
| `controllerManager.manager.containerSecurityContext` | Security context for the manager container    | (see values.yaml)              |
| `controllerManager.podSecurityContext`            | Security context for operator pods               | (see values.yaml)              |
| `controllerManager.nodeSelector`                  | Node selector for operator pods                  | `{}`                           |
| `controllerManager.tolerations`                   | Tolerations for operator pods                    | `[]`                           |
| `controllerManager.topologySpreadConstraints`     | Topology spread constraints for operator pods    | `[]`                           |

### Service Account Parameters

| Name                              | Description                                      | Default                        |
|-----------------------------------|--------------------------------------------------|--------------------------------|
| `serviceAccount.create`           | Create service account                           | `true`                         |
| `serviceAccount.name`             | Service account name (generated if empty)        | `""`                           |
| `serviceAccount.annotations`      | Annotations for service account                  | `{}`                           |
| `serviceAccount.automount`        | Automount service account token                  | `true`                         |

### Metrics Service Parameters

| Name                              | Description                                      | Default                        |
|-----------------------------------|--------------------------------------------------|--------------------------------|
| `metricsService.type`             | Kubernetes service type for metrics              | `ClusterIP`                    |
| `metricsService.ports`            | Ports configuration for metrics service          | (see values.yaml)              |

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
