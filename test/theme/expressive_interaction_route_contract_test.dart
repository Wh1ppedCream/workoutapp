import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dashboard feature routes pass their owning Expressive destination', () {
    final sections = _read('lib/widgets/dashboard_sections.dart');
    final dashboard = _read('lib/screens/dashboard_page.dart');

    expect(
      sections,
      matches(RegExp(r'family:\s*AppExpressiveDestinationFamily\.catalog')),
    );
    expect(
      sections,
      matches(RegExp(r'family:\s*AppExpressiveDestinationFamily\.logbook')),
    );
    expect(
      sections,
      matches(
        RegExp(
          r'expressiveCatalogPresentation:\s*context\.usesExpressivePresentation',
        ),
      ),
    );
    expect(
      dashboard,
      matches(RegExp(r'family:\s*AppExpressiveDestinationFamily\.logbook')),
    );
  });

  test('Expressive workout catalog pickers retain Catalog presentation', () {
    final fab = _read('lib/widgets/add_exercise_fab.dart');
    final train2 = _read('lib/screens/exercise/train2_page.dart');
    final swap = _read('lib/widgets/swap_exercise_sheet.dart');

    expect(
      fab,
      matches(
        RegExp(
          r'expressiveCatalogPresentation:\s*ctx\.usesExpressivePresentation',
        ),
      ),
    );
    expect(
      train2,
      matches(
        RegExp(
          r'expressiveCatalogPresentation:\s*context\.usesExpressivePresentation',
        ),
      ),
    );
    expect(
      swap,
      matches(
        RegExp(
          r'expressiveCatalogPresentation:\s*context\.usesExpressivePresentation',
        ),
      ),
    );
    for (final source in [fab, train2, swap]) {
      expect(
        source,
        matches(RegExp(r'family:\s*AppExpressiveDestinationFamily\.catalog')),
      );
    }
  });
}

String _read(String path) => File(path).readAsStringSync();
