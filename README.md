# Aruba Cloud Helm Repository

# Aruba Cloud Helm Charts Repository

This repository hosts multiple Helm charts for Aruba Cloud, published via GitHub Pages.

## Structure
- `charts/` - Each chart in its own subdirectory (e.g., `charts/copilot/`)
- `docs/` - Published chart index for GitHub Pages
- `.github/workflows/` - CI/CD workflows for publishing

## Publishing Charts to GitHub Pages
Charts are packaged and indexed automatically using GitHub Actions. All charts in `charts/` are published to the `docs/` folder and served via GitHub Pages.

## Importing Aruba Cloud Helm Repo
Add the repo to your Helm client:

```sh
helm repo add arubacloud https://arubacloud.github.io/helm-charts/
helm repo update
```

Install a chart:
```sh
helm install my-release arubacloud/<chart-name>
```

## Contributing
- Add new charts in their own subdirectory under `charts/`
- Update chart version in `Chart.yaml` before publishing
