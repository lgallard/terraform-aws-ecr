# ECR Feature Discovery Cron Migration Plan

> **For Hermes:** Use this document to migrate `.github/workflows/feature-discovery.yml` to a Hermes cron job in controlled phases.

**Goal:** Replace the GitHub Actions feature discovery workflow with a Hermes cron job that analyzes AWS provider ECR changes, updates the in-repo tracker JSON, reports back to Telegram, and uses the local `gh` CLI for GitHub issue handling.

**Architecture:** Run the automation from the Terraform Hermes profile with `workdir=/Users/lgallard/git/lgallard/terraform-aws-ecr`. Keep the state file in `.github/feature-tracker/ecr-features.json`. Use a report-first rollout: validate the logic manually, then create the cron job, then remove the GitHub workflow after successful shadow runs.

**Tech Stack:** Hermes cron jobs, terminal/file/web tools, `gh` CLI, in-repo JSON tracker, Terraform module source tree.

---

## Scope and invariants

- Keep state in: `.github/feature-tracker/ecr-features.json`
- Use local `gh` CLI for issue listing/creation/editing
- Deliver summaries back to the Terraform Telegram thread
- Keep the cron workdir pinned to the repository root
- Start in report-first mode; do not remove the GitHub workflow until the cron path is validated
- If `gh auth status` fails, the run must degrade to report-only mode instead of failing the scan

---

## Phase 1 — Local one-shot reproduction

### Objective

Reproduce the workflow logic in Hermes without scheduling it yet.

### Inputs to preserve from the GitHub workflow

- Weekly cadence equivalent to `0 0 * * 0`
- Optional provider version override
- Analysis categories:
  - new features
  - deprecations
  - bug fixes
- Deduplication against existing tracker state
- GitHub issue handling via `gh`
- Summary output for humans

### Tracker handling rules

The tracker file currently has usable structure but inconsistent history. During migration, Hermes should preserve the file and update it conservatively.

#### Required top-level sections

- `metadata`
- `scan_history`
- `current_implementation`
- `discovered_features`
- `issues_created`
- `current_scan`
- `statistics`

#### Update rules

1. Read the current JSON before analysis.
2. Preserve historical content unless there is a clear schema corruption fix.
3. Update `metadata.last_scan`, `metadata.provider_version`, and `metadata.scan_count`.
4. Append a new entry to `scan_history`.
5. Refresh `current_scan` with the latest summary.
6. Update `discovered_features` only for genuinely new or materially changed findings.
7. Add to `issues_created` only after confirming issue creation with `gh`.
8. Recompute `statistics` conservatively; do not invent totals that cannot be derived from the file.
9. Never delete historical findings during Phase 1.
10. If the JSON is malformed or internally inconsistent, report it explicitly before writing any update.

#### Deduplication rules

Treat a finding as already tracked if all of the following materially match an existing record:

- category (`new_resource`, `new_argument`, `new_data_source`, `deprecated_item`, `bug_fix`)
- AWS resource or data source name
- argument name, if applicable
- same underlying implementation gap or provider fix

Treat a GitHub issue as already tracked if any of the following match:

- exact issue number recorded in tracker
- exact issue URL recorded in tracker
- existing open issue with matching normalized title or same feature key

---

## Phase 1 Hermes prompt draft

Use this as the basis for the manual one-shot run and later the cron job.

