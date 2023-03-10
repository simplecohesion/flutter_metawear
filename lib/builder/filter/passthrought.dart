/// Operation modes for the passthrough limiter
enum Passthrough {
  /// Allow all data through
  ALL,

  /// Only allow data through if value &gt; 0
  CONDITIONAL,

  /// Only allow a fixed number of data samples through
  COUNT
}
