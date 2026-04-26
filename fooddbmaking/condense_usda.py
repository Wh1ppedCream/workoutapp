# condense_usda.py
import re, sys, math, orjson, ijson

def clean_name(s: str) -> str:
    s = s.strip()
    parts = [p.strip() for p in s.split(',') if p.strip()]
    # collapse exact repeated trailing sequence (e.g., "... CINNAMON, RAISIN, CINNAMON, RAISIN")
    half = len(parts)//2
    if half and parts[:half] == parts[half:]:
        parts = parts[:half]
    return ', '.join(parts)

def digits_or_none(s):
    if not s: return None
    d = ''.join(ch for ch in str(s) if ch.isdigit())
    return d if d else None

NUM_MAP = {208:"KCAL", 203:"PROTEIN_G", 205:"CARB_G", 204:"FAT_G"}

def per100_from_foodNutrients(foodNutrients):
    out = {}
    for fn in foodNutrients or []:
        n = fn.get("nutrient") or {}
        try: num = int(n.get("number") or 0)
        except: continue
        code = NUM_MAP.get(num)
        if not code: continue
        amt = fn.get("amount")
        unit = (n.get("unitName") or "").lower()
        if amt is None: continue
        if code == "KCAL" and unit == "kj":
            amt = float(amt) / 4.184
        out[code] = float(amt)
    return out

def scale_label_to_100g(label, serving_size, serving_unit):
    if not label or serving_unit != "g" or not serving_size or serving_size <= 0:
        return {}
    f = 100.0/float(serving_size)
    out = {}
    if "calories" in label and "value" in label["calories"]:
        out["KCAL"] = float(label["calories"]["value"]) * f
    if "protein" in label:
        out["PROTEIN_G"] = float(label["protein"]["value"]) * f
    if "carbohydrates" in label:
        out["CARB_G"] = float(label["carbohydrates"]["value"]) * f
    if "fat" in label:
        out["FAT_G"] = float(label["fat"]["value"]) * f
    return out

def round_macros(x):
    return {
        "KCAL": int(round(x["KCAL"])) if "KCAL" in x else None,
        "PROTEIN_G": round(x.get("PROTEIN_G", 0.0), 1),
        "CARB_G": round(x.get("CARB_G", 0.0), 1),
        "FAT_G": round(x.get("FAT_G", 0.0), 1),
    }

def emit(obj, fh):
    fh.write(orjson.dumps(obj, default=float, option=orjson.OPT_APPEND_NEWLINE))

def main(path):
    with open(path, "rb") as f, sys.stdout.buffer as out:
        for item in ijson.items(f, "BrandedFoods.item"):
            name = clean_name(item.get("description",""))
            brand = (item.get("brandOwner") or None)
            barcode = digits_or_none(item.get("gtinUpc"))
            source_id = item.get("fdcId")
            category = item.get("brandedFoodCategory")
            serving_amt = item.get("servingSize")
            serving_unit = item.get("servingSizeUnit")
            serving_text = item.get("householdServingFullText")
            fn_per100 = per100_from_foodNutrients(item.get("foodNutrients"))
            if len(fn_per100) < 4:
                scaled = scale_label_to_100g(item.get("labelNutrients"), serving_amt, serving_unit)
                fn_per100.update({k:v for k,v in scaled.items() if k not in fn_per100})
            if not all(k in fn_per100 for k in ("KCAL","PROTEIN_G","CARB_G","FAT_G")):
                continue  # skip incomplete

            macros = round_macros(fn_per100)
            portions = [{"measure_name":"100 g","gram_weight":100,"is_default":True}]
            if serving_unit == "g" and isinstance(serving_amt, (int,float)) and serving_amt>0:
                label = "serving" + (f" ({serving_text})" if serving_text else "")
                portions.insert(0, {"measure_name":label, "gram_weight": float(serving_amt)})

            obj = {
              "name": name or None,
              "brand": brand,
              "barcodes": [barcode] if barcode else [],
              "source": "USDA Branded",
              "source_id": source_id,
              "category": category,
              "serving_size": (
                  {"amount": serving_amt, "unit": serving_unit, "text": serving_text}
                  if serving_amt and serving_unit else None
              ),
              "per_100g": macros,
              "portions": portions
            }
            emit(obj, out)

if __name__ == "__main__":
    main(sys.argv[1])
