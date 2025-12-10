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

#### Vault AppRole Secret Configuration for Aruba Cloud Operator

This guide explains how the operator can use HashiCorp Vault AppRole authentication to securely access Aruba Cloud credentials.

Vault must be enabled in the operator configuration, and the operator requires access to the KV engine to retrieve secrets (**client-id** and **client-secret**) for OAuth client_credentials flow.

###### Prerequisites

* Vault is running and accessible.
* A token with appropriate capabilities (or root token) is available.
* KV engine is enabled or can be enabled.
* Namespace usage (optional) is known if relevant.

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
File: operator-policy.hcl 
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
8. Store the client ID and client secret for the tenant used in your CRs (for example, tenant ARU-77777)
```bash
  vault kv put kv/aru-77777 client-id="cmp-12345667" client-secret="xxxxxxxxxxxxxxxxxx"
```
output:
```bash
  == Secret Path ==
  kv/data/aru-77777
  ======= Metadata =======
  Key                Value
  ---                -----
  created_time       2025-12-10T09:14:31.121191577Z
  custom_metadata    <nil>
  deletion_time      n/a
  destroyed          false
  version            1
```

###### Configuration to change in values.yaml
Example with values from example above:

```yaml
  vault-enabled: true
  vault-address: http://localhost:8200
  role-path: approle
  kv-mount: kv
  role-namespace: ""
  role-id: c7f48cd1-e464-7c80-b919-88b5a668e8f9
  role-secret: 1aee83c8-fafa-6cf9-cc84-fe1decd6625b
```
Replace values with your Vault AppRole credentials.

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
