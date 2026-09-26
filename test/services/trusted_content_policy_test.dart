import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:env_test/services/trusted_content_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrustedContentPolicy', () {
    test('accepts only absolute HTTPS URLs without credentials', () {
      expect(
        () => TrustedContentPolicy.requireHttps(
          Uri.parse('https://cdn.example/media.webp'),
          description: 'Media',
        ),
        returnsNormally,
      );
      expect(
        () => TrustedContentPolicy.requireHttps(
          Uri.parse('http://cdn.example/media.webp'),
          description: 'Media',
        ),
        throwsFormatException,
      );
      expect(
        () => TrustedContentPolicy.requireHttps(
          Uri.parse('https://user:secret@cdn.example/media.webp'),
          description: 'Media',
        ),
        throwsFormatException,
      );
    });

    test('redirects remain HTTPS on the original authority', () {
      final origin = Uri.parse('https://cdn.example/manifests/media.json');
      expect(
        TrustedContentPolicy.validatedRedirect(origin, '../v2/media.json'),
        Uri.parse('https://cdn.example/v2/media.json'),
      );
      expect(
        () => TrustedContentPolicy.validatedRedirect(
          origin,
          'https://other.example/media.json',
        ),
        throwsA(isA<HttpException>()),
      );
      expect(
        () => TrustedContentPolicy.validatedRedirect(
          origin,
          'http://cdn.example/media.json',
        ),
        throwsFormatException,
      );
    });

    test('requires complete bounded integrity metadata', () {
      expect(
        TrustedContentPolicy.validatedSha256(List.filled(64, 'A').join()),
        List.filled(64, 'a').join(),
      );
      expect(
        () => TrustedContentPolicy.validatedSha256('short'),
        throwsFormatException,
      );
      expect(TrustedContentPolicy.validatedMediaBytes(512), 512);
      expect(
        () => TrustedContentPolicy.validatedMediaBytes(
          TrustedContentPolicy.maxMediaBytes + 1,
        ),
        throwsFormatException,
      );
    });

    test(
      'streams valid media and rejects corrupt or interrupted bodies',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'tonos_verified_media_',
        );
        addTearDown(() => directory.delete(recursive: true));
        final expected = sha256.convert([1, 2, 3]).toString();

        final valid = File(
          '${directory.path}${Platform.pathSeparator}valid.tmp',
        );
        await VerifiedMediaWriter.writeAtomically(
          Stream.value([1, 2, 3]),
          valid,
          expectedBytes: 3,
          expectedSha256: expected,
        );
        expect(await valid.readAsBytes(), [1, 2, 3]);

        final corrupt = File(
          '${directory.path}${Platform.pathSeparator}corrupt.tmp',
        );
        await corrupt.writeAsBytes([9, 9, 9]);
        await expectLater(
          VerifiedMediaWriter.writeAtomically(
            Stream.value([1, 2, 4]),
            corrupt,
            expectedBytes: 3,
            expectedSha256: expected,
          ),
          throwsFormatException,
        );
        expect(await corrupt.readAsBytes(), [9, 9, 9]);

        final interrupted = File(
          '${directory.path}${Platform.pathSeparator}interrupted.tmp',
        );
        await expectLater(
          VerifiedMediaWriter.writeAtomically(
            Stream.value([1, 2]),
            interrupted,
            expectedBytes: 3,
            expectedSha256: expected,
          ),
          throwsFormatException,
        );
        expect(await interrupted.exists(), isFalse);
        expect(
          await directory
              .list()
              .where((entry) => entry.path.endsWith('.download'))
              .isEmpty,
          isTrue,
        );
      },
    );
  });
}
