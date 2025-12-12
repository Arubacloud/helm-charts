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

### Install the Chart

Add the arubacloud Helm repository (if not already added):
```bash
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update
```

#### Single-Tenant Installation (Default)

For single-tenant deployments with direct OAuth credentials:

```bash
helm install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system \
  --create-namespace \
  --set config.auth.mode=single \
  --set config.auth.single.clientId=<your-client-id> \
  --set config.auth.single.clientSecret=<your-client-secret>
```

Example with specific image version:
```bash
helm upgrade --install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system \
  --create-namespace \
  --set controller.manager.image.tag=v0.0.1-alpha4 \
  --set config.auth.mode=single \
  --set config.auth.single.clientId=cmp-4adf9b35-3d98-4233-a863-8ad48cd2a2f5 \
  --set config.auth.single.clientSecret=i3HaYhQHDhczUWWaUYUeL2tZffeHzo4F
```

#### Multi-Tenant Installation (Vault-based)

For multi-tenant deployments using HashiCorp Vault:

```bash
helm install arubacloud-operator arubacloud/arubacloud-resource-operator \
  --namespace aruba-system \
  --create-namespace \
  --set config.auth.mode=multi \
  --set config.auth.multi.vault.address=<vault-address> \
  --set config.auth.multi.vault.rolePath=<vault-role-path> \
  --set config.auth.multi.vault.roleId=<vault-role-id> \
  --set config.auth.multi.vault.roleSecret=<vault-role-secret> \ 
  --set config.auth.multi.vault.kvMount=<vault-role-kvMount>
```

## Configuration

### Prerequisites

If you enable **multi** mode 

* Vault is running and accessible.
* A token with appropriate capabilities (or root token) is available.
* KV engine is enabled or can be enabled.
* Namespace usage (optional) is known if relevant.

#### Vault AppRole Configuration

This guide explains how the operator can use HashiCorp Vault AppRole authentication to securely access Aruba Cloud credentials.

Vault must be enabled in the operator configuration (**vault-enabled**), and the operator requires access to the KV engine to retrieve secrets (**client-id** and **client-secret**) for OAuth client_credentials flow.

###### Steps to Configure Vault

Below is a summary of how to configure Vault:

0. Export environment variables (address and root token, or a token with the required capabilities)
```bash
  export VAULT_ADDRESS=http://localhost:8200
  export VAULT_TOKEN=hvs.xxxxxxxxxxxxxxxxxxxx
```
1. Enable AppRole auth
```bash
  vault auth enable approle
```
2. Create a policy allowing access to your KV engine path
_File: operator-policy.hcl_
```bash
     path "kv/data/*" {
      capabilities = ["read"]
    }
```
3. Write the policy
```bash
  vault policy write operator-policy operator-policy.hcl
```
4. Create an AppRole and assign the policy
```bash
vault write auth/approle/role/operator-role \
  token_policies="operator-policy" \
  secret_id_ttl=0 \
  secret_id_num_uses=0 \
  token_ttl=1h \
  token_max_ttl=4h
```
5. Get the Role ID
```bash
  vault read auth/approle/role/operator-role/role-id
```
_output:_
```bash
  Key        Value
  ---        -----
  role_id    c7f48cd1-e464-7c80-b919-88b5a668e8f9
```
6. Get the Secret ID
```bash
  vault write -f auth/approle/role/operator-role/secret-id
```
output:
```bash
  Key                   Value
  ---                   -----
  secret_id             1aee83c8-fafa-6cf9-cc84-fe1decd6625b
  secret_id_accessor    5d14319e-052c-fec6-42c0-9b6a643d0664
  secret_id_num_uses    0
  secret_id_ttl         0s
```
7. Enable KV version 2 using your chosen path (in this case kv)
```bash
  vault secrets enable -path=kv kv-v2
```
8. Store the client ID and client secret for the tenant used in your CRs.
```bash
  vault kv put kv/my-tenant client-id="cmp-12345667" client-secret="xxxxxxxxxxxxxxxxxx"
```
_output:_
```bash
  == Secret Path ==
  kv/data/my-tenant
  ======= Metadata =======
  Key                Value
  ---                -----
  created_time       2025-12-10T09:14:31.121191577Z
  custom_metadata    <nil>
  deletion_time      n/a
  destroyed          false
  version            1
```

## Parameters

### Global Parameters

| Name                | Description                                      | Default                        |
|---------------------|--------------------------------------------------|--------------------------------|
| `crds.enabled`      | Install CRDs as a dependency (set to false if managing CRDs separately) | `true` |
| `kubernetesClusterDomain` | Kubernetes cluster domain | `cluster.local` |

### Configuration Parameters

| Name                | Description                                      | Default                        |
|---------------------|--------------------------------------------------|--------------------------------|
| `config.gateway` | Aruba Cloud API gateway endpoint | `https://api.arubacloud.com` |
| `config.auth.idp` | Keycloak/IDP authentication URL | `https://login.aruba.it/auth` |
| `config.auth.realm` | API realm name | `cmp-new-apikey` |
| `config.auth.mode` | Authentication mode: `single` or `multi` | `single` |
| `config.auth.single.clientId` | OAuth client ID (required when mode is `single`) | `""` |
| `config.auth.single.clientSecret` | OAuth client secret (required when mode is `single`) | `""` |
| `config.auth.multi.vault.address` | Vault server address (used when mode is `multi`) | `http://vault0.default.svc.cluster.local:8200` |
| `config.auth.multi.vault.kvMount` | Vault KV mount path (used when mode is `multi`) | `kw` |
| `config.auth.multi.vault.rolePath` | Vault AppRole path (used when mode is `multi`) | `approle` |
| `config.auth.multi.vault.roleId` | Vault AppRole ID (required when mode is `multi`) | `""` |
| `config.auth.multi.vault.roleSecret` | Vault AppRole secret (required when mode is `multi`) | `""` |

### Controller Parameters

| Name                | Description                                      | Default                        |
|---------------------|--------------------------------------------------|--------------------------------|
| `controller.replicas` | Number of operator replicas | `1` |
| `controller.manager.image.repository` | Operator image repository | (see values.yaml) |
| `controller.manager.image.tag` | Operator image tag | `latest` |
| `controller.manager.resources.limits.cpu` | CPU limit | `500m` |
| `controller.manager.resources.limits.memory` | Memory limit | `128Mi` |
| `controller.manager.resources.requests.cpu` | CPU request | `10m` |
| `controller.manager.resources.requests.memory` | Memory request | `64Mi` |
| `controller.nodeSelector` | Node selector for pod assignment | `{}` |
| `controller.tolerations` | Tolerations for pod assignment | `[]` |
| `controller.topologySpreadConstraints` | Topology spread constraints | `[]` |
| `controller.podSecurityContext` | Pod security context | (see values.yaml) |
| `controller.manager.containerSecurityContext` | Container security context | (see values.yaml) |

### Service Account Parameters

| Name                | Description                                      | Default                        |
|---------------------|--------------------------------------------------|--------------------------------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.name` | Service account name (generated if empty) | `""` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.automount` | Automount service account token | `true` |

### Metrics Service Parameters

| Name                | Description                                      | Default                        |
|---------------------|--------------------------------------------------|--------------------------------|
| `metricsService.type` | Metrics service type | `ClusterIP` |
| `metricsService.ports` | Metrics service ports | (see values.yaml) |

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