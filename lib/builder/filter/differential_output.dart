/// Output modes for the differentiail filter
enum DifferentialOutput {
  /// Return the data as is
  ABSOLUTE,

  /// Return the difference between the value and its reference point
  DIFFERENCE,

  /// 1 if the difference is positive, -1 if negative
  BINARY
}
