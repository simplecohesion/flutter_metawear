import 'package:flutter_metawear/async_data_producer.dart';
import 'package:flutter_metawear/config_editor_base.dart';
import 'package:flutter_metawear/configurable.dart';
import 'package:flutter_metawear/forced_data_producer.dart';
import 'package:flutter_metawear/module/accelerometer.dart' as Accelerometer;
import 'package:flutter_metawear/module/accelerometer_bosch.dart'
    as AccelerometerBosch;
import 'package:flutter_metawear/module/accelerometer_bosch.dart';

enum FilterMode { OSR4, OSR2, NORMAL }

/// Operating frequencies of the BMI160 accelerometer

class OutputDataRate {
  /// Frequency represented as a float value
  final double frequency;

  const OutputDataRate._(this.frequency);

  /// 0.78125 Hz
  static const ODR_0_78125_HZ = OutputDataRate._(0.78125);

  /// 1.5625 Hz
  static const ODR_1_5625_HZ = OutputDataRate._(1.5625);

  /// 3.125 Hz
  static const ODR_3_125_HZ = OutputDataRate._(3.125);

  /// 6.25 Hz
  static const ODR_6_25_HZ = OutputDataRate._(6.25);

  /// 12.5 Hz
  static const ODR_12_5_HZ = OutputDataRate._(12.5);

  /// 25 Hz
  static const ODR_25_HZ = OutputDataRate._(25);

  /// 50 Hz
  static const ODR_50_HZ = OutputDataRate._(50);

  /// 100 Hz
  static const ODR_100_HZ = OutputDataRate._(100);

  /// 200 Hz
  static const ODR_200_HZ = OutputDataRate._(200);

  /// 400 Hz
  static const ODR_400_HZ = OutputDataRate._(400);

  /// 800 Hz
  static const ODR_800_HZ = OutputDataRate._(800);

  /// 1600 Hz
  static const ODR_1600_HZ = OutputDataRate._(1600);

  static List<OutputDataRate> _entries = [
    ODR_0_78125_HZ,
    ODR_1_5625_HZ,
    ODR_3_125_HZ,
    ODR_6_25_HZ,
    ODR_12_5_HZ,
    ODR_25_HZ,
    ODR_50_HZ,
    ODR_100_HZ,
    ODR_200_HZ,
    ODR_400_HZ,
    ODR_800_HZ,
    ODR_1600_HZ
  ];

  static List<double> get frequences {
    return _entries.map((e) => e.frequency).toList(growable: false);
  }
}

/// Accelerometer configuration editor specific to the BMI160 accelerometer

abstract class ConfigEditor extends Accelerometer.ConfigEditor<ConfigEditor> {
  /// Set the output data rate
  /// @param odr    New output data rate
  /// @return Calling object
  ConfigEditor odrType(OutputDataRate odr);

  /// Set the data range
  /// @param fsr    New data range
  /// @return Calling object
  ConfigEditor rangeType(AccelerometerBosch.AccRange fsr);

  /// Set the filter mode.  This parameter is ignored if the data rate is less than 12.5Hz
  /// @param mode New filter mode
  /// @return Calling object
  ConfigEditor filter(FilterMode mode);
}

/// Operation modes for the step detector

enum StepDetectorMode {
  /// Default mode with a balance between false positives and false negatives
  NORMAL,

  /// Mode for light weighted persons that gives few false negatives but eventually more false positives
  SENSITIVE,

  /// Gives few false positives but eventually more false negatives
  ROBUST
}

/// Configuration editor for the step detection algorithm

abstract class StepConfigEditor extends ConfigEditorBase {
  /// Set the operational mode of the step detector balancing sensitivity and robustness.
  /// @param mode    Detector sensitivity
  /// @return Calling object
  StepConfigEditor mode(StepDetectorMode mode);

  /// Write the configuration to the sensor
  void commit();
}

/// Interrupt driven step detection where each detected step triggers a data interrupt.  This data producer
/// cannot be used in conjunction with the {@link StepCounterDataProducer} interface.

