# Tonos Expressive visual remediation

This folder records the post-baseline visual-readiness audit and narrowly
scoped remediation performed for the Expressive candidate. Remediated screens
remain candidates for human visual review; this work does not grant new visual
approvals. The October 12 supplement below is the current status; dated build,
capture, and validation records retain their original historical provenance.

## Latest working-tree status — 2026-10-12

This status supersedes any undated use of “current” in the October 10 closeout
sections below. Historical build and screenshot manifests remain valid only
for their recorded source revisions.

- Branch `feature/expressive-visual-polish`; HEAD remains the pushed baseline
  `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`. The remote
  `origin/feature/classic-m3e` still points to that SHA; the feature branch has
  no upstream.
- Working tree: **61 tracked modifications, 2,194 untracked paths, 0 staged**.
  Preserve all existing work. The current changed/untracked Dart manifest has
  56 paths and fingerprint
  `62e10fc222ec639839fe76836764647b3f3331835e4e92993952b9b82112bfc0`;
  details are in [`current-source-snapshot.md`](current-source-snapshot.md).
- The latest source follow-up refined Expressive Onboarding Included Equipment
  surfaces and Skip Setup dialog. Focused validation recorded **67 passing
  tests across seven files**; it did not include a full-suite run.
- There has been no device build/capture after that source change. The latest
  known Pixel 7 build is the October 11 APK SHA
  `91AFB3AE4E7171D2F2A7E1E144756A6C75C88B89B9161D66EF7E41C39345DCB3`, which
  predates the change. The October 10 screenshots remain historical, not
  current-source proof.
- Five B candidates are in the latest review queue: Onboarding; Preset
  Generation QA; Analytics Dashboard / Weekly Sets Overview; Dashboard root;
  and plan-specific Flow Methods editor. No approvals changed. Exact 55-page
  aggregate counts remain unresolved; the separate 24-route dossier is
  15 approved / 9 pending.
- The isolated preview database/preferences were last backed up, restored,
  and hash-verified after the October 11 device audit. They were not checked
  again on October 12. Production data was not touched.

## Baseline checkpoint

- Original branch: `feature/classic-m3e`
- Original HEAD: `ab18ed8cab5582c8449e13724afae3c4b74ebeea`
- Baseline commit: `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`
- Baseline commit message: `checkpoint: preserve Tonos Expressive visual review and audit baseline`
- Remote: `origin` (`https://github.com/Wh1ppedCream/workoutapp.git`)
- Push confirmation: `origin/feature/classic-m3e` resolved to the baseline commit after push.
- Remediation branch: `feature/expressive-visual-polish` (local, created from the pushed baseline).
- Baseline contents: reviewed tracked application, localization, test, inventory, and route-ledger changes plus five new implementation files and 24 focused tests.

### Deliberately local / excluded from the public checkpoint

- The initial 2026-10-10 evidence package, including screenshots and UI
  hierarchy captures, remains local at
  `docs/proposals/tonos-expressive-visual-evidence/current-candidate/20261010-build-e87b4eee0383/`,
  per the user's instruction. It records 92 verified screenshots (47 light,
  45 dark), one failed lockscreen probe, and one redundant excluded probe.
- The post-remediation candidate screenshots and UI hierarchy captures remain
  local at
  [`post-remediation-evidence/20261010-build-79e1ad79/`](post-remediation-evidence/20261010-build-79e1ad79/README.md).
  They include standard-build route captures and a separately identified
  onboarding capture build; see the evidence README for their distinct
  provenance.
- The October 10 post-remediation captures for the dirty source tree at that
  time are local at
  [`post-remediation-evidence/20261010-build-2e4a2bd4-current/`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md).
  These were rebuilt from `lib/expressive_preview_main.dart`; they supersede
  earlier post-remediation captures for the overlapping routes. Captures are
  not included in the public baseline, per the user's instruction.
- A prior build that used the wrong app entrypoint is preserved and clearly
  labeled as diagnostic only at
  [`post-remediation-evidence/20261010-build-bbd53b9c-wrong-entrypoint-diagnostic/`](post-remediation-evidence/20261010-build-bbd53b9c-wrong-entrypoint-diagnostic/).
  It is not used as current-source visual evidence.
- Historical proposal screenshots, clips, and hierarchy captures remain in
  their existing local folders; they were not swept into the public baseline.
- The 24-route dossier remains local because eight of its links target captures
  excluded from the public checkpoint. The committed 55-archetype route ledger
  records the current approval inventory and its known count-boundary caveat.
- Generated and temporary/unowned material remains local: `android/build/`,
  `tmp/`, `incoming/exercise_media_batch_009/`, `flutter_06.png`,
  `test/theme/widgets/failures/`, and the unverified Flow Editor golden-test
  bundle under `test/theme/widgets/auto_preset_flow_panels_golden_test.dart`
  and `test/goldens/expressive_flow_editor/`.

The baseline commit did not run a new full-suite qualification and does not
claim release readiness. The repository had no staged paths before the
checkpoint. All excluded local work was preserved in place.

## Audit and remediation deliverables

- `visual-readiness-audit.md` — current-source route classifications, evidence
  references, concrete defects, and prioritized review gaps.
- `implementation-ledger.md` — scoped changes, tests, render checks, and
  remaining limitations.
- `current-source-snapshot.md` — October 12 working-tree manifest and status,
  plus the explicitly historical October 10 build provenance, device identity,
  and preview-data restoration record.
- `responsive-validation.md` — only viewports and text scales actually tested.
- [`post-remediation-evidence/20261010-build-2e4a2bd4-current/`](post-remediation-evidence/20261010-build-2e4a2bd4-current/README.md)
  — October 10 candidate-source Pixel 7 light/dark evidence for Muscle Rankings, Body Part
  / Muscle Mapping, Exercise Editor and its caller-scoped Catalog picker,
  Weekly Sets overview/detail routes, Database Settings, and Optimized
  Workout Settings. All media remains local.
- `visual-review-queue.md` — screens and states ready for the user's review.
- [`REMEDIATION_HANDOFF.md`](REMEDIATION_HANDOFF.md) — October 10 closeout with
  an October 12 state supplement; the current five-item review queue is in
  [`visual-review-queue.md`](visual-review-queue.md).

## Candidate state on 2026-10-10 (historical) and qualification boundary

- Candidate source remains on local branch `feature/expressive-visual-polish`
  at baseline HEAD `9ac12f9f234d2edf1ee0c7a8154c875d3243f51f`; the remediation
  itself is uncommitted and unpushed.
- The current isolated-preview APK was built from the dedicated
  `lib/expressive_preview_main.dart` entrypoint. Its SHA-256 is
  `2e4a2bd46a6aca16f6f0e46cee01b93f0df54855cdbcc1ec29427547539cb5c7`.
- Source remediation is recorded against a dirty working tree of 19 tracked
  Dart files. The baseline checkpoint remains pushed; remediation itself is
  uncommitted and unpushed.
- No user visual approvals or master inventory classifications were changed.
- Technical results, remaining full-suite failures, responsive evidence gaps,
  and source/build provenance are recorded separately; this package does not
  claim release qualification.

