import 'dart:typed_data';

import 'package:flutter_metawear/data.dart';
import 'package:flutter_metawear/data_token.dart';
import 'package:flutter_metawear/impl/array_data.dart';
import 'package:flutter_metawear/builder/route_component.dart';
import 'package:flutter_metawear/impl/byte_array_data.dart';
import 'package:flutter_metawear/impl/data_attributes.dart';
import 'package:flutter_metawear/impl/DataProcessorConfig.dart';
import 'package:flutter_metawear/impl/DataProcessorImpl.dart';
import 'package:flutter_metawear/impl/IntData.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'package:flutter_metawear/impl/u_int_data.dart';
import 'package:flutter_metawear/impl/Util.dart';
import 'package:tuple/tuple.dart';

import 'package:flutter_metawear/impl/SerialPassthroughImpl.dart';
import 'package:flutter_metawear/impl/SettingsImpl.dart';
import 'package:flutter_metawear/impl/SensorFusionBoschImpl.dart';
import 'package:flutter_metawear/impl/SwitchImpl.dart';

import 'package:flutter_metawear/module/DataProcessor.dart';

import 'package:flutter_metawear/builder/predicate/pulse_output.dart';
import 'dart:math';

class _DataTypeBase extends DataTypeBase {
  _DataTypeBase.raw(Uint8List config, int offset, int length)
      : super.raw(config, offset, length);

  @override
  DataTypeBase copy(DataTypeBase? input, ModuleType? module, int register,
      int id, DataAttributes attributes) {
    throw UnsupportedError("Unsupported DataTypeBase");
  }

  @override
  Data createMessage(bool logData, MetaWearBoardPrivate mwPrivate,
      Uint8List data, DateTime timestamp, T Function<T>() apply) {
    throw UnsupportedError("Unsupported DataTypeBase");
  }
}

abstract class DataTypeBase implements DataToken {
  static String createUri(
      DataTypeBase dataType, MetaWearBoardPrivate mwPrivate) {
    String? uri;
    switch (ModuleType.lookupEnum(dataType.eventConfig[0])) {
      case ModuleType.SWITCH:
        uri = SwitchImpl.createUri(dataType);
        break;
      case ModuleType.DATA_PROCESSOR:
        uri = DataProcessorImpl.createUri(
            dataType,
            mwPrivate.getModules()[DataProcessor] as DataProcessorImpl,
            mwPrivate.getFirmwareVersion(),
            mwPrivate.lookupModuleInfo(ModuleType.DATA_PROCESSOR).revision);
        break;
      case ModuleType.SERIAL_PASSTHROUGH:
        uri = SerialPassthroughImpl.createUri(dataType);
        break;
      case ModuleType.SETTINGS:
        uri = SettingsImpl.createUri(dataType);
        break;
      case ModuleType.SENSOR_FUSION:
        uri = SensorFusionBoschImpl.createUri(dataType);
        break;
      default:
        uri = null;
        break;
    }

    if (uri == null) {
      throw new Exception("Cannot create uri for data type: " +
          Util.arrayToHexString(dataType.eventConfig));
    }
    return uri;
  }

  static final int _noDataId = 0xff;

  final Uint8List eventConfig;
  final DataAttributes attributes;
  final DataTypeBase? input;
  List<DataTypeBase>? split;

  DataTypeBase.raw(Uint8List config, int offset, int length)
      : eventConfig = config,
        input = null,
        split = null,
        attributes =
            DataAttributes(Uint8List.fromList([length]), 1, offset, false);

  DataTypeBase(
    ModuleType module,
    int register,
    DataAttributes attributes, {
    int? id,
    DataTypeBase? input,
  })  : this.eventConfig = Uint8List.fromList(
            [module.id, register, id == null ? _noDataId : id]),
        this.attributes = attributes,
        this.input = input {
    this.split = createSplits();
  }

