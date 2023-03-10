import 'dart:typed_data';

import 'package:flutter_metawear/data.dart';
import 'package:flutter_metawear/builder/route_component.dart';
import 'package:flutter_metawear/impl/DataAttributes.dart';
import 'package:flutter_metawear/impl/DataPrivate.dart';
import 'package:flutter_metawear/impl/DataTypeBase.dart';
import 'package:flutter_metawear/impl/IntData.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/DataProcessorConfig.dart';
import 'package:flutter_metawear/impl/Util.dart';
import 'package:flutter_metawear/impl/DataProcessorImpl.dart';
import 'package:tuple/tuple.dart';

class UintData extends DataTypeBase {
  UintData(
    ModuleType module,
    int register,
    DataAttributes attributes, {
    int? id,
    DataTypeBase? input,
  }) : super(module, register, attributes, id: id, input: input);

  @override
  DataTypeBase copy(DataTypeBase input, ModuleType module, int register, int id,
      DataAttributes attributes) {
    return new UintData(module, register, attributes, input: input, id: id);
  }

  @override
  num convertToFirmwareUnits(MetaWearBoardPrivate mwPrivate, num value) {
    return value;
  }

  @override
  Data createMessage(bool logData, MetaWearBoardPrivate mwPrivate,
      Uint8List data, DateTime timestamp, T Function<T>() apply) {
    final Uint8List buffer = Util.bytesToUIntBuffer(logData, data, attributes);
    return DataPrivate2(timestamp, data, apply, () => 1.0, <T>() {
      if (T is bool) {
        return ByteData.view(buffer.buffer).getInt8(0) > 0 as T;
      }
      if (T is int) {
        return ByteData.view(buffer.buffer).getInt64(0) as T;
      }
      throw TypeError();
    });
  }

  @override
  Tuple2<DataTypeBase?, DataTypeBase?> dataProcessorTransform(
      DataProcessorConfig config, DataProcessorImpl dpModule) {
    switch (config.id) {
      case Maths.ID:
        {
          Maths casted = config as Maths;
          DataTypeBase? processor;
          switch (casted.op) {
            case Operation.ADD:
              {
                DataAttributes newAttrs = attributes.dataProcessorCopySize(4);
                processor = casted.rhs < 0
                    ? new IntData(this, ModuleType.DATA_PROCESSOR,
                        DataProcessorImpl.NOTIFY, newAttrs)
                    : dataProcessorCopy(this, newAttrs);
                break;
              }
            case Operation.MULTIPLY:
              {
                DataAttributes newAttrs = attributes.dataProcessorCopySize(
                    casted.rhs.abs() < 1 ? attributes.sizes[0] : 4);
                processor = casted.rhs < 0
                    ? new IntData(this, ModuleType.DATA_PROCESSOR,
                        DataProcessorImpl.NOTIFY, newAttrs)
                    : dataProcessorCopy(this, newAttrs);
                break;
              }
            case Operation.DIVIDE:
              {
                DataAttributes newAttrs = attributes.dataProcessorCopySize(
                    casted.rhs.abs() < 1 ? 4 : attributes.sizes[0]);
                processor = casted.rhs < 0
                    ? new IntData(this, ModuleType.DATA_PROCESSOR,
                        DataProcessorImpl.NOTIFY, newAttrs)
                    : dataProcessorCopy(this, newAttrs);
                break;
              }
            case Operation.SUBTRACT:
              processor = new IntData(
                  this,
                  ModuleType.DATA_PROCESSOR,
                  DataProcessorImpl.NOTIFY,
                  attributes.dataProcessorCopySigned(true));
              break;
            case Operation.ABS_VALUE:
              processor = dataProcessorCopy(
                  this, attributes.dataProcessorCopySigned(false));
              break;
            default:
              processor = null;
          }
          if (processor != null) {
            return new Tuple2(processor, null);
          }
          break;
        }
      case Differential.ID:
        {
          Differential casted = config as Differential;
          if (casted.mode == DifferentialOutput.DIFFERENCE) {
            return Tuple2(
                new IntData(
                    this,
                    ModuleType.DATA_PROCESSOR,
                    DataProcessorImpl.NOTIFY,
                    attributes.dataProcessorCopySigned(true)),
                null);
          }
        }
    }
    return super.dataProcessorTransform(config, dpModule);
  }
}
