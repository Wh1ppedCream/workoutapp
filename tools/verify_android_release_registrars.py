"""Check reflection entry points in the actual minified Android release outputs."""

import argparse
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

ANDROID = '{http://schemas.android.com/apk/res/android}'
PREFIX = 'com.google.firebase.components:'
REGISTRAR = 'com.google.firebase.components.ComponentRegistrar'
CLASS = re.compile(r'^([^\s#].*) -> ([^:\s]+):$')
CONSTRUCTOR = re.compile(r'\bvoid <init>\(\)(?::\d+(?::\d+)?)? -> <init>$')


def manifest_registrars(xml):
    names = set()
    for node in ET.fromstring(xml).iter('meta-data'):
        key = node.get(ANDROID + 'name', '')
        if key.startswith(PREFIX) and node.get(ANDROID + 'value') == REGISTRAR:
            name = key.removeprefix(PREFIX)
            if name.startswith('com.google.mlkit.'):
                names.add(name)
    return names


def mapping_failures(lines, required):
    """A kept class alone is insufficient under AGP 9 strict keep semantics."""
    entries = {}
    current = None
    for line in lines:
        line = line.rstrip()
        header = CLASS.match(line)
        if header:
            original, renamed = header.groups()
            current = original if original in required else None
            if current:
                entries[current] = [renamed, False]
        elif current and CONSTRUCTOR.search(line):
            entries[current][1] = True
    failures = []
    for name in sorted(required):
        entry = entries.get(name)
        if entry is None:
            failures.append(f'{name}: class missing from R8 output')
        elif entry[0] != name:
            failures.append(f'{name}: reflection name changed to {entry[0]}')
        elif not entry[1]:
            failures.append(f'{name}: no retained no-argument constructor')
    return failures


def verify(build_dir):
    manifest_root = build_dir / 'intermediates/merged_manifests/release'
    manifests = sorted(manifest_root.rglob('AndroidManifest.xml'))
    if not manifests:
        raise ValueError('No merged release manifest; build the signed release first.')
    required = set()
    for manifest in manifests:
        required.update(manifest_registrars(manifest.read_text(encoding='utf-8')))
    if not required:
        raise ValueError('No ML Kit registrar metadata in the merged release manifest.')
    mapping = build_dir / 'outputs/mapping/release/mapping.txt'
    with mapping.open(encoding='utf-8') as lines:
        failures = mapping_failures(lines, required)
    if failures:
        raise ValueError('\n'.join(failures))
    return len(required)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build-dir', type=Path, default=Path('build/app'))
    args = parser.parse_args()
    try:
        count = verify(args.build_dir)
    except (OSError, ValueError, ET.ParseError) as error:
        print(f'Android release registrar check failed: {error}', file=sys.stderr)
        return 1
    print(f'Android release registrar check passed: '
          f'{count} reflection names and constructors retained.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
