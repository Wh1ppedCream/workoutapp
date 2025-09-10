-- lib/db/schema_latest.sql
PRAGMA foreign_keys = ON;
PRAGMA recursive_triggers = OFF;

BEGIN;

-- ────────────────────────────────────────────────────────────────────────────
-- Lookup tables
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS brands (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS sources (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

-- ────────────────────────────────────────────────────────────────────────────
-- Core: foods & portions
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS foods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  brand TEXT,                -- text copy kept for FTS/fallback
  brand_id INTEGER,
  category_id INTEGER,
  is_custom INTEGER DEFAULT 0,      -- 0/1
  verified INTEGER,                 -- 0/1/NULL
  data_source TEXT,
  data_source_id TEXT,
  source_id INTEGER,
  density_g_per_ml REAL,
  quality_score INTEGER,
  version INTEGER,
  preparation TEXT,
  default_portion_id INTEGER,       -- optional helper
  created_at TEXT,
  updated_at TEXT,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_foods_name ON foods(name);
CREATE INDEX IF NOT EXISTS idx_foods_brand_id ON foods(brand_id);
CREATE INDEX IF NOT EXISTS idx_foods_is_deleted ON foods(is_deleted);
CREATE INDEX IF NOT EXISTS idx_foods_default_portion ON foods(default_portion_id);

CREATE TABLE IF NOT EXISTS food_portions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id INTEGER NOT NULL,
  measure_name TEXT NOT NULL,
  gram_weight REAL,
  ml_volume REAL,
  is_default INTEGER NOT NULL DEFAULT 0,   -- 0/1
  list_kind TEXT,                          -- e.g. 'basis','household','label'
  sort_order INTEGER,
  amount REAL,
  unit TEXT,
  label TEXT,
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_portions_food ON food_portions(food_id);
CREATE INDEX IF NOT EXISTS idx_portions_default ON food_portions(food_id,is_default DESC);

-- Optional: keep foods.default_portion_id pointing at an existing row
-- (safe even if app doesn't rely on FK strictly)
-- If you prefer to avoid constraint errors during edits, comment this out.
-- ALTER TABLE foods ADD FOREIGN KEY (default_portion_id) REFERENCES food_portions(id) ON DELETE SET NULL;

-- Barcodes (unique per code; many codes can point to one food)
CREATE TABLE IF NOT EXISTS food_barcodes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id INTEGER NOT NULL,
  upc TEXT NOT NULL UNIQUE,
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_barcodes_food ON food_barcodes(food_id);

-- ────────────────────────────────────────────────────────────────────────────
-- Nutrients & values
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS nutrients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,     -- e.g., KCAL, PROTEIN_G, ...
  name TEXT NOT NULL,
  unit TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS nutrient_aliases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nutrient_id INTEGER NOT NULL,
  alias TEXT NOT NULL,           -- display/legacy alias (case-insensitive in app)
  UNIQUE(alias),
  FOREIGN KEY (nutrient_id) REFERENCES nutrients(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_aliases_nutrient ON nutrient_aliases(nutrient_id);

-- Legacy per_100g mirror (still used in a few code paths)
CREATE TABLE IF NOT EXISTS food_nutrients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id INTEGER NOT NULL,
  nutrient_id INTEGER NOT NULL,
  amount_per_100g REAL NOT NULL,
  UNIQUE(food_id, nutrient_id),
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE,
  FOREIGN KEY (nutrient_id) REFERENCES nutrients(id) ON DELETE CASCADE
);

-- Flexible values (v22+): per_100g / per_100ml / per_portion(+portion_id)
CREATE TABLE IF NOT EXISTS food_nutrient_values (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  food_id INTEGER NOT NULL,
  nutrient_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  basis TEXT NOT NULL CHECK (basis IN ('per_100g','per_100ml','per_portion')),
  portion_id INTEGER,  -- only set when basis='per_portion'
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE,
  FOREIGN KEY (nutrient_id) REFERENCES nutrients(id) ON DELETE CASCADE,
  FOREIGN KEY (portion_id) REFERENCES food_portions(id) ON DELETE CASCADE
);

-- Enforce uniqueness when portion_id IS NULL
CREATE UNIQUE INDEX IF NOT EXISTS uq_fnv_base
  ON food_nutrient_values(food_id, nutrient_id, basis)
  WHERE portion_id IS NULL;

-- Enforce uniqueness when portion_id IS NOT NULL
CREATE UNIQUE INDEX IF NOT EXISTS uq_fnv_portion
  ON food_nutrient_values(food_id, nutrient_id, basis, portion_id)
  WHERE portion_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_fnv_food_basis
  ON food_nutrient_values(food_id, basis);

CREATE INDEX IF NOT EXISTS idx_fnv_food_nutrient
  ON food_nutrient_values(food_id, nutrient_id);


-- ────────────────────────────────────────────────────────────────────────────
-- Recipes
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  notes TEXT,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  created_at TEXT,
  updated_at TEXT
);

CREATE TABLE IF NOT EXISTS recipe_ingredients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER NOT NULL,
  food_id INTEGER NOT NULL,
  portion_id INTEGER,
  quantity REAL,  -- count of portion
  grams REAL,     -- optional explicit grams override
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE,
  FOREIGN KEY (portion_id) REFERENCES food_portions(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_rings_recipe ON recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_rings_food ON recipe_ingredients(food_id);

-- Cached per-100g for recipes (code stored as DB code, e.g., KCAL/PROTEIN_G/etc.)
CREATE TABLE IF NOT EXISTS recipe_nutrients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recipe_id INTEGER NOT NULL,
  code TEXT NOT NULL,
  per_100g REAL NOT NULL,
  UNIQUE(recipe_id, code),
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- ────────────────────────────────────────────────────────────────────────────
-- Diary, goals, totals, favorites, usage, tags
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS diary_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL,
  date TEXT NOT NULL,                -- YYYY-MM-DD (local-date semantics)
  meal_type INTEGER NOT NULL,        -- enum index
  food_id INTEGER,
  recipe_id INTEGER,
  portion_id INTEGER,
  quantity REAL NOT NULL DEFAULT 1.0,
  grams REAL,                        -- legacy field
  logged_grams REAL,                 -- preferred precise grams
  grams_override REAL,               -- legacy shim
  notes TEXT,
  kcal_snapshot REAL,
  protein_g_snapshot REAL,
  carb_g_snapshot REAL,
  fat_g_snapshot REAL,
  nutrient_snapshot_json TEXT,
  logged_at INTEGER,                 -- epoch ms UTC
  is_deleted INTEGER NOT NULL DEFAULT 0,
  updated_at INTEGER,                -- epoch ms UTC
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE SET NULL,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE SET NULL,
  FOREIGN KEY (portion_id) REFERENCES food_portions(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_diary_profile_date ON diary_entries(profile_id, date);
CREATE INDEX IF NOT EXISTS idx_diary_profile_logged_at ON diary_entries(profile_id, logged_at);
CREATE INDEX IF NOT EXISTS idx_diary_is_deleted ON diary_entries(is_deleted);

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
  date TEXT NOT NULL,                 -- YYYY-MM-DD
  kcal REAL NOT NULL DEFAULT 0,
  protein_g REAL NOT NULL DEFAULT 0,
  fat_g REAL NOT NULL DEFAULT 0,
  carbs_g REAL NOT NULL DEFAULT 0,
  fiber_g REAL NOT NULL DEFAULT 0,
  sugar_g REAL NOT NULL DEFAULT 0,
  sat_fat_g REAL NOT NULL DEFAULT 0,
  sodium_mg REAL NOT NULL DEFAULT 0,
  PRIMARY KEY (profile_id, date)
);

CREATE TABLE IF NOT EXISTS nutrition_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id INTEGER NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT,
  kcal_target REAL,
  protein_g_target REAL,
  fat_g_target REAL,
  carbs_g_target REAL,
  fiber_g_target REAL,
  sodium_mg_limit REAL
);
CREATE INDEX IF NOT EXISTS idx_goals_profile_span ON nutrition_goals(profile_id, start_date, end_date);

CREATE TABLE IF NOT EXISTS favorite_foods (
  profile_id INTEGER NOT NULL,
  food_id INTEGER NOT NULL,
  created_at INTEGER,
  PRIMARY KEY (profile_id, food_id),
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS diary_entry_tags (
  entry_id INTEGER NOT NULL,
  tag TEXT NOT NULL,
  created_at INTEGER,
  PRIMARY KEY (entry_id, tag),
  FOREIGN KEY (entry_id) REFERENCES diary_entries(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS food_usage_stats (
  profile_id INTEGER NOT NULL,
  food_id INTEGER NOT NULL,
  hits INTEGER NOT NULL DEFAULT 0,
  last_used TEXT,
  PRIMARY KEY (profile_id, food_id),
  FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
);

-- ────────────────────────────────────────────────────────────────────────────
-- FTS (FTS4 external content = foods)
-- ────────────────────────────────────────────────────────────────────────────
-- Only name + brand are indexed for search; adjust if you also want categories.
CREATE VIRTUAL TABLE IF NOT EXISTS food_search_fts USING fts4(
  name,
  brand,
  content=foods
);

-- Keep the FTS index in sync with foods
CREATE TRIGGER IF NOT EXISTS foods_ai AFTER INSERT ON foods BEGIN
  INSERT INTO food_search_fts(rowid, name, brand)
  VALUES (NEW.id, NEW.name, COALESCE(NEW.brand,''));
END;

CREATE TRIGGER IF NOT EXISTS foods_ad AFTER DELETE ON foods BEGIN
  DELETE FROM food_search_fts WHERE rowid = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS foods_au AFTER UPDATE ON foods BEGIN
  DELETE FROM food_search_fts WHERE rowid = OLD.id;
  INSERT INTO food_search_fts(rowid, name, brand)
  VALUES (NEW.id, NEW.name, COALESCE(NEW.brand,''));
END;

COMMIT;
