import 'dart:typed_data';

import 'package:flutter_metawear/data.dart';
import 'package:flutter_metawear/impl/Util.dart';
import 'package:sprintf/sprintf.dart';

// abstract class ClassToObject {
//   Object? apply<T>();
// }

// abstract class DataPrivate implements Data {
//   final DateTime _timestamp;
//   final Uint8List _dataBytes;
//   final T? Function<T>()? _mapper;

//   DataPrivate(this._timestamp, this._dataBytes, this._mapper);

//   @override
//   DateTime timestamp() {
//     return _timestamp;
//   }

//   @override
//   String formattedTimestamp() {
//     return timestamp().toIso8601String();
//   }

//   @override
//   double scale() => 1.0;

//   @override
//   Uint8List bytes() => _dataBytes;

//   @override
//   T value<T>() {
//     throw TypeError();
//   }

//   T extra<T>() {
//     Object? value;
//     if (_mapper == null || (value = _mapper!.call()) == null) {
//       throw TypeError();
//     }

//     return value! as T;
//   }

//   @override
//   String toString() => sprintf("{timestamp: %s, data: %s}",
//       [formattedTimestamp(), Util.arrayToHexString(bytes())]);
// }

class DataPrivate implements Data {
  final DateTime _timestamp;
  final Uint8List _dataBytes;
  final T? Function<T>()? _mapper;
  final double Function()? _scale;
  final T? Function<T>()? _value;

  DataPrivate(this._timestamp, this._dataBytes, this._mapper,
      [this._scale, this._value]);

  @override
  DateTime timestamp() {
    return _timestamp;
  }

  @override
  String formattedTimestamp() {
    return timestamp().toIso8601String();
  }

  @override
  double scale() => _scale();

  @override
  Uint8List bytes() => _dataBytes;

  @override
  T value<T>() => _value<T>();

  T extra<T>() {
    Object value;
    if (_mapper == null || (value = _mapper!.call()) == null) {
      throw TypeError();
    }
    return value;
  }

  @override
  String toString() => sprintf("{timestamp: %s, data: %s}",
      [formattedTimestamp(), Util.arrayToHexString(bytes())]);
}
