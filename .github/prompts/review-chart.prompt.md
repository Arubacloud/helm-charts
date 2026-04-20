---
agent: agent
description: Review a chart for security issues and Kubernetes best practices
---

# Chart Security & Best-Practices Review

You are auditing a Helm chart in this repository. Perform a thorough review and produce a prioritised list of findings with suggested fixes.

## Scope

Review the following files in `charts/<chart-name>/`:
- `values.yaml`
- `templates/*.yaml`
- `Chart.yaml`

## Checklist

### Security (CRITICAL)
- [ ] No hard-coded secrets, tokens, or passwords anywhere in the chart.
- [ ] Container runs as non-root (`runAsNonRoot: true` in `securityContext`).
- [ ] All capabilities dropped (`capabilities.drop: [ALL]`).
- [ ] `allowPrivilegeEscalation: false` set on every container.
- [ ] `readOnlyRootFilesystem: true` where feasible.
- [ ] ServiceAccount has `automountServiceAccountToken: false` unless explicitly required.
- [ ] RBAC rules follow least-privilege (no wildcard verbs or resources unless justified).
- [ ] Secrets are referenced via `secretKeyRef`, never embedded as plain-text env vars.

### Reliability
- [ ] Liveness and readiness probes defined for every container.
- [ ] Resource `requests` and `limits` set for every container.
- [ ] PodDisruptionBudget present for replicated workloads.
- [ ] `topologySpreadConstraints` or affinity rules present for HA deployments.

### Helm Best Practices
- [ ] All resources use `{{ include "<chart>.fullname" . }}` for names.
- [ ] All resources carry the standard labels from `_helpers.tpl`.
- [ ] Optional features are gated with `{{- if .Values.<feature>.enabled }}`.
- [ ] `NOTES.txt` is present and informative.
- [ ] `values.yaml` has `# --` annotations on all keys.
- [ ] No `tpl` usage on values that don't need template rendering.

### Version Management
- [ ] `version` and `appVersion` are in sync and follow SemVer.
- [ ] Dependency versions are pinned (no `*` or loose ranges).

## Output Format

List each finding as:
```
[SEVERITY] File: <file> — <description>
Suggested fix: <one-line fix or code snippet>
```

Severities: CRITICAL · HIGH · MEDIUM · LOW · INFO
