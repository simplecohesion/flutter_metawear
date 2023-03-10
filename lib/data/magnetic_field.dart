import 'package:sprintf/sprintf.dart';
import 'package:vector_math/vector_math.dart';

/// Encapsulates magnetic field strength data, values are in micro tesla
class MagneticField extends Vector3 {
  static const String tesla = "T";

  MagneticField(double x, double y, double z) : super.zero() {
    this[0] = x;
    this[1] = y;
    this[2] = z;
  }

  @override
  String toString() {
    return sprintf(
        "{x: %.3f%s, y: %.3f%s, z: %.3f%s}", [x, tesla, y, tesla, z, tesla]);
  }
}
