# actalis-cert-manager Helm Chart

A Helm chart to install cert-manager, configure Actalis ACME integration, and bootstrap secure certificate management for Kubernetes clusters.

## Features
- Installs cert-manager and CRDs
- Creates Actalis External Account Binding (EAB) secret
- Configures ClusterIssuer for Actalis ACME
- Supports HTTP01 challenge via configurable ingress class

## Requirements
- Kubernetes >= 1.21
- Helm >= 3.0


## Actalis ACME Setup
1. [Create an Actalis account](https://www.actalis.com/).
2. Activate ACME support in your Actalis dashboard (see [Actalis ACME activation guideline](https://guide.actalis.com/ssl/activation/acme)):
  ![Activate ACME](assets/acme-activation.png)
3. Retrieve your ACME credentials (Key ID and HMAC Key):
  ![Get ACME Credentials](assets/acme-credentials.png)

## Installation


## Install cert-manager CRDs
Before installing this chart, you must manually install cert-manager CRDs:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.crds.yaml
```


## Install the chart
The actalis-cert-manager chart will install cert-manager itself as a dependency. You do not need to install cert-manager separately.

Add the arubacloud Helm repository:
```bash
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update
```

Install the chart from the arubacloud repo:
```bash
helm install actalis-cert-manager arubacloud/actalis-cert-manager --namespace cert-manager --create-namespace
```

## Parameters
| Name                | Description                                      | Default                        |
|---------------------|--------------------------------------------------|--------------------------------|
| `certmanager.crds.enabled` | Install cert-manager CRDs                    | `true`                         |
| `actalis.eabKey`    | Actalis EAB HMAC key (base64url, unpadded)       | `CHANGE_ME_EAB_KEY`            |
| `actalis.kid`       | Actalis EAB Key ID                               | `CHANGE_ME_KID`                |
| `actalis.email`     | Email for ACME registration                      | `change-me@example.com`        |
| `actalis.server`    | Actalis ACME server URL                          | `https://acme-api.actalis.com/acme/directory` |
| `actalis.ingressClass` | Ingress class for HTTP01 challenge             | `nginx`                        |

## Example values.yaml
```yaml
certmanager:
  crds:
    enabled: true
actalis:
  eabKey: "_6lYptvZdi2ZWybRDO8_rfAmxIQSRBvrAszIcTIwdtE"
  kid: "qbjLGStU9KfgZNBBwPtWLKiZkn"
  email: "your-email@example.com"
  server: "https://acme-api.actalis.com/acme/directory"
  ingressClass: "nginx"
```

## Usage Example
After installing the chart, cert-manager will be set up and a ClusterIssuer for Actalis ACME will be created. You can then request certificates using this ClusterIssuer.


### Automatic Certificate Creation via Ingress Annotation
You can have cert-manager automatically create and manage certificates for your Ingress resources by adding the following annotation:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: actalis-acme
    acme.cert-manager.io/http01-edit-in-place: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - hello.devsecops2025-arubacloud.com
    secretName: hello.devsecops2025-arubacloud-com-tls
  rules:
  - host: hello.devsecops2025-arubacloud.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-world
            port:
              number: 80
```

With this annotation, cert-manager will automatically create the required Certificate resource and manage the TLS secret for your Ingress.

## Troubleshooting
- Ensure your EAB HMAC key is base64url-encoded and unpadded (no trailing `=`).
- Wait for all cert-manager pods to be ready before applying ACME resources.
- If you see webhook TLS errors, wait a few minutes and retry.
- For ACME registration errors, double-check your Key ID and HMAC key format.


## Uninstall

To uninstall the chart and all resources created by it:
```bash
helm uninstall my-release --namespace cert-manager
```

To remove cert-manager CRDs and namespace (optional, for a full cleanup):
```bash
kubectl delete crd certificaterequests.cert-manager.io certificates.cert-manager.io challenges.acme.cert-manager.io clusterissuers.cert-manager.io issuers.cert-manager.io orders.acme.cert-manager.io
kubectl delete namespace cert-manager
```

## Support
For issues with this chart, open an issue in your repository or consult the [cert-manager documentation](https://cert-manager.io/docs/).

For Actalis ACME support, refer to [Actalis documentation](https://guide.actalis.com/ssl/) or the [Actalis FAQ](https://guide.actalis.com/faq).
