/// Dummy class representing a sample of sensor data within the context of programming
/// advanced reactions in a data route.
abstract class DataToken {
  /// Creates a <code>DataToken</code> copy that represents a portion of the original data
  /// @param offset        Byte to start copying from
  /// @param length        Number of bytes to copy
  DataToken slice(int offset, int length);
}
