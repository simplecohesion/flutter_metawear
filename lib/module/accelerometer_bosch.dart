import 'package:flutter_metawear/config_editor_base.dart';
import 'package:flutter_metawear/data/sign.dart';
import 'package:flutter_metawear/data/tap_type.dart';
import 'package:flutter_metawear/module/accelerometer.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_metawear/async_data_producer.dart';
import 'package:flutter_metawear/configurable.dart';

/// Available data ranges
class AccRange {
  final int bitmask;
  final double scale, range;

  const AccRange._(this.bitmask, this.scale, this.range);

  // +-2g
  static const AR_2G = const AccRange._(0x3, 16384, 2.0);
  // +-4g
  static const AR_4G = const AccRange._(0x5, 8192, 4.0);
  // +-5g
  static const AR_8G = const AccRange._(0x8, 4096, 8.0);
  // +-16g
  static const AR_16G = const AccRange._(0xc, 2048, 16);

  static final Map<int, AccRange> _bitMaskToRange = {
    AR_2G.bitmask: AR_2G,
    AR_4G.bitmask: AR_4G,
    AR_8G.bitmask: AR_8G,
    AR_16G.bitmask: AR_16G
  };

  static AccRange bitMaskToRange(int bitmask) {
    return _bitMaskToRange[bitmask]!;
  }

  static List<AccRange> get values => [AR_2G, AR_4G, AR_8G, AR_16G];

  static List<double> ranges() {
    return [AR_2G.range, AR_4G.range, AR_8G.range, AR_16G.range];
  }
}

/// Calculation modes controlling the conditions that determine the sensor's orientation

enum OrientationMode {
  /// Default mode
  SYMMETRICAL,
  HIGH_ASYMMETRICAL,
  LOW_ASYMMETRICAL
}

/// Configuration editor for the orientation detection algorithm

abstract class OrientationConfigEditor implements ConfigEditorBase {
  /// Set the hysteresis offset for portrait/landscape detection
  /// @param hysteresis    New offset angle, in degrees
  /// @return Calling object
  OrientationConfigEditor hysteresis(double hysteresis);

  /// Set the orientation calculation mode
  /// @param mode    New calculation mode
  /// @return Calling object
  OrientationConfigEditor mode(OrientationMode mode);
}

/// Accelerometer agnostic interface for configuring flat detection algorithm
/// @param <T>    Type of flat detection config editor

abstract class FlatConfigEditor<T> implements ConfigEditorBase {
  /**
     * Set the delay for which the flat value must remain stable for a flat interrupt.  The closest,
     * valid delay will be chosen depending on underlying sensor
     * @param time    Delay time for a stable value
     * @return Calling object
     */
  //T holdTime(double time);
  /// Set the threshold defining a flat position
  /// @param angle    Threshold angle, between [0, 44.8] degrees
  /// @return Calling object
  T flatTheta(double angle);
}

/// Wrapper class encapsulating the data from a low/high g interrupt

class LowHighResponse {
  /// True if the interrupt from from low-g motion
  final bool isLow;

  /// True if the interrupt from from high-g motion.  If it is not high-g motion, there is no
  /// need to check the high-g variables
  final bool isHigh;

  /// True if the x-axis triggered high-g interrupt
  final bool highGx;

  /// True if the y-axis triggered high-g interrupt
  final bool highGy;

  /// True if the z-axis triggered high-g interrupt
  final bool highGz;

  /// Direction of the high-g motion interrupt
  final Sign highSign;

  LowHighResponse(this.isHigh, this.isLow, this.highGx, this.highGy,
      this.highGz, this.highSign);

  @override
  bool operator ==(other) =>
      other is LowHighResponse &&
      this.isLow == other.isLow &&
      this.isHigh == other.isHigh &&
      this.highGx == other.highGx &&
      this.highGy == other.highGy &&
      this.highGz == other.highGz &&
      this.highSign == other.highSign &&
      this.highSign == other.highSign;

  @override
  int get hashCode {
    int result = (isHigh ? 1 : 0);
    result = 31 * result + (isLow ? 1 : 0);
    result = 31 * result + (highGx ? 1 : 0);
    result = 31 * result + (highGy ? 1 : 0);
    result = 31 * result + (highGz ? 1 : 0);
    result = 31 * result + highSign.hashCode;
    return result;
  }

  @override
  String toString() => sprintf(
      "{low: %s, high: %s, high_x: %s, high_y: %s, high_z: %s, high_direction: %s}",
      [isLow, isLow, highGx, highGy, highGz, highSign.toString()]);
}

/// Interrupt modes for low-g detection

enum LowGMode {
  /// Compare |acc_x|, |acc_y|, |acc_z| with the low threshold
  SINGLE,

  /// Compare |acc_x| + |acc_y| + |acc_z| with the low threshold
  SUM
}

/// Interface for configuring low/high g detection

