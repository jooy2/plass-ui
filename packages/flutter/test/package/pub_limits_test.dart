import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// pub.dev refuses a package whose README, CHANGELOG or LICENSE is over
/// 256 KiB, and it checks that only once the archive has been uploaded.
/// `dart pub publish --dry-run` passes a file that is too long, so without this
/// the first sign of it is a failed publish.
///
/// The changelog is the file that grows. `CHANGELOG.md` keeps only the
/// unreleased changes and the latest release for that reason, and
/// `CHANGELOG.archive.md`, which is not published, holds the rest. When this
/// fails on `CHANGELOG.md`, either an earlier release was left in it or the
/// latest one has outgrown the limit on its own.
void main() {
  const int limit = 256 * 1024;

  for (final String path in <String>['CHANGELOG.md', 'README.md', 'LICENSE']) {
    test('$path fits in what pub.dev accepts', () {
      final int size = File(path).lengthSync();

      expect(
        size,
        lessThanOrEqualTo(limit),
        reason: '$path is $size bytes, and pub.dev refuses one over $limit.',
      );
    });
  }
}