abstract class StepDetectorDataProducer
    with AsyncDataProducer
    implements Configurable<StepConfigEditor> {}

/// Accumulates the number of detected steps in a counter that will send its current value on request.  This
/// data producer cannot be used in conjunction with the {@link StepDetectorDataProducer} interface.

abstract class StepCounterDataProducer
    with ForcedDataProducer
    implements Configurable<StepConfigEditor> {
  /// Reset the internal step counter
  void reset();
}

/// Enumeration of hold times for flat detection

class FlatHoldTime {
  /// Delays represented as a float value
  final double delay;

  const FlatHoldTime._(this.delay);

  /// 0 milliseconds
  static const FHT_0_MS = const FlatHoldTime._(0);

  /// 640 milliseconds
  static const FHT_640_MS = const FlatHoldTime._(640);

  /// 1280 milliseconds
  static const FHT_1280_MS = const FlatHoldTime._(1280);

  /// 2560 milliseconds
  static const FHT_2560_MS = const FlatHoldTime._(2560);

  static List<FlatHoldTime> _entires = [
    FHT_0_MS,
    FHT_640_MS,
    FHT_1280_MS,
    FHT_2560_MS
  ];

  static List<double> get delays =>
      _entires.map((f) => f.delay).toList(growable: false);
}

/// Configuration editor specific to BMI160 flat detection

abstract class FlatConfigEditor
    extends AccelerometerBosch.FlatConfigEditor<FlatConfigEditor> {
  FlatConfigEditor holdTime(FlatHoldTime time);
}

/// Extension of the {@link AccelerometerBosch.FlatDataProducer} interface providing
/// configuration options specific to the BMI160 accelerometer

abstract class FlatDataProducer extends AccelerometerBosch.FlatDataProducer {
  /// Configure the flat detection algorithm
  /// @return BMI160 specific configuration editor object
  @override
  FlatConfigEditor configure();
}

/// Skip times available for significant motion detection

enum SkipTime {
  /// 1.5s
  ST_1_5_S,

  /// 3s
  ST_3_S,

  /// 6s
  ST_6_S,

  /// 12s
  ST_12_S
}

/// Proof times available for significant motion detection

enum ProofTime {
  /// 0.25s
  PT_0_25_S,

  /// 0.5s
  PT_0_5_S,

  /// 1s
  PT_1_S,

  /// 2s
  PT_2_S
}

/// Configuration editor for BMI160 significant motion detection

abstract class SignificantMotionConfigEditor extends ConfigEditorBase {
  /// Set the skip time
  /// @param time    Number of seconds to sleep after movement is detected
  /// @return Calling object
  SignificantMotionConfigEditor skipTime(SkipTime time);

  /// Set the proof time
  /// @param time    Number of seconds that movement must still be detected after the skip time passed
  /// @return Calling object
  SignificantMotionConfigEditor proofTime(ProofTime time);
}

/// Detects when motion occurs due to a change in location.  Examples of this include walking or being in a moving vehicle.
/// Actions that do not trigger significant motion include standing stationary or movement from vibrational sources such
/// as a washing machine.

abstract class SignificantMotionDataProducer
    with MotionDetection, AsyncDataProducer
    implements Configurable<SignificantMotionConfigEditor> {}

/// Extension of the {@link AccelerometerBosch} interface providing finer control of the BMI160 accelerometer features

abstract class AccelerometerBmi160
    implements AccelerometerBosch.AccelerometerBosch {
  /// Configure the BMI160 accelerometer
  /// @return Editor object specific to the BMI160 accelerometer
  @override
  ConfigEditor configure();

  /// Get an implementation of the StepDetectorDataProducer interface
  /// @return StepDetectorDataProducer object
  StepDetectorDataProducer stepDetector();

  /// Get an implementation of the StepCounterDataProducer interface
  /// @return StepCounterDataProducer object
  StepCounterDataProducer stepCounter();

  /// Get an implementation of the BMI160 specific FlatDataProducer interface
  /// @return FlatDataProducer object
  @override
  FlatDataProducer flat();
}
