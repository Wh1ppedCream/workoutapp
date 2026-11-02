# Native Android migration — scheduled follow-up

Status: **planned maintenance, not an implemented dependency upgrade**.
Schedule this before the next major Flutter/AGP upgrade; review readiness at the
next dependency-maintenance checkpoint. The owner/developer can continue on the
pinned toolchain while its qualification remains current. Qualification evidence
and any remaining device limits belong to the [parent report](README.md).

## Pinned starting point

- Flutter 3.47.5 / Dart 3.13.4, through `tools/tonos.ps1`.
- Gradle 9.3.1 with the committed distribution checksum; AGP 9.1.0; legacy KGP 2.4.0.
- CI JDK 17, local JDK 21. App Java/Kotlin output remains JVM 11.
- Compile/target SDK 36, minimum SDK 24, NDK 28.2.13676358.
- Existing signing identities, package IDs, database names and approved UI remain stable.

The locked native-plugin inventory was inspected, including conditional plugin
application rather than just declared classpaths:

| Plugin | Locked version | Relevant current behavior |
| --- | --- | --- |
| `file_picker` | 11.0.2 | Declares a legacy Kotlin classpath but does not apply KGP on AGP 9. The project opts this module into the same-version built-in Kotlin plugin while the global opt-out remains. |
| `mobile_scanner` | 7.0.1 | Applies legacy KGP. Its ML Kit dependencies also need the app-owned registrar-constructor rule under strict R8. |
| `package_info_plus` | 8.3.1 | Applies legacy KGP; validate diagnostics/package metadata after migration. |
| `shared_preferences_android` | 2.4.13 | Applies legacy KGP; preserve existing preference keys, backend compatibility and queued writes. |
| `path_provider_android`, `sqflite_android`, `sqlite3_flutter_libs`, lifecycle plugin | See lockfile | Audit Android DSL compatibility too, without misclassifying Java-only modules as Kotlin migrations. |
| SDK `integration_test` | Flutter-pinned, development only | Include in debug/device-test compilation; keep it out of release registration. |

Flutter's plugin warning can detect a declared classpath even when that module
does not apply it. Inspect the resolved build before deciding a plugin is ready.

## Ordered implementation batches

1. **Inventory candidate versions and compatibility.** Read upstream release
   notes and Gradle scripts again at execution time. Record supported Flutter,
   AGP, Gradle, Kotlin and SDK levels. Use small, reversible source checkpoints;
   avoid a blanket `pub upgrade`. Never edit the Pub cache or generated registrant.
2. **Update the native-plugin cohort incrementally.** Prioritize the scanner's
   confirmed AGP/R8 integration, then package-info/preferences and the picker
   bridge. Preserve public Dart APIs and storage behavior. Validate each batch
   before enabling global built-in Kotlin. Upstream scanner release notes are
   useful evidence, not proof that an upgrade is safe for this app.
3. **Migrate the application and remaining modules.** Remove applied legacy
   `kotlin-android` plugins once their modules are ready; retain the app's typed
   `compilerOptions` and JVM 11 target. Enable built-in Kotlin and the new DSL
   explicitly. With the pinned Flutter migrator, merely deleting the opt-out
   properties can cause `false` to be added again: verify the resulting files
   and build. Remove the file-picker module hook and same-version opt-in plugin
   declaration only when global built-in Kotlin covers it. Retire the root
   legacy KGP declaration when no module needs it.
4. **Retire compatibility rules individually.** Confirm upstream consumer rules
   retain ML Kit's reflection constructors before removing the app-owned rule.
   Keep the generated-release artifact guard. Audit transitive Android support
   dependencies before turning off Jetifier. Revisit Kotlin incrementality only
   after testing the actual C:-Pub-cache / E:-checkout Windows layout.
5. **Promote only after qualification.** Record exact versions, commands,
   artifact hashes, device observations and data comparisons. Roll back a failed
   source batch to its checkpoint without resetting databases or preferences.

These batches implement the official
[Flutter app migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers),
[plugin migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)
and [Android module-by-module approach](https://developer.android.com/build/migrate-to-built-in-kotlin#module-by-module-migration).
Module-level pilots are possible; global enablement still requires the complete
active plugin set to be compatible. Android documents the built-in-Kotlin opt-out
as temporary before AGP 10.

## Retirement criteria

| Setting / shim | Keep until |
| --- | --- |
| `android.builtInKotlin=false`, `android.newDsl=false` | All applied plugins/app code support built-in Kotlin/new public DSL; explicit enablement passes both host builds and physical release checks. |
| File-picker built-in-Kotlin hook and settings declaration | Global migration includes the picker; signed-release native file selection/cancel works without the hook. |
| Legacy root KGP declaration | No active module applies legacy KGP, including debug/test configurations. |
| ML Kit registrar constructor rule | Upstream rules replace it; the minified-output guard passes without it and fresh-permission camera initialization works on the phone. Do not disable strict R8 or minification to pass this gate. |
| `android.enableJetifier=true` | Resolved dependency audit and debug/release builds show it is unnecessary; native smoke tests pass with it disabled. |
| `kotlin.incremental=false` | First and repeated Windows builds pass in the existing cross-volume layout without path-cache failures. Linux CI alone does not qualify its removal. |
| Gradle/Kotlin memory and worker limits | These are workstation safeguards, not migration debt. Keep them unless measurements justify an adjustment. |

The [Kotlin cache documentation](https://kotlinlang.org/docs/gradle-compilation-and-caches.html)
describes incrementality and daemon settings. Do not delete caches or relocate
the user's checkout/cache as a substitute for proving compatibility.

## Qualification for every migration batch

- Strict Dart analysis and relevant focused tests; full Flutter suite and all
  compile-time variants at the batch boundary. Keep localization/content checks,
  Node relay tests, Python artifact-guard tests, inventory and the 18-file ratchet.
- Linux/JDK 17 CI plus bounded Windows builds. Run heavy local checks sequentially.
  Use normal Pub-enabled release builds so release-specific platform registration
  is regenerated; verify the package lock/signing configuration remain intended.
- Check the actual minified APK/bundle output with
  `python tools/verify_android_release_registrars.py` before uploading artifacts.
- Physical signed release: first-permission camera start, close/reopen and camera
  switching; file picker open/cancel; preferences; SQLite reads/writes and durable
  workout restoration. Report barcode-decoding coverage separately from preview
  startup. Exercise failure injection in isolated test databases, not user data.
- Compare stopped-app preview database/preferences snapshots and integrity/schema
  checks. Preserve normal theme appearance and approved interaction behavior;
  technical passes do not grant fresh visual or release approval.

Device QA must use a dedicated package/database verified absent from **all Android
users, including retained/uninstalled (`-u`) entries**. A current-user package
list is insufficient; even a user-specific install can update a package binary
shared with another profile. The first attempt in the parent report illustrates
this constraint. Keep temporary identity overrides out of source checkpoints.

CI action-runtime deprecation notices are a separate tooling follow-up: refresh
reviewed action pins when appropriate without conflating an action's JavaScript
runtime with the Node version used for relay tests. No dependency, SDK, runner
or application-identity upgrade is performed by this planning document.
