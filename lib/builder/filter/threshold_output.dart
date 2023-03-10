/// Output modes for the threshold filter
enum ThresholdOutput {
  /// Return the data as is
  ABSOLUTE,

  /// 1 if the data exceeded the threshold, -1 if below
  BINARY
}
