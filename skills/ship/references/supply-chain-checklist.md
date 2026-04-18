# Supply Chain Security Checklist

Use this checklist when auditing or hardening the supply chain of an agent ecosystem project.

---

## 1. Lock File Verification

Lock files ensure reproducible builds. Without them, SBOM and provenance are meaningless because build inputs are unstable.

### Checks

- [ ] Lock file exists in the repository root
- [ ] Lock file is committed to version control (not gitignored)
- [ ] CI uses locked install commands (see below)
- [ ] `npm install` / `pip install` (unlocked) is NOT used in CI

### CI Configuration

**npm:**
```yaml
steps:
  - run: npm ci
    # npm ci installs from package-lock.json exactly.
    # Never use `npm install` in CI — it can update the lock file.
```

**Python (pip with hashes):**
```yaml
steps:
  - run: pip install --require-hashes -r requirements.txt
    # --require-hashes enforces that every dependency has a verified hash.
    # Generate hashed requirements: pip-compile --generate-hashes requirements.in
```

**Python (Poetry):**
```yaml
steps:
  - run: poetry install --no-root
    # Poetry uses poetry.lock by default. Verify it is committed.
```

**pnpm:**
```yaml
steps:
  - run: pnpm install --frozen-lockfile
```

**Yarn:**
```yaml
steps:
  - run: yarn install --frozen-lockfile
```

---

## 2. SBOM Generation

Generate a Software Bill of Materials on every release. Publish it as a release artifact.

### Checks

- [ ] SBOM generation is part of the CI/CD pipeline
- [ ] SBOM is published alongside each release
- [ ] At least one standard format is used (SPDX or CycloneDX)
- [ ] SBOM covers all runtime dependencies

### Commands

**Syft (recommended for most projects):**
```bash
# Generate SPDX JSON
syft packages . -o spdx-json > sbom-spdx.json

# Generate CycloneDX JSON
syft packages . -o cyclonedx-json > sbom-cdx.json
```

**Trivy (combined vulnerability scan + SBOM):**
```bash
# Generate SBOM
trivy fs . --format spdx-json --output sbom-trivy.json

# Scan existing SBOM for vulnerabilities
trivy sbom sbom-cdx.json
```

**CycloneDX CLI (conversion and validation):**
```bash
# Convert between formats
cyclonedx-cli convert --input-file sbom-spdx.json --output-file sbom-cdx.json

# Validate SBOM
cyclonedx-cli validate --input-file sbom-cdx.json
```

### CI Integration Example

```yaml
# Add to your release workflow
- name: Generate SBOM
  run: |
    syft packages . -o spdx-json > sbom-spdx.json
    syft packages . -o cyclonedx-json > sbom-cdx.json

- name: Upload SBOM as release artifact
  uses: softprops/action-gh-release@{{SHA_PIN}}
  with:
    files: |
      sbom-spdx.json
      sbom-cdx.json
```

### Format Selection

| Standard | Strengths | Best For |
|----------|-----------|----------|
| SPDX | ISO/IEC 5962 standard; GitHub native export | Compliance-heavy projects; GitHub ecosystem |
| CycloneDX | Rich component relationships; ML/AI asset support | Agent/AI projects needing semantic detail |

For agent ecosystem projects, CycloneDX is generally preferred due to its richer support for service and AI asset descriptions. Use both if compliance requires SPDX.

---

## 3. GitHub Actions SHA Pinning

Tags can be overwritten. Commit SHAs cannot. Pin all third-party actions to full commit SHA.

### Checks

- [ ] Every `uses:` directive in workflow files references a full 40-character commit SHA
- [ ] A comment after each SHA records the version tag for human readability
- [ ] No workflow uses tag-only references (e.g., `@v4`) for third-party actions

### Examples

**Incorrect (tag reference — can be overwritten):**
```yaml
- uses: actions/checkout@v4
- uses: actions/setup-node@v4
- uses: pypa/gh-action-pypi-publish@release/v1
```

**Correct (SHA pinned with version comment):**
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
- uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
- uses: pypa/gh-action-pypi-publish@81e9d935c883d0b210363ab89cf05f3894778450 # release/v1
```

### Finding SHAs

```bash
# Look up the commit SHA for a specific tag
git ls-remote --tags https://github.com/actions/checkout.git | grep "v4.1.1"
```

Or navigate to the action's releases page on GitHub and copy the full commit SHA from the tag.

### GITHUB_TOKEN Permissions

Always set explicit, minimal permissions. Do not rely on defaults.

```yaml
permissions:
  contents: read        # Read repository content
  packages: write       # Only if publishing packages
  id-token: write       # Only if using OIDC / Trusted Publishing
  # All other permissions default to 'none'
```

### Checks

- [ ] Top-level `permissions` block is present in every workflow file
- [ ] Permissions are set to the minimum required for each job
- [ ] `contents: write` is only granted to jobs that create releases or push commits
- [ ] `id-token: write` is only granted to jobs that perform OIDC authentication

---

## 4. Trusted Publishing (npm)

OIDC Trusted Publishing eliminates long-lived publish tokens. The CI environment proves its identity to the registry via a short-lived OIDC token.

### Checks

- [ ] No long-lived npm tokens are stored in repository secrets
- [ ] Publishing workflow uses OIDC (`id-token: write` permission)
- [ ] `npm publish --provenance` flag is used
- [ ] npm account has Trusted Publishing configured for the repository

### Workflow Example

```yaml
# .github/workflows/publish.yml
name: Publish to npm
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      id-token: write     # Required for OIDC
      contents: read
    steps:
      - uses: actions/checkout@{{CHECKOUT_SHA}} # {{CHECKOUT_VERSION}}
      - uses: actions/setup-node@{{SETUP_NODE_SHA}} # {{SETUP_NODE_VERSION}}
        with:
          node-version: 20
          registry-url: https://registry.npmjs.org
      - run: npm ci
      - run: npm publish --provenance --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Consumer Verification

