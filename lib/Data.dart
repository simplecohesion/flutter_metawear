import 'dart:typed_data';

/// A sample of sensor data
abstract class Data {
  /// Time of when the data was received (streaming) or created (logging)
  /// @return Data timestamp
  DateTime timestamp();

  /// String representation of the timestamp in the format <code>YYYY-MM-DDTHH:MM:SS.LLL</code>.  The timezone
  /// of the string will be the local device's current timezone.
  /// @return Formatted string representing the timestamp
  String formattedTimestamp();

  /// LSB to units ratio.  Only used if developer is manually type casting the returned byte array from
  /// the {@link #bytes()} method
  /// @return Value corresponding to 1 unit
  double scale();

  /// Raw byte representation of the data value
  /// @return Byte array of the value
  Uint8List bytes();

  /// Converts the data bytes to a usable data type
  /// @param clazz     Class type to convert the value to
  /// @param <T>       Runtime type the return value is casted as
  /// @return Data value as the specified type
  /// @throws ClassCastException if the data cannot be casted to desired type
  T value<T>();

  /// Extra information attached to this data sample
  /// @param clazz     Class type to convert the value to
  /// @param <T>       Runtime type the return value is casted as
  /// @return Extra data casted as the specified type
  /// @throws ClassCastException if the data cannot be casted to the desired type
  T extra<T>();
}
