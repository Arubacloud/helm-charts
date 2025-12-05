# Aruba Cloud Helm Repository

This repository hosts multiple Helm charts for Aruba Cloud, published via GitHub Pages.

## Available Charts

| Chart | Description | Version | Documentation |
|-------|-------------|---------|---------------|
| [actalis-cert-manager](./charts/actalis-cert-manager) | Installs cert-manager and configures Actalis ACME integration for automated certificate management | 0.1.0 | [README](./charts/actalis-cert-manager/README.md) |
| [arubacloud-resource-operator](./charts/arubacloud-resource-operator) | Kubernetes operator for managing Aruba Cloud infrastructure resources through CRDs | 0.1.0 | [README](./charts/arubacloud-resource-operator/README.md) |
| [arubacloud-resource-operator-crd](./charts/arubacloud-resource-operator-crd) | Custom Resource Definitions for the Aruba Cloud Resource Operator | 0.1.0 | [README](./charts/arubacloud-resource-operator-crd/README.md) |
| [cluster-autoscaler](./charts/cluster-autoscaler) | Kubernetes cluster autoscaler for automatic node scaling | 0.1.0 | [README](./charts/cluster-autoscaler/README.md) |

## Structure
- `charts/` - Each chart in its own subdirectory
- `docs/` - Published chart index for GitHub Pages
- `.github/workflows/` - CI/CD workflows for publishing

## Publishing Charts to GitHub Pages
Charts are packaged and indexed automatically using GitHub Actions. All charts in `charts/` are published to the `docs/` folder and served via GitHub Pages.

## Quick Start

### Add the Repository
```sh
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update
```

### List Available Charts
```sh
helm search repo arubacloud
```

### Install a Chart
```sh
helm install my-release arubacloud/<chart-name>
```

For detailed installation instructions and configuration options, refer to each chart's documentation.

## Contributing

### Adding a New Chart
1. Create a new subdirectory under `charts/` with your chart name
2. Ensure your chart includes:
   - `Chart.yaml` with proper metadata
   - `values.yaml` with default values
   - `README.md` with comprehensive documentation
   - `templates/` directory with Kubernetes manifests
3. Update chart version in `Chart.yaml` before publishing
4. Test your chart installation locally

### CI/CD Pipeline
The GitHub Actions workflow automatically:
- Checks chart structure and documentation presence
- Generates documentation using helm-docs
- Packages all charts
- Publishes to GitHub Pages

## Development

### Local Testing
```sh
# Test chart installation
helm install test-release ./charts/<chart-name> --dry-run --debug

# Generate documentation
make docs

# Package charts
make package
```

### Requirements
- Helm >= 3.0
- helm-docs (for documentation generation)

## Support

For chart-specific issues and detailed documentation, refer to individual chart READMEs linked in the table above.

For general repository issues, open an issue in the [helm-charts repository](https://github.com/Arubacloud/helm-charts).

## License

Copyright 2024 Aruba S.p.A. - Licensed under Apache License 2.0