Consumers can verify provenance of published packages:

```bash
npm audit signatures
```

Note: Provenance proves where and how a package was built. It does NOT prove the code is free of vulnerabilities.

---

## 5. Trusted Publishing (PyPI)

PyPI supports OIDC Trusted Publishing via GitHub Actions. No password or API token is needed.

### Checks

- [ ] No long-lived PyPI tokens are stored in repository secrets
- [ ] Publishing workflow uses OIDC (`id-token: write` permission)
- [ ] PyPI project has a Trusted Publisher configured for the GitHub repository
- [ ] A dedicated `pypi` environment is used in the workflow

### Workflow Example

```yaml
# .github/workflows/publish.yml
name: Publish to PyPI
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      id-token: write     # Required for OIDC
    environment: pypi      # Must match the environment configured in PyPI
    steps:
      - uses: actions/checkout@{{CHECKOUT_SHA}} # {{CHECKOUT_VERSION}}
      - uses: actions/setup-python@{{SETUP_PYTHON_SHA}} # {{SETUP_PYTHON_VERSION}}
        with:
          python-version: "3.12"
      - run: pip install build
      - run: python -m build
      - uses: pypa/gh-action-pypi-publish@{{PYPI_PUBLISH_SHA}} # {{PYPI_PUBLISH_VERSION}}
        # No password parameter needed — OIDC handles authentication
```

### Setup Steps

1. Go to your PyPI project's "Publishing" settings.
2. Add a new Trusted Publisher.
3. Enter your GitHub repository owner, name, workflow filename, and environment name (`pypi`).
4. Remove any stored API tokens from GitHub repository secrets.

---

## 6. Dependency Review

Run automated dependency review on pull requests to catch new vulnerabilities before they are merged.

### Checks

- [ ] `actions/dependency-review-action` is configured in PR workflows
- [ ] Failure threshold is set to `moderate` or stricter
- [ ] Dependabot or Renovate is enabled for automated dependency updates

### Workflow Example

```yaml
# .github/workflows/dependency-review.yml
name: Dependency Review
on: pull_request

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@{{CHECKOUT_SHA}} # {{CHECKOUT_VERSION}}
      - uses: actions/dependency-review-action@{{DEP_REVIEW_SHA}} # {{DEP_REVIEW_VERSION}}
        with:
          fail-on-severity: moderate
```

### Dependabot Configuration

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"        # or "pip", "github-actions", etc.
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

## 7. Container Image Security

If the project publishes Docker images, apply scan-sign-verify before release.

### Checks

- [ ] Trivy (or equivalent) scans the image in CI before publishing
- [ ] CI fails on HIGH or CRITICAL severity findings
- [ ] Image is signed with Cosign (keyless/OIDC)
- [ ] Documentation includes consumer verification instructions

### Commands

```bash
# 1. Build
docker build -t {{REGISTRY}}/{{IMAGE_NAME}}:{{VERSION}} .

# 2. Scan — fail on HIGH/CRITICAL
trivy image {{REGISTRY}}/{{IMAGE_NAME}}:{{VERSION}} \
  --severity HIGH,CRITICAL --exit-code 1

# 3. Sign (keyless via OIDC)
cosign sign --yes {{REGISTRY}}/{{IMAGE_NAME}}:{{VERSION}}

# 4. Consumer verification
cosign verify {{REGISTRY}}/{{IMAGE_NAME}}:{{VERSION}} \
  --certificate-identity=https://github.com/{{ORG}}/{{REPO}}/.github/workflows/release.yml@refs/tags/{{VERSION}} \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

### Documentation for Consumers

Include this in your README or installation docs:

```markdown
## Verifying Image Signatures

This image is signed with [Cosign](https://github.com/sigstore/cosign).
To verify:

\`\`\`bash
cosign verify {{REGISTRY}}/{{IMAGE_NAME}}:{{VERSION}} \
  --certificate-identity=https://github.com/{{ORG}}/{{REPO}}/.github/workflows/release.yml@refs/tags/{{VERSION}} \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
\`\`\`
```

---

## Quick Audit Summary

Use this summary to report supply chain audit results:

```
## Supply Chain Audit — {{PROJECT_NAME}}

| Category | Status | Notes |
|----------|--------|-------|
| Lock file | {{PASS/FAIL}} | {{NOTES}} |
| CI locked install | {{PASS/FAIL}} | {{NOTES}} |
| SBOM generation | {{PASS/FAIL}} | {{NOTES}} |
| Trusted Publishing | {{PASS/FAIL}} | {{NOTES}} |
| Actions SHA pinning | {{PASS/FAIL}} | {{NOTES}} |
| GITHUB_TOKEN scoping | {{PASS/FAIL}} | {{NOTES}} |
| Secret scanning | {{PASS/FAIL}} | {{NOTES}} |
| Dependency review | {{PASS/FAIL}} | {{NOTES}} |
| Container scanning | {{PASS/FAIL/NA}} | {{NOTES}} |
| Container signing | {{PASS/FAIL/NA}} | {{NOTES}} |
```
