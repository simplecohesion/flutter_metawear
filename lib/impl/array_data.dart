import 'dart:typed_data';

import 'package:flutter_metawear/data.dart';
import 'package:flutter_metawear/impl/data_attributes.dart';
import 'package:flutter_metawear/impl/data_private.dart';
import 'package:flutter_metawear/impl/DataProcessorConfig.dart';
import 'package:flutter_metawear/impl/DataProcessorImpl.dart';
import 'package:flutter_metawear/impl/data_type_base.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'package:flutter_metawear/module/DataProcessor.dart';

class ArrayData extends DataTypeBase {
  ArrayData(
    ModuleType module,
    int register,
    DataAttributes attributes, {
    int? id,
    DataTypeBase? input,
  }) : super(module, register, attributes, id: id, input: input);

  @override
  DataTypeBase copy(DataTypeBase? input, ModuleType module, int register,
      int id, DataAttributes attributes) {
    return new ArrayData(module, register, attributes, input: input, id: id);
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
    DataProcessorImpl dpModules =
        mwPrivate.getModules()[DataProcessor] as DataProcessorImpl;
    Processor fuser = dpModules.activeProcessors[eventConfig[2]]!;

    while (!(fuser.editor.configObj is Fuser)) {
      fuser = dpModules
          .activeProcessors[fuser.editor.source.input!.eventConfig[2]]!;
    }

    DataTypeBase source = fuser.editor.source.input == null
        ? fuser.editor.source
        : fuser.editor.source.input!;

    int offset = 0;

    final List<Data> unwrappedData =
        List.generate(fuser.editor.config.length + 1, (i) {
      if (i == 0) {
        offset += source.attributes.length();
        return source.createMessage(logData, mwPrivate, data, timestamp, apply);
      }

      Processor value = dpModules.activeProcessors[fuser.editor.config[i + 1]]!;
      // buffer state holds the actual data type
      Uint8List portion = Uint8List(value.state.attributes.length());

      portion.setAll(0, data.skip(offset));
      offset += value.state.attributes.length();
      return value.state
          .createMessage(logData, mwPrivate, portion, timestamp, apply);
    });

    return DataPrivate2(timestamp, data, apply, () => this.scale(mwPrivate),
        <T>() {
      if (T is List<Data>) {
        return unwrappedData as T;
      }
      throw TypeError();
    });
  }
}
