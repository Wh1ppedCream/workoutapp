# Branch and CI Policy

`master` is the release source of truth. Day-to-day work belongs on a focused
branch and reaches `master` through a pull request after the hosted checks pass.

## Branches

Use a short, descriptive branch under one of these prefixes:

- `feature/` for product behavior.
- `fix/` for defects and regressions.
- `updates/` for coordinated maintenance or backlog batches.
- `dependency/` for SDK, package, and build-tool maintenance.
- `chore/` for repository-only work.
- `release/` for release preparation.

The Flutter CI workflow runs on pushes to these prefixes so a branch gets
feedback before a pull request is opened. Pull requests targeting `master` run
the same checks again against the proposed merge.

## Required Checks

The following GitHub Actions checks are stable branch-protection contracts:

- `Localization, analyzer, and tests`
- `Release APK`

The quality check regenerates localization files, rejects stale generated
output, analyzes the app and repository tools, analyzes the nested catalog
builder, validates catalog and media fixtures, runs all Flutter tests, and runs
the diagnostics-relay schema tests. The release check builds a disposable,
non-production APK only after quality succeeds.

## Master Ruleset

Create an active repository ruleset named `Protect master`, targeting the
default branch, after the workflow changes have produced both required checks
on a pull request. Configure it to:

- Require changes through a pull request with zero mandatory approvals while
  the repository has a single maintainer.
- Require both checks above and require the branch to be up to date.
- Require all review conversations to be resolved.
- Block force pushes and branch deletion.
- Leave signed commits, linear history, deployments, and merge queue optional
  until the release process explicitly adopts them.
- Keep repository-administrator bypass available only for recovery from a
  GitHub outage or a broken protection rule; ordinary changes still use a PR.

Do not require an outside approval until another regular reviewer exists. A
one-person repository cannot satisfy that policy without weakening review
integrity or locking its maintainer out.

## Actions Security

Every external Action is pinned to a full commit SHA with the reviewed release
tag retained in a comment. Checkout credentials are not persisted, workflow
permissions are explicit, production release remains manual and environment
gated, and untrusted pull requests receive no production secrets.

Dependabot reviews Action pins weekly and Dart dependencies monthly. Its pull
requests use the same checks and are never merged automatically.

After this policy reaches `master`, also configure repository Actions settings
to use read-only workflow permissions by default and require full-length commit
SHA pins. Keep the Pages workflow's explicit `pages: write` and `id-token:
write` permissions because that deployment requires them.
