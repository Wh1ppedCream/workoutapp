# Theme Style Ratchet

Status: one exact production scope is enrolled and CI enforcement is enabled
for that scope. The latest supplied corrected-scope run (2026-09-22) reported
135 files formatted with 0 changes, clean analysis, 321 theme tests, 6
responsive tests, 46 route-boundary tests, and passing enforce-mode ratchet.
This is scoped protection, not full repository styling qualification.

Step 14's new Appearance selector is intentionally not enrolled here even
though its route/device qualification is now user-accepted. The protected
scope remains unchanged: the manifest records additional approvals for current
TonosSurface fingerprints, but no new production file is enrolled merely
because the selector is implemented or manually qualified.

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
blocked, evidence-pending, or qualified. Only TonosSurface is currently
enrolled; the CLI fixture is test-only, not production evidence.

## Existing Report Versus New Enforcement

tools/theme_style_inventory.dart and docs/theme-style-inventory.json are unchanged.
Their --check still means all candidates are assigned, not that styling is
qualified. The new tools/theme_style_ratchet.dart uses a separate version-1
docs/theme-style-ratchet.json file containing exact protected file entries.

The manifest contains one deliberately narrow production scope. An empty run
reports protectedFileCount: 0 and proves no production protection; CI now runs
enforcement against the enrolled scope. Do not broaden enrollment to make a
migration gate green.

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
public release. The single enrolled scope does not imply repository-wide style
coverage.
