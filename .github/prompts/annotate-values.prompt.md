---
agent: agent
description: Update values.yaml annotations so helm-docs regenerates an accurate README
---

# Annotate values.yaml for helm-docs

You are reviewing and improving the `# --` helm-docs annotations on a chart's `values.yaml`.

## Task

1. Open the `values.yaml` for the chart the user specifies (or the currently open file).
2. For every key that is missing a `# --` annotation above it, add a concise, accurate description.
3. For every key that has a vague or empty annotation, improve it.
4. Do **not** change any values — only add or update comment lines starting with `# --`.
5. For nested objects, annotate the parent key and each leaf key separately.
6. For keys that accept an existing Secret reference (`fieldNameFrom.secretKeyRef`), use this standard annotation:
   ```yaml
   # -- Alternative to `fieldName`. If set, references a key in an existing Secret and `fieldName` is ignored.
   ```

## Output

Return only the modified `values.yaml` with updated annotations in-place.

## Constraints
- Keep descriptions under 120 characters.
- Use present tense ("Sets the ...", "Enables ...", "Path to ...").
- Do not add markdown or HTML inside annotation strings.
- Do not reorder or restructure the YAML.
