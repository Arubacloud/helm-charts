---
agent: agent
description: Bump chart version, update changelog entry, and sync dependency versions
---

# Bump Chart Version

You are bumping the version of one or more charts in this repository before a release.

## Input

Ask the user for:
1. **Chart(s) to bump** (name or `all`)
2. **Bump type**: `patch` | `minor` | `major`
3. **Change summary** (one sentence describing what changed)

## Steps

For each targeted chart:

1. **Read `Chart.yaml`** and compute the new SemVer based on the bump type.
2. **Update `version` and `appVersion`** in `Chart.yaml` to the new version.
3. **If the chart has dependents** (e.g. `arubacloud-resource-operator` depends on `arubacloud-resource-operator-crd`):
   - Find all charts whose `Chart.yaml` `dependencies` block references the bumped chart.
   - Update the `version` constraint in those charts' `dependencies` block to match the new version.
4. **Do not** regenerate `README.md` — CI handles that.
5. **Print a summary** of every file changed and the old → new version.

## Constraints
- Never downgrade a version.
- Keep `version` and `appVersion` identical unless the user explicitly says otherwise.
- Dependency version strings must be exact (e.g. `"0.2.0"`), not ranges.
