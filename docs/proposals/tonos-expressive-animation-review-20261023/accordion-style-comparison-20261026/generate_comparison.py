from html import escape
from pathlib import Path
from struct import unpack
from zlib import crc32, decompress

ROOT = Path(__file__).resolve().parent
BASELINE = ROOT.parent / 'accordion-style-baseline-20261026'

# Each entry is (title, before light, after light, before dark, after dark).
GROUPS = [
    ('Plan Progression editor', 'progression', [
        ('Attach a progression action', '01-progression-editor-light-action.png', 'editor-action-light.png', '01-progression-editor-dark-action.png', 'editor-action-dark.png'),
        ('Add a branch', '01-progression-editor-light-branch.png', 'editor-branch-light.png', '01-progression-editor-dark-branch.png', 'editor-branch-dark.png'),
    ]),
    ('Workout Progress Rules / Flow Methods', 'rules', [
        ('Gym profile and plan rules', '02-progress-rules-light-gym-plan.png', 'rules-light.png', '02-progress-rules-dark-gym-plan.png', 'rules-dark.png'),
    ]),
    ('Workout Progress Flows', 'flows', [
        ('App and gym profile flows', '03-progress-flows-light-gym.png', 'flows-light.png', '03-progress-flows-dark-gym-top.png', 'flows-dark.png'),
    ]),
    ('Guided Tutorials', 'tutorials', [
        ('Main tabs category', '04-tutorials-light-main-expanded.png', 'tutorials-light.png', '04-tutorials-dark-main-expanded.png', 'tutorials-dark.png'),
    ]),
    ('Customize Food / Edit Food', 'food', [
        ('Portion Info', '05-food-editor-light-portions.png', 'food-portions-light.png', '05-food-editor-dark-portions.png', 'food-portions-dark.png'),
        ('Macronutrients', '05-food-editor-light-macros.png', 'food-macros-light.png', '05-food-editor-dark-macros.png', 'food-macros-dark.png'),
        ('Micronutrients', '05-food-editor-light-micros.png', 'food-micros-light.png', '05-food-editor-dark-micros.png', 'food-micros-dark.png'),
        ('Additional Components', '05-food-editor-light-additional.png', 'food-additional-light.png', '05-food-editor-dark-additional.png', 'food-additional-dark.png'),
    ]),
]

def validate_png(path):
    data = path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f'Not a PNG: {path}')
    position, payload, dimensions, ended = 8, [], None, False
    while position < len(data):
        length = unpack('>I', data[position:position + 4])[0]
        kind = data[position + 4:position + 8]
        content = data[position + 8:position + 8 + length]
        checksum = unpack('>I', data[position + 8 + length:position + 12 + length])[0]
        if crc32(kind + content) != checksum:
            raise ValueError(f'Invalid PNG checksum: {path}')
        if kind == b'IHDR':
            dimensions = unpack('>II', content[:8])
        elif kind == b'IDAT':
            payload.append(content)
        elif kind == b'IEND':
            ended = True
            break
        position += length + 12
    if not ended or dimensions != (1080, 2400) or not payload:
        raise ValueError(f'Incomplete PNG or unexpected dimensions: {path}')
    decompress(b''.join(payload))


for _, _, entries in GROUPS:
    for _, before_light, after_light, before_dark, after_dark in entries:
        for path in (BASELINE / before_light, ROOT / 'after' / after_light,
                     BASELINE / before_dark, ROOT / 'after' / after_dark):
            validate_png(path)

parts = ['''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tonos Expressive - accordion style comparison</title>
<style>
:root{color-scheme:light; font:16px/1.5 system-ui,sans-serif; color:#2d1d36; background:#f9f5fb}
body{margin:0} main{max-width:1120px;margin:auto;padding:24px 20px 70px}
h1{font-size:clamp(1.8rem,4vw,2.6rem);line-height:1.15;margin:.3em 0}
h2{margin:2em 0 .3em} h3{margin:1.4em 0 .4em} p{max-width:78ch}
nav{display:flex;flex-wrap:wrap;gap:.5rem;margin:1.3rem 0 2rem}
nav a{background:#e9d9f3;border:1px solid #c7afd3;border-radius:999px;padding:.4rem .8rem}
a{color:#502274} section{border-top:1px solid #d9cddd} .theme{font-weight:700;color:#5d4170}
.pair{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px;align-items:start}
figure{margin:0;background:white;border:1px solid #e0d6e3;border-radius:14px;padding:12px}
figcaption{font-weight:700;margin-bottom:8px} img{display:block;width:100%;height:auto;border-radius:5px}
.note{background:#f0e5f4;border-radius:14px;padding:14px 18px}
@media(max-width:540px){main{padding:16px 10px 48px}.pair{gap:8px}figure{padding:5px}figcaption{font-size:.9rem}}
</style></head><body><main>
<h1>Tonos Expressive - accordion style comparison</h1>
<p class="note"><strong>Historical comparison:</strong> these images precede the later header-geometry, chevron, divider and Food-action corrections. <a href="../accordion-final-polish-20261026/REVIEW.html">Open the latest finishing-pass captures.</a></p>
<p>Side-by-side screenshots of the five areas updated with inset accordion headers and more comfortable expanded content.</p>
<p class="note"><strong>Before:</strong> the original Pixel 7 baseline from checkpoint a8dff3e. <strong>After:</strong> the updated build on the same device, captured during the recent refinement and comparison. Scroll positions differ slightly in some pairs. Click any image to open the full-size screenshot. The existing Food Save and Cancel overlay appears in both versions.</p>
<nav aria-label="Comparison sections">''']
for title, anchor, _ in GROUPS:
    parts.append(f'<a href="#{anchor}">{escape(title)}</a>')
parts.append('</nav>')

count = 0
for title, anchor, entries in GROUPS:
    parts.append(f'<section id="{anchor}"><h2>{escape(title)}</h2>')
    for label, before_light, after_light, before_dark, after_dark in entries:
        parts.append(f'<h3>{escape(label)}</h3>')
        for theme, before, after in [('Light', before_light, after_light), ('Dark', before_dark, after_dark)]:
            old = f'../accordion-style-baseline-20261026/{before}'
            new = f'after/{after}'
            alt = escape(f'{title}, {label}, {theme.lower()} mode')
            parts.append(f'''<p class="theme">{theme} mode</p><div class="pair">
<figure><figcaption>Before</figcaption><a href="{old}"><img loading="lazy" src="{old}" alt="Before: {alt}"></a></figure>
<figure><figcaption>After</figcaption><a href="{new}"><img loading="lazy" src="{new}" alt="After: {alt}"></a></figure>
</div>''')
            count += 1
    parts.append('</section>')
parts.append('<p>Original baseline captures are preserved. This comparison does not change approval status.</p></main></body></html>')
(ROOT / 'COMPARISON_GALLERY.html').write_text('\n'.join(parts), encoding='utf-8')
print(f'Validated {count} before/after pairs across {len(GROUPS)} pages; all images are 1080 x 2400.')
