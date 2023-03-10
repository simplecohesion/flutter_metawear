import 'package:sprintf/sprintf.dart';
import 'package:vector_math/vector_math.dart';

/// Encapsulates angular velocity data, values are in degrees per second
class AngularVelocity extends Vector3 {
  static const String degreesPerSecond = "\u00B0/s";
  AngularVelocity(double x, double y, double z) : super.zero() {
    this[0] = x;
    this[1] = y;
    this[2] = z;
  }

  @override
  String toString() {
    return sprintf("{x: %.3f%s, y: %.3f%s, z: %.3f%s}",
        [x, degreesPerSecond, y, degreesPerSecond, z, degreesPerSecond]);
  }
}