  Tuple3<int, int, int> eventConfigAsTuple() {
    return Tuple3<int, int, int>(
        eventConfig[0], eventConfig[1], eventConfig[2]);
  }

  void read(MetaWearBoardPrivate mwPrivate, [Uint8List? parameters]) {
    if (parameters == null) {
      if (eventConfig[2] == _noDataId) {
        mwPrivate
            .sendCommand(Uint8List.fromList([eventConfig[0], eventConfig[1]]));
      } else {
        mwPrivate.sendCommand(eventConfig);
      }
    } else {
      Uint8List command = Uint8List(eventConfig.length + parameters.length);
      command.setAll(0, eventConfig);
      command.setAll(eventConfig.length, parameters);
      mwPrivate.sendCommand(command);
    }
  }

  void markSilent() {
    if ((eventConfig[1] & 0x80) == 0x80) {
      eventConfig[1] |= 0x40;
    }
  }

  void markLive() {
    if ((eventConfig[1] & 0x80) == 0x80) {
      eventConfig[1] &= ~0x40;
    }
  }

  double scale(MetaWearBoardPrivate mwPrivate) {
    return input?.scale(mwPrivate) ?? 1;
  }

  DataTypeBase copy(DataTypeBase? input, ModuleType module, int register,
      int id, DataAttributes attributes);

  DataTypeBase dataProcessorCopy(
      DataTypeBase input, DataAttributes attributes) {
    return copy(input, ModuleType.DATA_PROCESSOR, DataProcessorImpl.NOTIFY,
        _noDataId, attributes);
  }

  DataTypeBase dataProcessorStateCopy(
      DataTypeBase input, DataAttributes attributes) {
    return copy(input, ModuleType.DATA_PROCESSOR,
        Util.setSilentRead(DataProcessorImpl.STATE), _noDataId, attributes);
  }

  num convertToFirmwareUnits(MetaWearBoardPrivate mwPrivate, num value) {
    return value;
  }

  Data createMessage(bool logData, MetaWearBoardPrivate mwPrivate,
      Uint8List data, DateTime timestamp, T Function<T>() apply);

