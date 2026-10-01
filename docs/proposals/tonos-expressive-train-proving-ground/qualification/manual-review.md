# Train + shell Expressive — user review

The user has approved the current Train + shell Expressive visual/motion language as a reference baseline, and this slice has passed technical qualification. This guide remains the procedure for opening and rechecking the isolated preview. It does not approve a stored theme, production rollout, or any other screen.

**Current review build:** the canonical profile preview was rebuilt, manifest-verified, installed, and visually checked on Pixel 7 after qualification. It uses the isolated package/database below; the normal Tonos installs and their data were not targeted.

- Package: `com.tonos.expressivepreview`
- Database: `tonos_expressive_preview.db`
- Build: profile, versionCode 6 / versionName 1.0.1; no DEBUG ribbon
- Device: Pixel 7, serial `28021FDH200228`

Launch it from the app drawer as **Tonos Expressive Preview**, or after USB debugging reconnects run:

```powershell
& 'E:\Android\Sdk\platform-tools\adb.exe' -s 28021FDH200228 shell monkey -p com.tonos.expressivepreview -c android.intent.category.LAUNCHER 1
```

Open the sliders button in the preview strip. Select **Expressive**, **Curated**, **Light**, **1×**; leave **Reduced motion** and **Effects off** disabled. Use **Done** or Android Back to close controls. **Reset review controls** restores the comparison settings; **Reset sandbox fixtures** restores disposable sample content. The controls and fixture reset affect only the preview sandbox.

## Open and compare

1. Open **Tonos Expressive Preview** on the Pixel 7. Use this sandbox, not the normal Tonos app.
2. Tap the sliders icon in the separate top review strip. Choose **Expressive**, **Curated**, **Light**, and **1×** text; leave **Reduced motion** and **Effects off** off. Close with **Done** or Android Back.
3. Review **Train → Overview** and **Train → Plans**. Switch the review look to **Classic** to compare the same content, tab, and scroll position. Switch back to Expressive, then repeat in **Dark**.
4. **Reset review controls** resets appearance controls only. **Reset sandbox fixtures** restores disposable preview content; use it between workflow trials, not while finishing a workout.

## What to try

| Area | Action | What to judge against Classic |
|---|---|---|
| At rest | Compare Overview, then Plans at the same scroll position. | Tonal grouping, selected segment geometry, primary-purple Start versus Classic's green Start, and the navigation indicator. Does it feel newer while remaining Tonos? |
| Train selection | Alternate Overview/Plans slowly, then 15–20 times quickly. | Expressive adds a bounded spring to the selected background; content should change immediately. Is recovery enjoyable, too subtle, or tiring? |
| Navigation | Alternate Train/Catalog, then return to Train. | The selected indicator moves while labels and hit areas stay fixed. Is selection clearer and responsive? Child-page visuals are outside this review. |
| Start | On Overview, press Start, then return from the disposable Session. Repeat after resetting the sandbox if needed. | Expressive changes the Start corners on press/release. The real callback should run promptly. Does the response feel useful rather than distracting? |
| Density | Compare visible content, then select **2×** text in the review controls and scroll both Train tabs. | The ordinary Train header is 8 dp taller; the corrected five-item navigation is about 72 dp at 2×. Is the content still comfortable to scan and reach? |
| Color/dark | Compare light and dark. | Are neutral surfaces and primary/supporting actions clear? Is there too much purple? Plan identities, heatmaps, and completion colors should retain their meaning. |
| Reduced motion | Turn **Reduced motion** on; repeat tabs, navigation, and Start. | Spring recovery should snap, while Expressive's static selected states and surfaces remain. Is the static distinction still useful? |

## Feedback

For any later targeted review, describe the exact surface/control, light/dark mode, text scale, and whether a concern appears at rest or after repeated use. The approved Train + shell baseline is the reference for future adaptation; technical qualification does not authorize production rollout or determine the visual design of other destinations.
