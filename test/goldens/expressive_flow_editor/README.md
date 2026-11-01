# Flow-control golden references

The four original references are the Windows Flutter 3.47.5 baseline retained
from the pre-refactor rendering. `linux/` contains the same four states rendered
by Flutter 3.47.5 on the GitHub Actions Linux host. Both sets use exact pixel
comparison; there is no tolerance, skipped golden test or automatic regeneration
in CI. Application widgets and styling have not changed for this repair.

Linux references came from the test-image outputs in the
`golden-failures-16afe0f5c3da23c03e9f68d57f53acee8c35c2d0` artifact of
[run 41341614065](https://github.com/Wh1ppedCream/workoutapp/actions/runs/41341614065).
All four test images and their masked/isolated comparisons were inspected.
The differences trace the Ahem text/icon glyph edges; card geometry, padding,
surfaces and layout remain the same. The original Windows references were not
overwritten. Flutter documents [host-dependent font rendering in golden tests](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html).

Update references deliberately on the corresponding host using the pinned SDK,
review every comparison and commit the images with the intended change. Do not
copy an unreviewed failure into either baseline. Other host platforms have not
been qualified by this follow-up.
