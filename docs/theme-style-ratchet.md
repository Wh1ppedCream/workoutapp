# Theme Style Ratchet

Status: three exact production scopes are listed for enforcement. The three
TonosSurfaceTheme fingerprints, 13 workout-record-badge fingerprints, and
three TonosExpansionTileScope fingerprints were mapped and reviewed. On
2026-09-24, the focused inventory/ratchet/CLI/settings/ExpansionTile suite
passed all 52 tests with clean analysis; formatting changed three targeted test
files. The current three-scope report/enforce output matched all approved
fingerprints. This is scoped protection, not full repository styling
qualification.
On 2026-09-25, after the final Current Metrics caller-side
`TonosSurfaceTheme`/`Builder` foreground-scope edit passed targeted
format/analyze/tests and inventory refresh, both report and enforce again
matched the existing three protected scopes. The manifest and enrolled files
did not change; no scope was expanded.

Reviewed TonosSurfaceTheme fingerprints (2026-09-23):

- `b4a7314cb5fe5c1f029c64a1fd626aceeb584dc8b0f9c7416e95eaa2545c3b18`:
  the helper's explicit `Color surface` role.
- `c0c1508f90b9eab20bdd29eeb7eb400591ebb3e8d758f34761a47eb152ee4396`:
  the active `Theme.of(context)` lookup.
- `cf3529f26722b1a59f40a8edb32069d8762cf0c8e0ba9c0df2eba901338652c5`:
  the scoped `Theme` that updates surface and inherited foreground roles.

Each had actual count 1 and expected count 0 in the failing report. Source and
lexer identities were reviewed directly, and the machine-readable manifest now
expects count 1 for each, and the subsequent enforce-mode run passed. The
commands below can be rerun after future changes; do not regenerate approvals
automatically.

Step 14's new Appearance selector is intentionally not enrolled here even
though its route/device qualification is user-accepted. At that checkpoint,
the protected scope remained unchanged and the manifest only added approvals
for current TonosSurface fingerprints. The later badge-file enrollment below
is based on its own per-file evidence, not selector implementation or route
qualification.

The 2026-09-17 implementation pass adds optional shape/elevation forwarding
through the already protected TonosSurface boundary and preserves the
ratchet-recognized style statements. The post-review shape regression fix and
contract-test changes were covered by the corrected-scope verifier run on
2026-09-22 and passed. No new production file was enrolled. Do not
automatically regenerate approvals or treat the new compatibility test as a
substitute for per-file review.

## Eligibility Decision

Interpolated files are explicitly ineligible under the current lexer, including
simple variable interpolation. Do not remove strings or broaden approvals to
bypass this restriction. Parser support is deferred and must cover nested
expressions, escaped dollars, raw strings and styles inside interpolation.

Other production files remain pending per-file Classic qualification. Before
enrollment, record exact path, owner, lexer compatibility, parity evidence and
narrow fingerprint approvals. Classify each proposed file as interpolation-
blocked, evidence-pending, or qualified. `lib/theme/widgets/tonos_surface.dart`,
`lib/theme/widgets/tonos_expansion_tile_scope.dart`, and
`lib/widgets/workout_record_badges.dart` are the three listed production
scopes; the CLI fixture is test-only, not production evidence.

## Existing Report Versus New Enforcement

`tools/theme_style_inventory.dart` and `docs/theme-style-inventory.json` remain
separate from ratchet enforcement. Inventory classification can change without
changing the protected scope, and its `--check` still means all candidates are
assigned, not that styling is qualified. `tools/theme_style_ratchet.dart` uses
the separate version-1 `docs/theme-style-ratchet.json` file containing exact
protected file entries.

The manifest contains three deliberately narrow production scopes. An empty run
reports protectedFileCount: 0 and proves no production protection; CI's
existing ratchet job enforces the listed scopes. Do not broaden enrollment to
make a migration gate green.

## Enrollment

Each file entry requires path (exact lib-relative .dart path), owner, evidence,
and approvals. Each approval requires fingerprint (64-character SHA-256),
positive count, and a nonempty reason. Use explicit reviewed evidence, not
a generic directory classification. Duplicate paths or approvals are errors.
Missing protected files fail, including deliberate renames until reviewed.

Run report mode on a proposed manifest with exact paths and empty approvals
to inspect fingerprints. Review the source alongside the output, then manually
add only justified approvals. The tool never writes or updates a baseline.
File deletion, changed values and stale approvals require review as well as
new findings. There is no wildcard approval.

