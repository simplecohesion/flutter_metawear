import 'dart:typed_data';

import 'package:flutter_metawear/data.dart';
import 'package:flutter_metawear/impl/data_attributes.dart';
import 'package:flutter_metawear/impl/data_type_base.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'package:flutter_metawear/impl/data_private.dart';

class ByteArrayData extends DataTypeBase {
  ByteArrayData(
    ModuleType module,
    int register,
    DataAttributes attributes, {
    int? id,
    DataTypeBase? input,
  }) : super(module, register, attributes, input: input, id: id);

  @override
  DataTypeBase copy(
    DataTypeBase? input,
    ModuleType module,
    int register,
    int id,
    DataAttributes attributes,
  ) {
    return new ByteArrayData(module, register, attributes,
        input: input, id: id);
  }

  @override
  num convertToFirmwareUnits(MetaWearBoardPrivate mwPrivate, num value) {
    return value;
  }

  @override
  Data createMessage(
    bool logData,
    MetaWearBoardPrivate mwPrivate,
    Uint8List data,
    DateTime timestamp,
    T? Function<T>()? apply,
  ) {
    return DataPrivate2(timestamp, data, apply, () => 1.0, <T>() {
      if (T is Uint8List) {
        return data as T;
      }
      throw TypeError();
    });
  }
}