abstract class LowHighConfigEditor extends ConfigEditorBase {
  /// Enable low g detection on all 3 axes
  /// @return Calling object
  LowHighConfigEditor enableLowG();

  /// Enable high g detection on the x-axis
  /// @return Calling object
  LowHighConfigEditor enableHighGx();

  /// Enable high g detection on the y-axis
  /// @return Calling object
  LowHighConfigEditor enableHighGy();

  /// Enable high g detection on the z-axis
  /// @return Calling object
  LowHighConfigEditor enableHighGz();

  /// Set the minimum amount of time the acceleration must stay below (ths + hys) for an interrupt
  /// @param duration    Duration between [2.5, 640] milliseconds
  /// @return Calling object
  LowHighConfigEditor lowDuration(int duration);

  /// Set the threshold that triggers a low-g interrupt
  /// @param threshold    Low-g interrupt threshold, between [0.00391, 2.0] g
  /// @return Calling object
  LowHighConfigEditor lowThreshold(double threshold);

  /// Set the hysteresis level for low-g interrupt
  /// @param hysteresis    Low-g interrupt hysteresis, between [0, 0.375]g
  /// @return Calling object
  LowHighConfigEditor lowHysteresis(double hysteresis);

  /// Set mode for low-g detection
  /// @param mode    Low-g detection mode
  /// @return Calling object
  LowHighConfigEditor lowGMode(LowGMode mode);

  /// Set the minimum amount of time the acceleration sign does not change for an interrupt
  /// @param duration    Duration between [2.5, 640] milliseconds
  /// @return Calling object
  LowHighConfigEditor highDuration(int duration);

  /// Set the threshold for clearing high-g interrupt
  /// @param threshold    High-g clear interrupt threshold
  /// @return Calling object
  LowHighConfigEditor highThreshold(double threshold);

  /// Set the hysteresis level for clearing the high-g interrupt
  /// @param hysteresis    Hysteresis for clearing high-g interrupt
  /// @return Calling object
  LowHighConfigEditor highHysteresis(double hysteresis);
}

/// On-board algorithm that detects changes in the sensor's orientation.  Data is represented as
/// a {@link SensorOrientation} object.

abstract class OrientationDataProducer
    with AsyncDataProducer
    implements Configurable<OrientationConfigEditor> {}

/// On-board algorithm that detects when low (i.e. free fall) or high g acceleration is measured

abstract class LowHighDataProducer
    with AsyncDataProducer
    implements Configurable<LowHighConfigEditor> {}

/// Configuration editor for no-motion detection

abstract class NoMotionConfigEditor implements ConfigEditorBase {
  /// Set the duration
  /// @param duration    Time, in milliseconds, for which no slope data points exceed the threshold
  /// @return Calling object
  NoMotionConfigEditor duration(int duration);

  /// Set the tap threshold.  This value is shared with slow motion detection.
  /// @param threshold    Threshold, in Gs, for which no slope data points must exceed
  /// @return Calling object
  NoMotionConfigEditor threshold(double threshold);
}

/// Detects when the slope of acceleration data is below a threshold for a period of time.

abstract class NoMotionDataProducer
    with AsyncDataProducer, MotionDetection
    implements Configurable<NoMotionConfigEditor> {}

/// Wrapper class encapsulating interrupts from any motion detection

class AnyMotion {
  /// Slope sign of the triggering motion
  final Sign sign;

  /// True if x-axis triggered the motion interrupt
  final bool xAxisActive;

  /// True if y-axis triggered the motion interrupt
  final bool yAxisActive;

  /// True if z-axis triggered the motion interrupt
  final bool zAxisActive;

  AnyMotion(this.sign, this.xAxisActive, this.yAxisActive, this.zAxisActive);

  @override
  bool operator ==(other) {
    return other is AnyMotion &&
        this.xAxisActive == other.xAxisActive &&
        this.yAxisActive == other.yAxisActive &&
        this.zAxisActive == other.zAxisActive &&
        this.sign == other.sign;
  }

  @override
  int get hashCode {
    int result = sign.hashCode;
    result = 31 * result + (xAxisActive ? 1 : 0);
    result = 31 * result + (yAxisActive ? 1 : 0);
    result = 31 * result + (zAxisActive ? 1 : 0);
    return result;
  }

  @override
  String toString() {
    return sprintf(
        "{direction: %s, x-axis active: %s, y-axis active: %s, z-axis active: %s}",
        [sign, xAxisActive, yAxisActive, zAxisActive]);
  }
}

/// Configuration editor for any-motion detection

abstract class AnyMotionConfigEditor implements ConfigEditorBase {
  /// Set the number of consecutive slope data points that must be above the threshold for an interrupt to occur
  /// @param count    Number of consecutive slope data points
  /// @return Calling object
  AnyMotionConfigEditor count(int count);

  /// Set the threshold that the slope data points must be above
  /// @param threshold    Any motion threshold, in g's
  /// @return Calling object
  AnyMotionConfigEditor threshold(double threshold);
}