Existing user-run commands:
```powershell
dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json --report
dart run tools/theme_style_ratchet.dart docs/theme-style-ratchet.json
```

Report mode bypasses count comparison only; malformed schema/files and
unsupported syntax still fail. Enforcement failures use exit 64; filesystem
errors use exit 66. Output includes mode, protected count and sorted file/hash
counts. A failure identifies the path, fingerprint and expected/actual count.

## Identity And Deliberate Limits

The lexer ignores whitespace, nested comments and trailing commas. Strings are
kept as opaque tokens, not scanned as style expressions. Non-raw interpolation
is rejected in protected files rather than masked; such files need parser
support before enrollment. Raw and triple-quoted strings are recognized.

Fingerprints include lexical scope prefix, candidate name and surrounding
statement tokens. Counts preserve duplicate occurrences. This is conservative:
refactoring, declaration renaming, or nearby non-style changes can require
reapproval. It is not a full Dart parser, type resolver, or semantic-equivalence
checker. Aliases, indirect helpers and all possible styling APIs are not
exhaustively detected. The normal analyzer remains necessary.

Only the documented lexical candidate names are protected. Do not claim that
a passed run proves absence of all style debt. Expanding candidate recognition
requires fixtures and explicit baseline review. Report-only inventory remains
the broader discovery mechanism.

## Required Before CI

Run test/theme/theme_style_ratchet_test.dart plus the existing inventory
contract. Demonstrate an approved fixture passing and a changed value failing.
Tests also cover duplicates, comments/formatting, unsupported interpolation,
pending files, malformed approvals and missing protected files.

Enroll only reviewed scopes with qualified evidence. Review aliases and unsupported
syntax before claiming coverage. Extend diagnostics/parser support as needed;
do not work around limitations with broad approvals. Inspect existing CI and
workflow contract tests before adding the job. Never regenerate approvals in CI.

Q1's scoped automated completion is recorded: user-run results, one justified
production scope and the CI rollout are present. Additional production scopes
still require per-file evidence, and interpolation parser support remains
deferred. Current development human/device qualification is accepted in the
Q3 gate; this ratchet neither replaces that qualification nor approves a
public release. The three enrolled scopes do not imply repository-wide style
coverage.

## Step 18 Badge Scope (2026-09-23)

`lib/widgets/workout_record_badges.dart` was added after manual review of the
13 exact count-1 fingerprints supplied by the report-only run. The candidates
are confined to the shared badge renderer and legend: color/style declarations,
token-alpha fill and border, box decorations, text styles, and the theme-based
legend text role. Colors, surface opacities, and shapes resolve through theme
tokens; the source is compatible with the current lexer. The rendered test
checks the token colors, opacity, shape, spacing/density, and legend dots in
Classic/Neo light/dark, and the user-run formatter, analyzer and focused test
passed. The user also visually confirmed that the workout-detail badges no
longer overflow.

The manifest now lists this exact file with those 13 approvals. The user-run
post-change report and enforce commands both passed with two protected files;
the ratchet unit, CLI, and badge tests passed all 15 tests. The separate
user-run analyzer reported no issues for the formatted CLI test. Its six
broader inventory findings remain pending; this narrow lexical baseline does
not mark the file migrated or establish
repository-wide styling qualification.

## Step 18 ExpansionTile Scope (2026-09-24)

`TonosExpansionTileScope` has one clear production owner and report-inventory
findings already classified under the migrated `theme-system` rule. Its tests
cover standard, compact, and dense behavior, inherited ListTile/Icon fields,
and unrelated theme-role preservation across Classic/Neo light/dark. The user
accepted the Preset Generation QA and Food Customization ExpansionTiles. The
September 24 focused suite passed all 22 tests across inventory, ratchet,
ratchet CLI, and ExpansionTile contracts. The report-only fingerprints were
mapped as follows:

- `d2d922eabbf86a9668f71c0e18fe5e42425ff589417c18bc990d583b78db8068`:
  `Theme.of(context)` copies the active inherited theme.
- `01941e88c6ebd2ec01e2857976243cbc5d8f948f7f08bd954ae56c6c457e92c2`:
  the returned `Theme` scopes the shared ExpansionTile defaults.
- `bee7073bcd06b3c316dcda9c6eaa21e3a69b1b97f55708540a5c0547f3d77c54`:
  `Colors.transparent` intentionally hides the ExpansionTile divider.

These exact count-1 approvals are in the canonical manifest. The current
three-scope report and enforce run passed on 2026-09-24; the earlier two-scope
result is historical. Rerun these commands after future manifest changes.
