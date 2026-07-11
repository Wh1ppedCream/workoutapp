import 'package:env_test/utils/async_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'mapWithConcurrency preserves order and limits simultaneous work',
    () async {
      var active = 0;
      var peak = 0;

      final results = await mapWithConcurrency<int, int>(
        [1, 2, 3, 4, 5],
        maxConcurrency: 2,
        mapper: (value, _) async {
          active++;
          peak = peak < active ? active : peak;
          await Future<void>.delayed(const Duration(milliseconds: 5));
          active--;
          return value * value;
        },
      );

      expect(results, [1, 4, 9, 16, 25]);
      expect(peak, lessThanOrEqualTo(2));
    },
  );
}
