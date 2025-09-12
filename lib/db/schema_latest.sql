-- lib/db/schema_latest.sql
PRAGMA foreign_keys = ON;
PRAGMA recursive_triggers = OFF;

BEGIN;

-- ────────────────────────────────────────────────────────────────────────────
-- Lookup tables
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS brands (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS sources (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS categories (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

-- ────────────────────────────────────────────────────────────────────────────
-- Core: foods & portions
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS foods (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  name               TEXT NOT NULL,
  brand              TEXT,                -- denormalized copy (search/fallback)
  brand_id           INTEGER,
  category_id        INTEGER,
  is_custom          INTEGER DEFAULT 0,   -- 0/1
  verified           INTEGER,             -- 0/1/NULL
  data_source        TEXT,
  data_source_id     TEXT,
  source_id          INTEGER,
  density_g_per_ml   REAL,
  quality_score      INTEGER,
  version            INTEGER,
  preparation        TEXT,
  default_portion_id INTEGER,             -- optional helper (not FK-enforced)
  created_at         TEXT,
  updated_at         TEXT,
  is_deleted         INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (brand_id)    REFERENCES brands(id)    ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  FOREIGN KEY (source_id)   REFERENCES sources(id)   ON DELETE SET NULL
);

-- Baseline indexes (plus more below)
CREATE INDEX IF NOT EXISTS idx_foods_name         ON foods(name);
CREATE INDEX IF NOT EXISTS idx_foods_brand_id     ON foods(brand_id);
CREATE INDEX IF NOT EXISTS idx_foods_is_deleted   ON foods(is_deleted);
CREATE INDEX IF NOT EXISTS idx_foods_default_portion ON foods(default_portion_id);

CREATE TABLE IF NOT EXISTS food_portions (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id      INTEGER NOT NULL,
  measure_name TEXT NOT NULL,
  gram_weight  REAL,
  ml_volume    REAL,
  is_default   INTEGER NOT NULL DEFAULT 0,   -- 0/1
  list_kind    TEXT,                         -- 'basis' | 'household' | 'label'
  sort_order   INTEGER,
  amount       REAL,
  unit         TEXT,
  label        TEXT,
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_portions_food    ON food_portions(food_id);
CREATE INDEX IF NOT EXISTS idx_portions_default ON food_portions(food_id, is_default DESC);

-- Barcodes (unique per code; many codes can map to one food)
CREATE TABLE IF NOT EXISTS food_barcodes (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id INTEGER NOT NULL,
  upc     TEXT NOT NULL UNIQUE,
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_barcodes_food ON food_barcodes(food_id);

-- ────────────────────────────────────────────────────────────────────────────
-- Nutrients & values
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS nutrients (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,     -- e.g., KCAL, PROTEIN_G, ...
  name TEXT NOT NULL,
  unit TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_nutrients_code ON nutrients(code);

CREATE TABLE IF NOT EXISTS nutrient_aliases (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  nutrient_id INTEGER NOT NULL,
  alias       TEXT NOT NULL,
  UNIQUE(alias),
  FOREIGN KEY (nutrient_id) REFERENCES nutrients(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_aliases_nutrient ON nutrient_aliases(nutrient_id);

-- Legacy per_100g mirror (still used in a few code paths)
CREATE TABLE IF NOT EXISTS food_nutrients (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id          INTEGER NOT NULL,
  nutrient_id      INTEGER NOT NULL,
  amount_per_100g  REAL NOT NULL,
  UNIQUE(food_id, nutrient_id),
  FOREIGN KEY (food_id)     REFERENCES foods(id)     ON DELETE CASCADE,
  FOREIGN KEY (nutrient_id) REFERENCES nutrients(id) ON DELETE CASCADE
);

-- Flexible values (v22+): per_100g / per_100ml / per_portion(+portion_id)
CREATE TABLE IF NOT EXISTS food_nutrient_values (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id     INTEGER NOT NULL,
  nutrient_id INTEGER NOT NULL,
  amount      REAL NOT NULL,
  basis       TEXT NOT NULL CHECK (basis IN ('per_100g','per_100ml','per_portion')),
  portion_id  INTEGER,  -- set when basis='per_portion'
  FOREIGN KEY (food_id)     REFERENCES foods(id)         ON DELETE CASCADE,
  FOREIGN KEY (nutrient_id) REFERENCES nutrients(id)     ON DELETE CASCADE,
  FOREIGN KEY (portion_id)  REFERENCES food_portions(id) ON DELETE CASCADE
);

-- Partial uniqueness (replaces UNIQUE(..., COALESCE(portion_id,-1)))
CREATE UNIQUE INDEX IF NOT EXISTS uq_fnv_base
  ON food_nutrient_values(food_id, nutrient_id, basis)
  WHERE portion_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_fnv_portion
  ON food_nutrient_values(food_id, nutrient_id, basis, portion_id)
  WHERE portion_id IS NOT NULL;

-- Useful read-path indexes (and mirrored at runtime)
CREATE INDEX IF NOT EXISTS idx_fnv_food_basis           ON food_nutrient_values(food_id, basis);
CREATE INDEX IF NOT EXISTS idx_fnv_food_nutrient        ON food_nutrient_values(food_id, nutrient_id);
CREATE INDEX IF NOT EXISTS idx_fnv_food_basis_nutrient  ON food_nutrient_values(food_id, basis, nutrient_id);
CREATE INDEX IF NOT EXISTS idx_fnv_food_basis_portion   ON food_nutrient_values(food_id, basis, portion_id);

-- ────────────────────────────────────────────────────────────────────────────
-- Recipes
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS recipes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT NOT NULL,
  notes      TEXT,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  created_at TEXT,
  updated_at TEXT
);

CREATE TABLE IF NOT EXISTS recipe_ingredients (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id  INTEGER NOT NULL,
  food_id    INTEGER NOT NULL,
  portion_id INTEGER,
  quantity   REAL,  -- number of portion
  grams      REAL,  -- optional explicit grams override
  FOREIGN KEY (recipe_id)  REFERENCES recipes(id)       ON DELETE CASCADE,
  FOREIGN KEY (food_id)    REFERENCES foods(id)         ON DELETE CASCADE,
  FOREIGN KEY (portion_id) REFERENCES food_portions(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_rings_recipe ON recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_rings_food   ON recipe_ingredients(food_id);

-- Cached per-100g for recipes (code = DB code like KCAL/PROTEIN_G/etc.)
CREATE TABLE IF NOT EXISTS recipe_nutrients (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER NOT NULL,
  code      TEXT NOT NULL,
  per_100g  REAL NOT NULL,
  UNIQUE(recipe_id, code),
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_recipe_nutrients_recipe ON recipe_nutrients(recipe_id);

-- ────────────────────────────────────────────────────────────────────────────
-- Diary, goals, totals, favorites, usage, tags
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS diary_entries (
  id                      INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id              INTEGER NOT NULL,
  date                    TEXT NOT NULL,        -- YYYY-MM-DD (local date)
  meal_type               INTEGER NOT NULL,     -- enum index
  food_id                 INTEGER,
  recipe_id               INTEGER,
  portion_id              INTEGER,
  quantity                REAL NOT NULL DEFAULT 1.0,
  grams                   REAL,                 -- legacy field
  logged_grams            REAL,                 -- preferred precise grams
  grams_override          REAL,                 -- legacy shim
  notes                   TEXT,
  kcal_snapshot           REAL,
  protein_g_snapshot      REAL,
  carb_g_snapshot         REAL,
  fat_g_snapshot          REAL,
  nutrient_snapshot_json  TEXT,
  logged_at               INTEGER,              -- epoch ms UTC
  is_deleted              INTEGER NOT NULL DEFAULT 0,
  updated_at              INTEGER,              -- epoch ms UTC
  FOREIGN KEY (food_id)    REFERENCES foods(id)           ON DELETE SET NULL,
  FOREIGN KEY (recipe_id)  REFERENCES recipes(id)         ON DELETE SET NULL,
  FOREIGN KEY (portion_id) REFERENCES food_portions(id)   ON DELETE SET NULL
);

-- Read-path indexes
CREATE INDEX IF NOT EXISTS idx_diary_profile_date     ON diary_entries(profile_id, date);
CREATE INDEX IF NOT EXISTS idx_diary_profile_logged_at ON diary_entries(profile_id, logged_at);
CREATE INDEX IF NOT EXISTS idx_diary_is_deleted       ON diary_entries(is_deleted);

-- Runtime also uses a variant with is_deleted in key; include it:
CREATE INDEX IF NOT EXISTS idx_diary_entries_profile_date
  ON diary_entries(profile_id, date, is_deleted);
CREATE INDEX IF NOT EXISTS idx_diary_entries_profile_logged
  ON diary_entries(profile_id, logged_at);

-- Keep updated_at bumped automatically (AFTER triggers + in-place UPDATE)
CREATE TRIGGER IF NOT EXISTS diary_set_updated_at_ins
AFTER INSERT ON diary_entries
WHEN NEW.updated_at IS NULL
BEGIN
  UPDATE diary_entries
     SET updated_at = CAST(strftime('%s','now') AS INTEGER) * 1000
   WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS diary_set_updated_at_upd
AFTER UPDATE ON diary_entries
BEGIN
  UPDATE diary_entries
     SET updated_at = CAST(strftime('%s','now') AS INTEGER) * 1000
   WHERE id = NEW.id;
END;

CREATE TABLE IF NOT EXISTS day_totals_cache (
  profile_id INTEGER NOT NULL,
  date       TEXT NOT NULL,   -- YYYY-MM-DD
  kcal       REAL NOT NULL DEFAULT 0,
  protein_g  REAL NOT NULL DEFAULT 0,
  fat_g      REAL NOT NULL DEFAULT 0,
  carbs_g    REAL NOT NULL DEFAULT 0,
  fiber_g    REAL NOT NULL DEFAULT 0,
  sugar_g    REAL NOT NULL DEFAULT 0,
  sat_fat_g  REAL NOT NULL DEFAULT 0,
  sodium_mg  REAL NOT NULL DEFAULT 0,
  PRIMARY KEY (profile_id, date)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_day_totals_profile_date
  ON day_totals_cache(profile_id, date);

CREATE TABLE IF NOT EXISTS nutrition_goals (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id       INTEGER NOT NULL,
  start_date       TEXT NOT NULL,
  end_date         TEXT,
  kcal_target      REAL,
  protein_g_target REAL,
  fat_g_target     REAL,
  carbs_g_target   REAL,
  fiber_g_target   REAL,
  sodium_mg_limit  REAL
);
CREATE INDEX IF NOT EXISTS idx_goals_profile_span
  ON nutrition_goals(profile_id, start_date, end_date);

CREATE TABLE IF NOT EXISTS favorite_foods (
  profile_id INTEGER NOT NULL,
  food_id    INTEGER NOT NULL,
  created_at INTEGER,
  PRIMARY KEY (profile_id, food_id),
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_favorite_foods_profile ON favorite_foods(profile_id);

CREATE TABLE IF NOT EXISTS diary_entry_tags (
  entry_id   INTEGER NOT NULL,
  tag        TEXT NOT NULL,
  created_at INTEGER,
  PRIMARY KEY (entry_id, tag),
  FOREIGN KEY (entry_id) REFERENCES diary_entries(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_diary_entry_tags_entry ON diary_entry_tags(entry_id);
CREATE INDEX IF NOT EXISTS idx_diary_entry_tags_tag   ON diary_entry_tags(tag);

CREATE TABLE IF NOT EXISTS food_usage_stats (
  profile_id INTEGER NOT NULL,
  food_id    INTEGER NOT NULL,
  hits       INTEGER NOT NULL DEFAULT 0,
  last_used  TEXT,
  PRIMARY KEY (profile_id, food_id),
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_food_usage_profile_last
  ON food_usage_stats(profile_id, last_used);

-- ────────────────────────────────────────────────────────────────────────────
-- User profile (referenced by app’s PersonalInfoDao)
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS personal_info (
  id             INTEGER PRIMARY KEY CHECK (id = 1),
  birth_date     TEXT,    -- YYYY-MM-DD
  sex            TEXT,    -- 'male' | 'female' | 'other' | NULL
  height_cm      REAL,
  weight_kg      REAL,
  activity_level TEXT,
  created_at     TEXT,
  updated_at     TEXT
);

-- ────────────────────────────────────────────────────────────────────────────
-- Optional audit table (export guarded by existence in app)
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS diary_entry_audit (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id    INTEGER,
  action      TEXT NOT NULL,     -- 'insert' | 'update' | 'delete'
  payload_json TEXT,
  created_at  INTEGER,           -- epoch ms UTC
  FOREIGN KEY (entry_id) REFERENCES diary_entries(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_deaudit_entry ON diary_entry_audit(entry_id);

-- ────────────────────────────────────────────────────────────────────────────
-- FTS (contentless FTS4; populated by builder / maintenance tasks)
-- ────────────────────────────────────────────────────────────────────────────
CREATE VIRTUAL TABLE IF NOT EXISTS food_search_fts USING fts4(
  name,
  brand
);

-- No triggers here. The offline builder bulk-populates it after seeding,
-- and the app can rebuild/optimize it when needed.

-- ────────────────────────────────────────────────────────────────────────────
-- Safe portion triggers (single default per food)
-- ────────────────────────────────────────────────────────────────────────────
CREATE TRIGGER IF NOT EXISTS trg_portion_single_default_ins
AFTER INSERT ON food_portions
WHEN NEW.is_default = 1
BEGIN
  UPDATE food_portions
     SET is_default = 0
   WHERE food_id = NEW.food_id AND id <> NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS trg_portion_single_default_upd
AFTER UPDATE OF is_default ON food_portions
WHEN NEW.is_default = 1
BEGIN
  UPDATE food_portions
     SET is_default = 0
   WHERE food_id = NEW.food_id AND id <> NEW.id;
END;

COMMIT;