  Tuple2<DataTypeBase?, DataTypeBase?> dataProcessorTransform(
      DataProcessorConfig config, DataProcessorImpl dpModule) {
    switch (config.id) {
      case Buffer.ID:
        return Tuple2(
            UintData(ModuleType.DATA_PROCESSOR, DataProcessorImpl.NOTIFY,
                new DataAttributes(Uint8List(0), 0, 0, false),
                input: this),
            dataProcessorStateCopy(this, this.attributes));
      case Accumulator.ID:
        {
          Accumulator casted = config as Accumulator;
          DataAttributes attributes = new DataAttributes(
              Uint8List.fromList([casted.output]),
              1,
              0,
              !casted.counter && this.attributes.signed);

          return Tuple2(
              casted.counter
                  ? new UintData(ModuleType.DATA_PROCESSOR,
                      DataProcessorImpl.NOTIFY, attributes, input: this)
                  : dataProcessorCopy(this, attributes),
              casted.counter
                  ? new UintData(ModuleType.DATA_PROCESSOR,
                      Util.setSilentRead(DataProcessorImpl.STATE), attributes,
                      input: null, id: DataTypeBase._noDataId)
                  : dataProcessorStateCopy(this, attributes));
        }
      case Average.ID:
      case Delay.ID:
      case Time.ID:
        return Tuple2(
            dataProcessorCopy(this, this.attributes.dataProcessorCopy()), null);
      case PassthroughConfig.ID:
        return Tuple2(
            dataProcessorCopy(this, this.attributes.dataProcessorCopy()),
            new UintData(
                ModuleType.DATA_PROCESSOR,
                Util.setSilentRead(DataProcessorImpl.STATE),
                new DataAttributes(Uint8List.fromList([2]), 1, 0, false),
                id: DataTypeBase._noDataId));
      case Maths.ID:
        {
          Maths casted = config as Maths;
          DataTypeBase? processor;
          switch (casted.op) {
            case Operation.ADD:
              processor =
                  dataProcessorCopy(this, attributes.dataProcessorCopySize(4));
              break;
            case Operation.MULTIPLY:
              processor = dataProcessorCopy(
                  this,
                  attributes.dataProcessorCopySize(
                      casted.rhs.abs() < 1 ? attributes.sizes[0] : 4));
              break;
            case Operation.DIVIDE:
              processor = dataProcessorCopy(
                  this,
                  attributes.dataProcessorCopySize(
                      casted.rhs.abs() < 1 ? 4 : attributes.sizes[0]));
              break;
            case Operation.SUBTRACT:
              processor = dataProcessorCopy(
                  this, attributes.dataProcessorCopySigned(true));
              break;
            case Operation.ABS_VALUE:
              processor = dataProcessorCopy(
                  this, attributes.dataProcessorCopySigned(false));
              break;
            case Operation.MODULUS:
              {
                processor =
                    dataProcessorCopy(this, attributes.dataProcessorCopy());
                break;
              }
            case Operation.EXPONENT:
              {
                processor = new ByteArrayData(
                    ModuleType.DATA_PROCESSOR,
                    DataProcessorImpl.NOTIFY,
                    attributes.dataProcessorCopySize(4),
                    input: this);
                break;
              }
            case Operation.LEFT_SHIFT:
              {
                processor = new ByteArrayData(
                    ModuleType.DATA_PROCESSOR,
                    DataProcessorImpl.NOTIFY,
                    attributes.dataProcessorCopySize(
                        min(attributes.sizes[0] + (casted.rhs / 8).floor(), 4)),
                    input: this);
                break;
              }
            case Operation.RIGHT_SHIFT:
              {
                processor = new ByteArrayData(
                    ModuleType.DATA_PROCESSOR,
                    DataProcessorImpl.NOTIFY,
                    attributes.dataProcessorCopySize(
                        max(attributes.sizes[0] - (casted.rhs / 8).floor(), 1)),
                    input: this);
                break;
              }
            case Operation.SQRT:
              {
                processor = new ByteArrayData(
                    ModuleType.DATA_PROCESSOR,
                    DataProcessorImpl.NOTIFY,
                    attributes.dataProcessorCopySigned(false),
                    input: this);
                break;
              }
            case Operation.CONSTANT:
              DataAttributes attributes = new DataAttributes(
                  Uint8List.fromList([4]), 1, 0, casted.rhs >= 0);
              processor = attributes.signed
                  ? new IntData(this, ModuleType.DATA_PROCESSOR,
                      DataProcessorImpl.NOTIFY, attributes)
                  : new UintData(ModuleType.DATA_PROCESSOR,
                      DataProcessorImpl.NOTIFY, attributes,
                      input: this);
              break;
          }
          return Tuple2(processor, null);
        }
      case Pulse.ID:
        {
          Pulse casted = config as Pulse;
          DataTypeBase? processor;
          switch (casted.mode) {
            case PulseOutput.WIDTH:
              processor = new UintData(
                  ModuleType.DATA_PROCESSOR,
                  DataProcessorImpl.NOTIFY,
                  new DataAttributes(Uint8List.fromList([2]), 1, 0, false),
                  input: this);
              break;
            case PulseOutput.AREA:
              processor =
                  dataProcessorCopy(this, attributes.dataProcessorCopySize(4));
              break;
            case PulseOutput.PEAK:
              processor =
                  dataProcessorCopy(this, attributes.dataProcessorCopy());
              break;
            case PulseOutput.ON_DETECT:
              processor = new UintData(
                  ModuleType.DATA_PROCESSOR,
                  DataProcessorImpl.NOTIFY,
                  new DataAttributes(Uint8List.fromList([1]), 1, 0, false),
                  input: this);
              break;
            default:
              processor = null;
          }
          if (processor != null) {
            return Tuple2(processor, null);
          }
          break;
        }
      case ComparisonConfig.ID:
        {
          DataTypeBase? processor;
          if (config is SingleValueComparison) {
            processor =
                dataProcessorCopy(this, this.attributes.dataProcessorCopy());
          } else if (config is MultiValueComparison) {
            MultiValueComparison casted = config;
            if (casted.mode == ComparisonOutput.PASS_FAIL ||
                casted.mode == ComparisonOutput.ZONE) {
              processor = new UintData(
                  ModuleType.DATA_PROCESSOR,
                  DataProcessorImpl.NOTIFY,
                  new DataAttributes(Uint8List.fromList([1]), 1, 0, false),
                  input: this);
            } else {
              processor =
                  dataProcessorCopy(this, attributes.dataProcessorCopy());
            }
          }
          if (processor != null) {
            return Tuple2(processor, null);
          }
          break;
        }
      case Threshold.ID:
        {
          Threshold casted = config as Threshold;
          switch (casted.mode) {
            case ThresholdOutput.ABSOLUTE:
              return Tuple2(
                  dataProcessorCopy(this, attributes.dataProcessorCopy()),
                  null);
            case ThresholdOutput.BINARY:
              return Tuple2(
                  new IntData(
                      this,
                      ModuleType.DATA_PROCESSOR,
                      DataProcessorImpl.NOTIFY,
                      new DataAttributes(Uint8List.fromList([1]), 1, 0, true)),
                  null);
          }
        }
      case Differential.ID:
        {
          Differential casted = config as Differential;
          switch (casted.mode) {
            case DifferentialOutput.ABSOLUTE:
              return Tuple2(
                  dataProcessorCopy(this, attributes.dataProcessorCopy()),
                  null);
            case DifferentialOutput.DIFFERENCE:
              throw new Exception(
                  "Differential processor in 'difference' mode must be handled by subclasses");
            case DifferentialOutput.BINARY:
              return Tuple2(
                  new IntData(
                      this,
                      ModuleType.DATA_PROCESSOR,
                      DataProcessorImpl.NOTIFY,
                      new DataAttributes(Uint8List.fromList([1]), 1, 0, true)),
                  null);
          }
        }
      case Packer.ID:
        {
          Packer casted = config as Packer;
          return Tuple2(
              dataProcessorCopy(
                  this, attributes.dataProcessorCopyCopies(casted.count)),
              null);
        }
      case Accounter.ID:
        {
          Accounter casted = config as Accounter;
          return Tuple2(
              dataProcessorCopy(
                  this,
                  new DataAttributes(
                      Uint8List.fromList([casted.length, attributes.length()]),
                      1,
                      0,
                      attributes.signed)),
              null);
        }
      case Fuser.ID:
        {
          int fusedLength = attributes.length();
          Fuser casted = config as Fuser;

          for (int id in casted.filterIds) {
            fusedLength +=
                dpModule.activeProcessors[id]?.state.attributes.length() ?? 0;
          }

          return Tuple2(
              new ArrayData(
                  ModuleType.DATA_PROCESSOR,
                  DataProcessorImpl.NOTIFY,
                  new DataAttributes(
                      Uint8List.fromList([fusedLength]), 1, 0, false),
                  input: this),
              null);
        }
    }

    throw Exception("Unable to determine the DataTypeBase object for config: " +
        Util.arrayToHexString(config.build()));
  }

  List<DataTypeBase>? createSplits() {
    return null;
  }

  DataToken slice(int offset, int length) {
    if (offset < 0) {
      throw RangeError("offset must be >= 0");
    }
    if (offset + length > attributes.length()) {
      int len = attributes.length();
      throw RangeError("offset + length is greater than data length ($len)");
    }
    return _DataTypeBase.raw(eventConfig, offset, length);
  }
}
