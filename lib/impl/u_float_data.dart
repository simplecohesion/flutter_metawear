import 'dart:typed_data';

import 'package:flutter_metawear/data.dart';
import 'package:flutter_metawear/builder/route_component.dart';
import 'package:flutter_metawear/impl/data_attributes.dart';
import 'package:flutter_metawear/impl/DataPrivate.dart';
import 'package:flutter_metawear/impl/DataProcessorConfig.dart';
import 'package:flutter_metawear/impl/DataProcessorImpl.dart';
import 'package:flutter_metawear/impl/data_type_base.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/SFloatData.dart';
import 'package:flutter_metawear/impl/Util.dart';

import 'package:tuple/tuple.dart';

class UFloatData extends DataTypeBase {
  UFloatData(
    ModuleType module,
    int register,
    DataAttributes attributes, {
    int? id,
    DataTypeBase? input,
  }) : super(module, register, attributes, id: id, input: input);

  @override
  DataTypeBase copy(
    DataTypeBase? input,
    ModuleType module,
    int register,
    int id,
    DataAttributes attributes,
  ) {
    if (input == null) {
      if (this.input == null) {
        throw TypeError();
      }
      return this.input!.copy(null, module, register, id, attributes);
    }

    return new UFloatData(module, register, attributes, id: id, input: input);
  }

  @override
  num convertToFirmwareUnits(MetaWearBoardPrivate mwPrivate, num value) {
    return value.toDouble() * scale(mwPrivate);
  }

  @override
  Data createMessage(
    bool logData,
    MetaWearBoardPrivate mwPrivate,
    Uint8List data,
    DateTime timestamp,
    T Function<T>() apply,
  ) {
    Uint8List buffer = Util.bytesToUIntBuffer(logData, data, attributes);
    final double scaled =
        ByteData.view(buffer.buffer).getUint64(0, Endian.little) /
            scale(mwPrivate);
    return DataPrivate2(timestamp, data, apply, () => this.scale(mwPrivate),
        <T>() {
      if (T is double) {
        return scaled as T;
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
                    ? new SFloatData(ModuleType.DATA_PROCESSOR,
                        DataProcessorImpl.NOTIFY, newAttrs,
                        input: this)
                    : dataProcessorCopy(this, newAttrs);
                break;
              }
            case Operation.MULTIPLY:
              {
                DataAttributes newAttrs = attributes.dataProcessorCopySize(
                    casted.rhs.abs() < 1 ? attributes.sizes[0] : 4);
                processor = casted.rhs < 0
                    ? new SFloatData(ModuleType.DATA_PROCESSOR,
                        DataProcessorImpl.NOTIFY, newAttrs,
                        input: this)
                    : dataProcessorCopy(this, newAttrs);
                break;
              }
            case Operation.DIVIDE:
              {
                DataAttributes newAttrs = attributes.dataProcessorCopySize(
                    casted.rhs.abs() < 1 ? 4 : attributes.sizes[0]);
                processor = casted.rhs < 0
                    ? new SFloatData(ModuleType.DATA_PROCESSOR,
                        DataProcessorImpl.NOTIFY, newAttrs,
                        input: this)
                    : dataProcessorCopy(this, newAttrs);
                break;
              }
            case Operation.SUBTRACT:
              processor = new SFloatData(
                  ModuleType.DATA_PROCESSOR,
                  DataProcessorImpl.NOTIFY,
                  attributes.dataProcessorCopySigned(true),
                  input: this);
              break;
            case Operation.ABS_VALUE:
              processor = dataProcessorCopy(
                  this, attributes.dataProcessorCopySigned(false));
              break;
            default:
              processor = null;
              break;
          }

          if (processor != null) {
            return Tuple2(processor, null);
          }
          break;
        }
      case Differential.ID:
        {
          Differential casted = config as Differential;
          if (casted.mode == DifferentialOutput.DIFFERENCE) {
            return Tuple2(
                new SFloatData(
                    ModuleType.DATA_PROCESSOR,
                    DataProcessorImpl.NOTIFY,
                    attributes.dataProcessorCopySigned(true),
                    input: this),
                null);
          }
        }
    }
    return super.dataProcessorTransform(config, dpModule);
  }
}
