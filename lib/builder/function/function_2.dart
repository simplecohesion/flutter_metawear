/// 2 operand functions that operate on sensor or processor data
enum Function2 {
  /// Add the data
  ADD,

  /// Multiply the data
  MULTIPLY,

  /// Divide the data
  DIVIDE,

  /// Calculate the remainder
  MODULUS,

  /// Calculate exponentiation of the data
  EXPONENT,

  /// Perform left shift
  LEFT_SHIFT,

  /// Perform right shift
  RIGHT_SHIFT,

  /// Subtract the data
  SUBTRACT,

  /// Transforms the input into a constant value
  CONSTANT
}
