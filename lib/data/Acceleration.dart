import 'package:sprintf/sprintf.dart';
import 'package:vector_math/vector_math.dart';

/// Encapsulates acceleration data, values are in units of g's
class Acceleration extends Vector3 {
  static const String gees = "g";

  Acceleration(double x, double y, double z) : super.zero() {
    this[0] = x;
    this[1] = y;
    this[2] = z;
  }

  @override
  String toString() {
    return sprintf(
        "{x: %.3f%s, y: %.3f%s, z: %.3f%s}", [x, gees, y, gees, z, gees]);
  }
}
