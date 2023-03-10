import 'package:sprintf/sprintf.dart';
import 'package:vector_math/vector_math.dart';

/// Encapsulates Euler angles, values are in degrees
class EulerAngles extends Vector4 {
  static const String degrees = "\u00B0";

  EulerAngles(double heading, double pitch, double roll, double yaw)
      : super.zero() {
    this[0] = heading;
    this[1] = pitch;
    this[2] = roll;
    this[3] = yaw;
  }

  /// Gets the heading angle
  /// @return Heading angel
  double heading() {
    return this[0];
  }

  /// Gets the pitch angle
  /// @return Pitch angle
  double pitch() {
    return this[1];
  }

  /// Gets the roll angle
  /// @return Roll angle
  double roll() {
    return this[2];
  }

  /// Gets the yaw angle
  /// @return Yaw angle
  double yaw() {
    return this[3];
  }

  @override
  String toString() {
    return sprintf(
        "{heading %.3f%s, pitch: %.3f%s, roll: %.3f%s, yaw: %.3f%s}", [
      heading(),
      degrees,
      pitch(),
      degrees,
      roll(),
      degrees,
      yaw(),
      degrees
    ]);
  }
}
