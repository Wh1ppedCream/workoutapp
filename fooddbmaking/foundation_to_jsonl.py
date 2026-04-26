#!/usr/bin/env python3
import json
from pathlib import Path

INPUT = Path("FoodData_Central_foundation_food_json_2025-04-24.json")
OUTPUT = Path("foods.foundation.jsonl")

# USDA nutrient "number" → our compact keys
NUTRIENT_MAP = {
    "208": "KCAL",       # Energy (kcal)
    "203": "PROTEIN_G",  # Protein (g)
    "205": "CARB_G",     # Carbohydrate, by difference (g)
    "204": "FAT_G",      # Total lipid (fat) (g)
}

def first_portion(food):
    """Pick the first foodPortions entry and return (amount, unit_abbrev, text, gram_weight)
    or None if not available."""
    portions = food.get("foodPortions") or []
    if not portions:
        return None
    p = portions[0]

    value = p.get("value")
    unit = None
    mu = p.get("measureUnit") or {}
    # Prefer abbreviation when present, otherwise name
    unit = (mu.get("abbreviation") or mu.get("name") or "").strip()
    modifier = (p.get("modifier") or "").strip()
    gram_weight = p.get("gramWeight")

    # Build human text
    if value is not None and unit:
        text = f"{value:g} {unit}"
    elif value is not None:
        text = f"{value:g}"
    else:
        text = unit or ""

    if modifier:
        # Some rows use modifier for extra detail (e.g., "chopped")
        text = f"{text} {modifier}"

    # Normalize unit field in serving_size (just the unit token, like "tbsp" or "cup")
    unit_field = unit if unit else "g"

    return value, unit_field, text.strip(), gram_weight

def extract_per_100g(food):
    """Return dict with only KCAL/PROTEIN_G/CARB_G/FAT_G if present."""
    per = {}
    for fn in food.get("foodNutrients") or []:
        nutr = fn.get("nutrient") or {}
        number = nutr.get("number")
        key = NUTRIENT_MAP.get(number)
        if key is None:
            continue
        amt = fn.get("amount")
        if amt is None:
            # Some entries put the value under "median" (rare). Fall back if needed.
            amt = fn.get("median")
        if amt is None:
            continue
        # Use native float; don't round away precision here.
        per[key] = float(amt)
    return per

def foundation_to_jsonl_record(food):
    name = food.get("description") or ""
    fdc_id = food.get("fdcId")
    category = None
    if isinstance(food.get("foodCategory"), dict):
        category = food["foodCategory"].get("description")

    per_100g = extract_per_100g(food)

    # Serving size & portions
    portion_info = first_portion(food)
    if portion_info is None or portion_info[3] in (None, 0):
        # Fallback to 100 g only
        serving_size = {"amount": 100, "unit": "g", "text": "100 g"}
        portions = [{"measure_name": "100 g", "gram_weight": 100.0, "is_default": True}]
    else:
        amount, unit, text, gram_weight = portion_info
        # Guard against missing amount/unit
        if amount is None or not unit:
            serving_size = {"amount": 100, "unit": "g", "text": "100 g"}
            portions = [{"measure_name": "100 g", "gram_weight": 100.0, "is_default": True}]
        else:
            serving_size = {"amount": float(amount), "unit": unit, "text": text}
            portions = [
                {"measure_name": text, "gram_weight": float(gram_weight), "is_default": False},
                {"measure_name": "100 g", "gram_weight": 100.0, "is_default": True},
            ]

    rec = {
        "name": name,
        "brand": None,
        "barcodes": [],
        "source": "USDA Foundation",
        "source_id": fdc_id,
        "category": category,
        "serving_size": serving_size,
        "per_100g": per_100g,
        "portions": portions,
    }
    return rec

def main():
    with INPUT.open("r", encoding="utf-8") as f:
        root = json.load(f)

    foods = root.get("FoundationFoods") or []
    count_in = 0
    count_out = 0

    with OUTPUT.open("w", encoding="utf-8") as out_fp:
        for food in foods:
            count_in += 1
            rec = foundation_to_jsonl_record(food)

            # Skip if we didn't get any of the four core nutrients (should be rare)
            if not rec["per_100g"]:
                continue

            out_fp.write(json.dumps(rec, ensure_ascii=False, separators=(",", ":")) + "\n")
            count_out += 1

    print(f"Read {count_in} foundation foods; wrote {count_out} JSONL lines to {OUTPUT}")

if __name__ == "__main__":
    main()
