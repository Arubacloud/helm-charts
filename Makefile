## Aruba Cloud Helm Charts Makefile
# All documentation, packaging, and publishing is handled automatically by the GitHub Actions pipeline.
# No local targets are required.

CHARTS_DIR := charts
DOCS_CMD := helm-docs
PACKAGE_CMD := helm package
INDEX_CMD := helm repo index

.PHONY: docs package index all

# Run all local development steps
all: docs package index

# Generate documentation for all charts (requires helm-docs installed locally)
docs:
	@for dir in $(CHARTS_DIR)/*/ ; do \
		$(DOCS_CMD) --chart-search-root "$$dir" ; \
	done

# Package all charts locally
package:
	@mkdir -p packaged
	@for dir in $(CHARTS_DIR)/*/ ; do \
		$(PACKAGE_CMD) "$$dir" -d packaged ; \
	done

# Generate Helm repo index locally
index:
	@$(INDEX_CMD) packaged --url https://arubacloud.github.io/helm-charts/
