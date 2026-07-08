# Nutrition Cloud Content Plan

Nutrition content should follow the same staged model as exercise media: the
app ships with enough local structure to function, then downloads shared
datasets and optional images from public cloud manifests as they become ready.

## Goals

- Keep large food datasets and food images out of the app bundle.
- Preserve offline behavior after content is cached.
- Make every imported food traceable to a source and license.
- Allow incremental publishing, so a small verified dataset can go live before
  the full nutrition library is complete.
- Keep nutrition inactive in user-facing flows until the nutrition product work
  resumes.

## Proposed Namespaces

- `food_content`: food definitions, nutrition facts, serving metadata,
  aliases, barcode links, and source/license data.
- `food_media`: optional food thumbnails or images linked to food definitions.

These can be separate manifests later if the food database updates more often
than food images. For the first implementation, the source shape allows image
assets directly inside each food entry.

## Food Entry Contract

Each food should have:

- `foodId`: stable Tonos/content ID, preferably namespaced by provider.
- `source`: provider or dataset name, such as `usda`, `open_food_facts`, or a
  curated Tonos source.
- `licenseId`: license key stored in the manifest and release report.
- `name`: display name.
- `brand`: optional brand/manufacturer.
- `barcodes`: optional UPC/EAN list.
- `aliases`: optional search aliases.
- `serving`: default serving label, grams, and unit metadata.
- `nutrients`: calories and macro/micro values normalized per serving and/or
  per 100 g.
- `assets`: optional image entries using the same metadata pattern as exercise
  media: URL/path, thumbnail, dimensions, bytes, sha256, and license.

## Release Rules

- Release checks should require licenses for production food content.
- Imported foods should not overwrite user-created custom foods with the same
  display name.
- Barcode collisions should be reported during release checks.
- Food media should be optional; missing images should fall back to a local
  icon or color treatment.
- The app should be able to sync a new manifest without requiring a database
  destructive migration.

## Future Implementation Steps

1. Add `food_content` DAO tables for synced cloud foods.
2. Add a nutrition content repository parallel to `ContentRepository`.
3. Extend `tools/content_pipeline.dart` with `validate-food-content`,
   `build-food-content`, `diff-food-content`, and `release-check-food-content`.
4. Add cache reuse for food images through the existing media cache service.
5. Add source/license disclosure in any nutrition detail UI.
6. Turn nutrition UI back on only after the data model and user-facing flows are
   ready.
