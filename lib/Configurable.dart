import 'package:flutter_metawear/ConfigEditorBase.dart';

/// Attribute indicating the object can be configured
/// @param <T>    Type that modifies this object's configuration
abstract class Configurable<T extends ConfigEditorBase> {
  /// Configure the object
  /// @return Config editor object
  T configure();
}
