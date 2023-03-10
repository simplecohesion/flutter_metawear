/// Output types of the pulse finder
enum PulseOutput {
  /// Returns the number of samples in the pulse
  WIDTH,

  /// Returns a running sum of all samples in the pulse
  AREA,

  /// Returns the highest sample value in the pulse
  PEAK,

  /// Returns 0x1 as soon as a pulse is detected
  ON_DETECT
}
