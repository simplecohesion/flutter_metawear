import 'package:flutter_metawear/meta_wear_board.dart';
import 'package:flutter_metawear/config_editor_base.dart';
import 'package:flutter_metawear/Configurable.dart';
import 'package:flutter_metawear/async_data_producer.dart';

/// Reports measured acceleration values from the accelerometer.  Combined xyz acceleration data is represented
/// by the {@link Acceleration} class and split data is interpreted as a float.

abstract class AccelerationDataProducer extends AsyncDataProducer {
  /// Get the name for x-axis data
  /// @return X-axis data name
  String xAxisName();

  /// Get the name for y-axis data
  /// @return Y-axis data name
  String yAxisName();

  /// Get the name for z-axis data
  /// @return Z-axis data name
  String zAxisName();
}

/// Accelerometer agnostic interface for configuring the sensor
/// @param <T>    Type of accelerometer config editor
abstract class ConfigEditor<T> extends ConfigEditorBase {
  /// Generic function for setting the output data rate.  The closest, valid frequency will be chosen
  /// depending on the underlying sensor
  /// @param odr    New output data rate, in Hz
  /// @return Calling object
  T odr(double odr);

  /// Generic function for setting the data range.  The closest, valid range will be chosen
  /// depending on the underlying sensor
  /// @param fsr    New data range, in g's
  /// @return Calling object
  T range(double fsr);
}

/// Measures sources of acceleration, such as gravity or motion.  This interface is provides general
/// access to an accelerometer. If you know specifically which accelerometer is on your board, use the
/// appropriate subclass instead.

/// @see AccelerometerBma255
/// @see AccelerometerBmi160
/// @see AccelerometerMma8452q
abstract class Accelerometer<T extends ConfigEditor> extends Module
    implements Configurable<T> {
  /// Get an implementation of the {@link AccelerationDataProducer} interface
  /// @return AccelerationDataProducer object
  AccelerationDataProducer acceleration();

  /// Variant of acceleration data that packs multiple data samples into 1 BLE packet to increase the
  /// data throughput.  Only streaming is supported for this data producer.
  /// @return AsyncDataProducer object for packed acceleration data
  AsyncDataProducer packedAcceleration();

  /// Switch the accelerometer into active mode
  void start();

  /// Switch the accelerometer into standby mode
  void stop();

  /// Get the output data rate.  The returned value is only meaningful if the API has configured the sensor
  /// @return Selected output data rate
  double getOdr();

  /// Get the data range.  The returned value is only meaningful if the API has configured the sensor
  /// @return Selected data range
  double getRange();

  /// Pulls the current accelerometer output data rate and data range from the sensor
  /// @return Task that is completed when the settings are received
  Future<void> pullConfigAsync();
}
