import 'dart:core';

import 'package:sprintf/sprintf.dart';

class Version implements Comparable<Version> {
  static final RegExp _versionStringPattern =
      RegExp("(\\d+)\\.(\\d+)\\.(\\d+)");

//    static final long serialVersionUID = -6928626294821091652L;

  final int major;
  final int minor;
  final int step;

  Version(this.major, this.minor, this.step);

  factory Version.fromString(String versionString) {
    final matches = _versionStringPattern.firstMatch(versionString);

    if (matches == null) {
      throw new Exception(
          "Version string: $versionString does not match pattern X.Y.Z");
    }
    int major = int.parse(matches.group(1) ?? '0');
    int minor = int.parse(matches.group(2) ?? '0');
    int step = int.parse(matches.group(3) ?? '0');

    return Version(major, minor, step);
  }

  int weightedCompare(int left, int right) {
    if (left < right) {
      return -1;
    } else if (left > right) {
      return 1;
    }
    return 0;
  }

  @override
  int compareTo(Version other) {
    int sum = 4 * weightedCompare(major, other.major) +
        2 * weightedCompare(minor, other.minor) +
        weightedCompare(step, other.step);
    if (sum < 0) {
      return -1;
    } else if (sum > 0) {
      return 1;
    }
    return 0;
  }

  @override
  String toString() {
    return sprintf("%d.%d.%d", [major, minor, step]);
  }
}