/// Detects when a number of consecutive slope data points is above a threshold.

abstract class AnyMotionDataProducer
    with MotionDetection, AsyncDataProducer
    implements Configurable<AnyMotionConfigEditor> {}

/// Configuration editor for slow-motion detection

abstract class SlowMotionConfigEditor implements ConfigEditorBase {
  /// Set the number of consecutive slope data points that must be above the threshold for an interrupt to occur
  /// @param count    Number of consecutive slope data points
  /// @return Calling object
  SlowMotionConfigEditor count(int count);

  /// Set the tap threshold.  This value is shared with no motion detection
  /// @param threshold    Threshold, in Gs, for which no slope data points must exceed
  /// @return Calling object
  SlowMotionConfigEditor threshold(double threshold);
}

/// Similar to any motion detection except no information is stored regarding what triggered the interrupt.

abstract class SlowMotionDataProducer
    with MotionDetection, AsyncDataProducer
    implements Configurable<SlowMotionConfigEditor> {}

/// Wrapper class encapsulating responses from tap detection

class Tap {
  /// Tap type of the response
  final TapType type;

  /// Sign of the triggering signal
  final Sign sign;

  Tap(this.type, this.sign);

  @override
  bool operator ==(other) {
    return other is Tap && this.type == other.type && this.sign == other.sign;
  }

  @override
  String toString() {
    return sprintf("{type: %s, direction: %s}", [type, sign]);
  }
}

/// Available quiet times for double tap detection

enum TapQuietTime {
  /// 30ms
  TQT_30_MS,

  /// 20ms
  TQT_20_MS
}

/// Available shock times for tap detection

enum TapShockTime {
  /// 50ms
  TST_50_MS,

  /// 75ms
  TST_75_MS
}

/// Available windows for double tap detection

enum DoubleTapWindow {
  /// 50ms
  DTW_50_MS,

  /// 100ms
  DTW_100_MS,

  /// 150ms
  DTW_150_MS,

  /// 200ms
  DTW_200_MS,

  /// 250ms
  DTW_250_MW,

  /// 375ms
  DTW_375_MS,

  /// 500ms
  DTW_500_MS,

  /// 700ms
  DTW_700_MS
}

/// Configuration editor for the tap detection algorithm

abstract class TapConfigEditor extends ConfigEditorBase {
  /// Enable double tap detection
  /// @return Calling object
  TapConfigEditor enableDoubleTap();

  /// Enable single tap detection
  /// @return Calling object
  TapConfigEditor enableSingleTap();

  /// Set the time that must pass before a second tap can occur
  /// @param time    New quiet time
  /// @return Calling object
  TapConfigEditor quietTime(TapQuietTime time);

  /// Set the time to lock the data in the status register
  /// @param time    New shock time
  /// @return Calling object
  TapConfigEditor shockTime(TapShockTime time);

  /// Set the length of time for a second shock to occur for a double tap
  /// @param window    New double tap window
  /// @return Calling object
  TapConfigEditor doubleTapWindow(DoubleTapWindow window);

  /// Set the threshold that the acceleration difference must exceed for a tap, in g's
  /// @param threshold    New tap threshold
  /// @return Calling object
  TapConfigEditor threshold(double threshold);
}

/// On-board algorithm that detects taps

abstract class TapDataProducer
    implements /*AsyncDataProducer,*/ Configurable<TapConfigEditor> {}

/// On-board algorithm that detects whether the senor is laying flat or not

abstract class FlatDataProducer<T extends FlatConfigEditor>
    with AsyncDataProducer
    implements Configurable<T> {}

/// Motion detection algorithms on Bosch sensors.  Only one type of motion detection can be active at a time.

abstract class MotionDetection {}

/// Extension of the {@link Accelerometer} providing general access to a Bosch accelerometer.  If you know specifically which
/// Bosch accelerometer is on your board, use the appropriate subclass instead.

/// @see AccelerometerBma255
/// @see AccelerometerBmi160
abstract class AccelerometerBosch extends Accelerometer {
  /// Get an implementation of the OrientationDataProducer interface
  /// @return OrientationDataProducer object
  OrientationDataProducer orientation();

  /// Get an implementation of the FlatDataProducer interface
  /// @return FlatDataProducer object
  FlatDataProducer flat();

  /// Get an implementation of the LowHighDataProducer interface
  /// @return LowHighDataProducer object
  LowHighDataProducer lowHigh();

  /// Get an implementation of the MotionDetection interface.
  /// @param motionClass    Type of motion detection to use
  /// @param <T>            Runtime type the returned value is casted as
  /// @return MotionDetection object, null if the motion detection type is not supported
  T motion<T extends MotionDetection>(Type motionClass);

  /// Get an implementation of the TapDataProducer interface
  /// @return TapDataProducer object
  TapDataProducer tap();
}
