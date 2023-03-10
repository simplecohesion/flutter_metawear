import 'package:vector_math/vector_math.dart';

/// Encapsulates Euler angles, values are in degrees
class EulerAngles extends Vector4 {
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
    return super[0];
  }

  /// Gets the pitch angle
  /// @return Pitch angle
  double pitch() {
    return super[1];
  }

  /// Gets the roll angle
  /// @return Roll angle
  double roll() {
    return super[2];
  }

  /// Gets the yaw angle
  /// @return Yaw angle
  double yaw() {
    return super[3];
  }
}
