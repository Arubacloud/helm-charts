---
agent: agent
description: Add a new CRD to the arubacloud-resource-operator-crd chart
---

# Add a New CRD

You are adding a new Custom Resource Definition to `charts/arubacloud-resource-operator-crd/`.

## Input

Ask the user for:
1. **Resource kind** (PascalCase, e.g. `LoadBalancer`)
2. **Resource group** (e.g. `cloud.arubacloud.com`)
3. **Plural form** (e.g. `loadbalancers`)
4. **Scope** (`Namespaced` or `Cluster`)
5. **Short names** (optional, e.g. `lb`)
6. **Spec fields** — list of fields with their types and whether they are required

## Output

### `charts/arubacloud-resource-operator-crd/templates/<resource-plural>-crd.yaml`

Scaffold a full `apiextensions.k8s.io/v1` CRD manifest:
- Include `openAPIV3Schema` with all requested spec fields.
- Add a `status` subresource with `conditions` (array of `metav1.Condition`-compatible objects).
- Set `preserveUnknownFields: false`.
- Include standard labels via `{{ include "arubacloud-resource-operator-crd.labels" . }}`.
- Wrap the whole file with `{{- if .Values.crds.install }}` guard.

### Update `charts/arubacloud-resource-operator-crd/values.yaml`
- The `crds.install` flag should already exist; no change needed unless missing.

### Update `charts/arubacloud-resource-operator-crd/Chart.yaml`
- Bump the **patch** version in both `version` and `appVersion`.

### Update `charts/arubacloud-resource-operator/Chart.yaml`
- Bump the CRD dependency version to match the new CRD chart version.

## Constraints
- CRD files must not include `helm.sh/hook` annotations (they are managed by the chart directly).
- All CRD spec fields must have a `description` in the schema.
- Validation patterns for known types: IP addresses use `pattern: ^\d{1,3}(\.\d{1,3}){3}$`, CIDR uses `format: cidr` (custom x-kubernetes).
