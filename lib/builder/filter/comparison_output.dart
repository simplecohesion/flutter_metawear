/// Output modes for the comparison filter, only supported by firmware v1.2.3 or higher
enum ComparisonOutput {
  /// Input value is returned when the comparison is satisfied
  ABSOLUTE,

  /// The reference value that satisfies the comparison is returned, no output if none match
  REFERENCE,

  /// The index (0 based) of the value that satisfies the comparison is returned, n if none match
  ZONE,

  /// 0 if comparison failed, 1 if it passed
  PASS_FAIL
}
