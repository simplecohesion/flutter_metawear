import 'package:flutter_metawear/config_editor_base.dart';
import 'package:flutter_metawear/configurable.dart';
import 'package:flutter_metawear/forced_data_producer.dart';
import 'package:flutter_metawear/meta_wear_board.dart';
import 'package:sprintf/sprintf.dart';

/// Analog gain scales
enum Gain { TCS34725_1X, TCS34725_4X, TCS34725_16X, TCS34725_60X }

/// Configurable parameters for the color detector
abstract class ConfigEditor extends ConfigEditorBase {
  /// Set the integration time, which impacts both the resolution and sensitivity of the adc values.
  /// @param time    Between [2.4, 614.4] milliseconds
  /// @return Calling object
  ConfigEditor integrationTime(double time);

  /// Set the analog gain
  /// @param gain    Gain scale
  /// @return Calling object
  ConfigEditor gain(Gain gain);

  /// Enable the illuminator LED
  /// @return Calling object
  ConfigEditor enableIlluminatorLed();
}

/// Wrapper class encapsulating adc data from the sensor
class ColorAdc {
  final int clear, red, green, blue;

  ColorAdc(this.clear, this.red, this.green, this.blue);

  @override
  String toString() => sprintf("{clear: %d, red: %d, green: %d, blue: %d}",
      [this.clear, this.red, this.green, this.blue]);

  @override
  bool operator ==(other) =>
      other is ColorAdc &&
      this.clear == other.clear &&
      this.red == other.red &&
      this.green == other.green &&
      this.blue == other.blue;

  @override
  int get hashCode {
    int result = clear;
    result = 31 * result + red;
    result = 31 * result + green;
    result = 31 * result + blue;
    return result;
  }
}

/// Extension of the {@link ForcedDataProducer} interface providing names for the component values
/// of the color adc data

abstract class ColorAdcDataProducer implements ForcedDataProducer {
  /// Get the name for clear adc data
  /// @return Clear adc data name
  String clearName();

  /// Get the name for red adc data
  /// @return Red adc data name
  String redName();

  /// Get the name for green adc data
  /// @return Green adc data name
  String greenName();

  /// Get the name for blue adc data
  /// @return Blue adc data name
  String blueName();
}

/// Color light-to-digital converter by TAOS that can sense red, green, blue, and clear light

abstract class ColorTcs34725 extends Module
    implements Configurable<ConfigEditor> {
  /// Get an implementation of the ColorAdcDataProducer interface, represented by the {@link ColorAdc} class
  /// @return Object managing the adc data
  ColorAdcDataProducer adc();
}