```text
You are running automated feature discovery for the terraform-aws-ecr module from the local repository checkout.

Repository root: /Users/lgallard/git/lgallard/terraform-aws-ecr
State file: .github/feature-tracker/ecr-features.json
GitHub repository: lgallard/terraform-aws-ecr

Primary objective:
Compare the current terraform-aws-ecr module implementation against current AWS provider ECR capabilities and identify:
1. New features not implemented in the module
2. Deprecations affecting the module
3. Important ECR-related bug fixes or behavior changes in the provider

Execution rules:
- Work only inside the repository workdir.
- Read the existing tracker JSON first and use it as the source of historical truth.
- Be conservative: avoid false positives and avoid duplicate issues.
- Focus only on ECR-related provider changes relevant to this module.
- Use the local gh CLI for GitHub issue operations.
- If `gh auth status` fails, continue in report-only mode and do not fail the run.
- If you update the tracker file, keep the JSON valid and preserve historical data.
- Do not commit or push changes during Phase 1.

Process:
1. Read `.github/feature-tracker/ecr-features.json`.
2. Check `gh auth status`.
3. Determine the provider version to analyze:
   - use an explicit override if supplied
   - otherwise use `latest`
4. Inspect the module implementation, including at least:
   - `main.tf`
   - `repository.tf` if present
   - `variables.tf`
   - `outputs.tf`
   - `modules/**`
5. Inspect AWS provider ECR documentation and recent ECR-related change notes.
6. Build an implementation inventory of current resources, data sources, major arguments, and module patterns.
7. Compare provider capabilities against the module.
8. Filter out already tracked findings from the JSON tracker.
9. Classify net-new findings as:
   - new_resource
   - new_argument
   - new_data_source
   - deprecated_item
   - bug_fix
10. For each significant finding, record:
   - title
   - category
   - AWS object name
   - provider version or version range if known
   - why it matters
   - module impact
   - implementation complexity
   - priority
   - links to supporting documentation
11. If `gh` is authenticated:
   - list existing relevant issues first
   - avoid duplicates
   - create issues only for significant net-new findings
   - capture issue number and URL
12. Update the tracker JSON conservatively.
13. Produce a final summary including:
   - provider version analyzed
   - whether gh auth was available
   - findings by category
   - issues created or skipped
   - tracker file updated or not
   - recommended next actions

Output requirements:
- Provide a concise executive summary first.
- Then provide a structured findings list.
- Then provide issue actions taken.
- Then provide tracker update details.
- If nothing new is found, say so clearly.
```

---

## Manual one-shot validation flow

### Step 1: Authentication check

Run and record:

```bash
gh auth status
```

Expected outcomes:
- If authenticated: issue handling path can be validated
- If unauthenticated: proceed in report-only mode for the first run

### Step 2: Dry local analysis

Run the prompt once in the Terraform Hermes profile against the repo workdir.

Validation points:
- Reads tracker successfully
- Reads module files successfully
- Produces sensible findings
- Does not crash if `gh` auth is missing

### Step 3: Tracker validation

After the run, verify:
- JSON remains parseable
- historical sections still exist
- only expected fields changed
- no duplicate or contradictory entries were introduced

### Step 4: GitHub issue validation

If authenticated:
- `gh issue list` works
- issue dedupe logic finds relevant existing issues
- optional controlled issue creation succeeds

If unauthenticated:
- final summary explicitly says issue creation was skipped due to auth

### Step 5: Output quality review

Review whether the summary is actually useful:
- clear signal/noise ratio
- specific, actionable findings
- evidence-backed claims
- no duplicate rediscovery spam

### Step 6: Cutover readiness decision

Only proceed to cron creation when all are true:
- manual run succeeded
- tracker update behavior is acceptable
- report quality is good enough
- `gh` behavior is understood

---

## Phase 2 — Enable GitHub issue handling

### Objective

Make `gh`-based issue management reliable enough for unattended cron runs.

### Checklist

1. Authenticate with `gh auth login`
2. Verify with `gh auth status`
3. Verify repo access:
   - `gh repo view lgallard/terraform-aws-ecr`
   - `gh issue list`
4. Validate duplicate detection against existing issues
5. Decide whether cron-created issues should assign `@me`, apply labels, or stay unassigned

---

## Phase 3 — Hermes cron job

### Current Terraform profile cron job

A report-first Hermes cron job already exists for this module:

- Job ID: `d070640e6150`
- Name: `terraform-aws-ecr feature discovery`
- Schedule: `30 7 * * 1` (Monday 07:30)
- Workdir: `/Users/lgallard/git/lgallard/terraform-aws-ecr`
- Delivery: Terraform Telegram ECR topic (`telegram:-1003886548288:248`)
- Profile: `terraform-research`
- Mode: read-only discovery/reporting

Current safety behavior:

- does not edit repository files
- does not create, edit, close, label, or comment on GitHub issues/PRs
- aborts if `git status --short` is dirty at start
- reports triage-ready issue suggestions instead of mutating GitHub

### Initial operating mode

- Report-first
- No auto-commit
- No issue creation
- No workflow removal yet

### Validation

- Keep the job enabled in shadow mode
- Trigger a manual run after the repo worktree is clean
- Confirm Terraform Telegram delivery
- Confirm the report is useful and not noisy
- Confirm `gh` read-only issue lookup behavior
- Only then consider issue-creation or tracker-update automation

---

## Phase 4 — Shadow run and cutover

### Objective

Run Hermes cron alongside the GitHub workflow long enough to build confidence.

### Exit criteria

- Hermes results are stable
- Findings quality is acceptable
- Duplicate issue handling works
- Tracker writes are acceptable

After that:
1. Remove `.github/workflows/feature-discovery.yml`
2. Update any docs that reference `gh workflow run feature-discovery.yml`
3. Keep monitoring the first few cron executions

---

## Manual validation notes — 2026-06-05

### Repository and auth checks

- `gh auth status` succeeded for account `lgallard`.
- `gh repo view lgallard/terraform-aws-ecr` returned `viewerPermission: ADMIN`.
- Existing open issues checked:
  - `#182` — Migrate feature discovery workflow to Hermes cron
  - `#181` — Simplify CI by removing Terratest workflow
  - `#112` — Dependency Dashboard

### Existing cron status

The Terraform-profile cron job already exists and last ran successfully at the scheduler level, but the run aborted discovery because the primary checkout was dirty:

```text
?? docs/feature-discovery-cron-migration.md
```

That file should be committed through this worktree or removed from the primary checkout before rerunning the cron job.

### Provider/source-backed inspection

Local provider schema inspection was run with Terraform in the worktree:

```bash
terraform init -backend=false -input=false
terraform providers schema -json
```

The installed provider schema exposed these current ECR resources:

- `aws_ecr_account_setting`
- `aws_ecr_lifecycle_policy`
- `aws_ecr_pull_through_cache_rule`
- `aws_ecr_pull_time_update_exclusion`
- `aws_ecr_registry_policy`
- `aws_ecr_registry_scanning_configuration`
- `aws_ecr_replication_configuration`
- `aws_ecr_repository`
- `aws_ecr_repository_creation_template`
- `aws_ecr_repository_policy`
- `aws_ecrpublic_repository`
- `aws_ecrpublic_repository_policy`

And these ECR data sources:

- `aws_ecr_authorization_token`
- `aws_ecr_image`
- `aws_ecr_images`
- `aws_ecr_lifecycle_policy_document`
- `aws_ecr_pull_through_cache_rule`
- `aws_ecr_repositories`
- `aws_ecr_repository`
- `aws_ecr_repository_creation_template`
- `aws_ecrpublic_authorization_token`
- `aws_ecrpublic_images`

Terraform Registry MCP provider lookup reported latest `hashicorp/aws` as `6.49.0`.

The upstream provider changelog had recent ECR-relevant entries including:

- `aws_ecr_account_setting`: `BLOB_MOUNTING` account setting support
- `aws_ecr_pull_time_update_exclusion`: new resource
- `aws_ecr_repository`: `image_tag_mutability_exclusion_filter` and `IMMUTABLE_WITH_EXCLUSION` / `MUTABLE_WITH_EXCLUSION`
- `aws_ecr_repository_creation_template`: `image_tag_mutability_exclusion_filter` and `CREATE_ON_PUSH`
- `aws_ecr_lifecycle_policy_document`: storage-class lifecycle arguments
- `aws_ecrpublic_images`: new data source

### Candidate findings for the next cron/manual report

The tracker already mentions several older findings, especially `image_tag_mutability_exclusion_filter`, `aws_ecr_repository_creation_template`, ECR data sources, and account settings. Net-new or under-tracked candidates observed during manual inspection:

1. `aws_ecr_pull_time_update_exclusion`
   - Not found in the tracker text.
   - Not implemented in the module inventory.
   - Candidate feature issue if relevant to module scope.

2. `BLOB_MOUNTING` for `aws_ecr_account_setting`
   - Not found in the tracker text.
   - Module already has account setting support, so this may be a low-complexity variable validation/default extension.

3. Pull-through cache rule arguments
   - Provider schema includes `custom_role_arn` and `upstream_repository_prefix`.
   - The submodule currently exposes `credential_arn` but not these two arguments.

4. Storage-class lifecycle policy document support
   - Changelog mentions `target_storage_class` and `storage_class` for `aws_ecr_lifecycle_policy_document`.
   - The module uses lifecycle policy JSON/string patterns; this is likely a documentation/example or helper enhancement, not necessarily a core resource gap.

## Immediate next actions

1. Commit this migration/validation note through the feature-discovery cron worktree.
2. Remove the copied untracked migration doc from the primary checkout so the existing cron job no longer aborts on dirty status.
3. Rerun cron job `d070640e6150` manually and review the delivered report.
4. Keep `.github/workflows/feature-discovery.yml` during shadow mode.
5. After stable useful cron reports, decide whether to remove the GitHub workflow and/or allow controlled issue creation.
