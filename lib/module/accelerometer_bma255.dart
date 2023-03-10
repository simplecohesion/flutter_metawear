import 'dart:ffi';
import 'dart:math';

import 'package:flutter_metawear/module/accelerometer_bosch.dart'
    as AccelerometerBosch;
import 'package:flutter_metawear/module/accelerometer.dart' as Accelerometer;

/// Operating frequencies of the accelerometer

class OutputDataRate {
  /// Frequency represented as a float value
  final double frequency;

  const OutputDataRate._(this.frequency);

  /// 15.62 Hz
  static const ODR_15_62HZ = const OutputDataRate._(15.62);

  /// 31.26 Hz
  static const ODR_31_26HZ = const OutputDataRate._(31.26);

  /// 62.5 Hz
  static const ODR_62_5HZ = const OutputDataRate._(62.5);

  /// 125 Hz
  static const ODR_125HZ = const OutputDataRate._(125);

  /// 250 Hz
  static const ODR_250HZ = const OutputDataRate._(250);

  /// 500 Hz
  static const ODR_500HZ = const OutputDataRate._(500);

  /// 1000 Hz
  static const ODR_1000HZ = const OutputDataRate._(1000);

  /// 2000 Hz
  static const ODR_2000HZ = const OutputDataRate._(2000);

  static List<OutputDataRate> _entires = [
    ODR_15_62HZ,
    ODR_31_26HZ,
    ODR_62_5HZ,
    ODR_125HZ,
    ODR_250HZ,
    ODR_500HZ,
    ODR_1000HZ,
    ODR_2000HZ
  ];

  static List<double> frequencies() {
    return _entires.map((f) => f.frequency).toList(growable: false);
  }
}

/// Enumeration of hold times for flat detection

class FlatHoldTime {
  /// Periods represented as a float value
  final double delay;

  const FlatHoldTime._(this.delay);

  /// 0 milliseconds
  static const FHT_0_MS = const FlatHoldTime._(0);

  /// 512 milliseconds
  static const FHT_512_MS = const FlatHoldTime._(512);

  /// 1024 milliseconds
  static const FHT_1024_MS = const FlatHoldTime._(1024);

  /// 2048 milliseconds
  static const FHT_2048_MS = const FlatHoldTime._(2048);

  static List<FlatHoldTime> _entires = [
    FHT_0_MS,
    FHT_512_MS,
    FHT_1024_MS,
    FHT_2048_MS
  ];

  static FlatHoldTime nearest(double value) {
    var dist =
        _entires.map((e) => (e.delay - value).abs()).toList(growable: false);
    return _entires[dist.indexOf(dist.reduce(min))];
  }

  static List<double> delays() {
    return _entires.map((e) => e.delay).toList(growable: false);
  }
}

/// Accelerometer configuration editor specific to the BMA255 accelerometer

abstract class ConfigEditor extends Accelerometer.ConfigEditor<ConfigEditor> {
  /// Set the output data rate
  /// @param odr    New output data rate
  /// @return Calling object
  ConfigEditor odr(double odr);

  /// Set the data range
  /// @param fsr    New data range
  /// @return Calling object
  ConfigEditor range(double fsr);
}

/// Configuration editor specific to BMA255 flat detection

abstract class FlatConfigEditor
    implements AccelerometerBosch.FlatConfigEditor<FlatConfigEditor> {
  FlatConfigEditor holdTime(FlatHoldTime time);
}

/// Extension of the {@link AccelerometerBosch.FlatDataProducer} interface providing
/// configuration options specific to the BMA255 accelerometer

abstract class FlatDataProducer implements AccelerometerBosch.FlatDataProducer {
  /// Configure the flat detection algorithm
  /// @return BMA255 specific configuration editor object
  @override
  FlatConfigEditor configure();
}

/// Extension of the {@link AccelerometerBosch} interface providing finer control of the BMA255 accelerometer

abstract class AccelerometerBma255
    extends AccelerometerBosch.AccelerometerBosch {
  /// Configure the BMA255 accelerometer
  /// @return Editor object specific to the BMA255 accelerometer
  @override
  ConfigEditor configure();

  /// Get an implementation of the BMA255 specific FlatDataProducer interface
  /// @return BMA255 specific FlatDataProducer object
  @override
  FlatDataProducer flat();
}
