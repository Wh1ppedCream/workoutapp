# Safe Error Handling

Tonos presents failures through privacy-safe categories instead of raw
exceptions. This protects local paths, SQL, URLs, imported data, and platform
details while still giving users a useful next step.

## Shared Boundary

- `lib/services/safe_failure.dart` converts an exception into a
  `SafeFailureKind` and a retryability decision. It never retains the original
  exception or message.
- `lib/l10n/safe_failure_localizations.dart` maps the category to localized
  guidance.
- `lib/widgets/safe_error_view.dart` provides the accessible failed-read state
  and the standard action-failure snackbar.

UI state may retain `SafeFailure`, but must not retain `Object`, an exception
message, or `error.toString()`. Raw exception details must never be interpolated
into `Text`, dialogs, banners, semantics, or snackbars.

## Recovery Rules

### Failed reads

Use `SafeErrorView` when required page or section data cannot be loaded. Pass
the operation-specific localized title and the classified failure. Supply
`onRetry` only for an idempotent read; the widget hides retry automatically
when the failure is not retryable. A retry must clear the old failure, enter a
loading state, and rerun the complete read.

### Failed writes and actions

Keep the current page, user input, and last known good data intact. Use
`safeFailureSnackBar` or combine the existing localized action summary with
`safeFailureMessage`. Do not navigate away, clear fields, report success, or
replace the whole page after a failed save. Features that make optimistic
updates must roll them back before reporting failure.

### Optional data

An optional thumbnail, secondary summary, or enhancement may keep its designed
fallback while retrying independently. Optional failure must not block the
primary workflow. Required data, corrupt state, and failed writes must not be
silently treated as successful optional fallbacks.

## Privacy And Diagnostics

Classification may inspect an exception briefly to choose a category, but the
exception must not escape that boundary. User-facing copy is always sourced
from ARB files. Developer logs should prefer a stable operation code and the
exception runtime type; never log database rows, imported content, local paths,
tokens, or user-entered values. Any future remote diagnostics must follow the
separate relay allowlist and consent policy.

## Adding A Failure Path

1. Decide whether the operation is a required read, a write/action, or an
   optional enhancement.
2. Preserve the last known good state and all recoverable user input.
3. Classify the caught exception immediately with `SafeFailure.classify`, or
   pass it directly to a shared safe presentation helper.
4. For reads, make retries idempotent and reset loading/failure state first.
5. Add localized operation context only when the generic title is insufficient.
6. Test the category, retry visibility, state preservation, and absence of raw
   details.
7. Run the safe-error source contract before merging.
