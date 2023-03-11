import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_metawear/active_data_producer.dart';
import 'package:flutter_metawear/route.dart';
import 'package:flutter_metawear/builder/route_builder.dart';
import 'package:flutter_metawear/impl/data_attributes.dart';
import 'package:flutter_metawear/impl/data_type_base.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/module_impl_base.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'package:flutter_metawear/impl/u_int_data.dart';
import 'package:flutter_metawear/impl/Util.dart';
import 'package:flutter_metawear/module/switch.dart';

import 'package:tuple/tuple.dart';

class _ActiveDataProducer extends ActiveDataProducer {
  final MetaWearBoardPrivate mwPrivate;

  _ActiveDataProducer(this.mwPrivate);

  @override
  Future<Route> addRouteAsync(RouteBuilder builder) =>
      mwPrivate.queueRouteBuilder(builder, SwitchImpl.PRODUCER);

  @override
  String name() => SwitchImpl.PRODUCER;
}

class SwitchImpl extends ModuleImplBase implements Switch {
  static const String PRODUCER =
      "com.mbientlab.metawear.impl.SwitchImpl.PRODUCER";
  static const int STATE = 0x1;

  static String? createUri(DataTypeBase dataType) {
    switch (Util.clearRead(dataType.eventConfig[1])) {
      case SwitchImpl.STATE:
        return "switch";
      default:
        return null;
    }
  }

  final StreamController<int> _streamController = StreamController<int>();

  ActiveDataProducer? _state;

  SwitchImpl(MetaWearBoardPrivate mwPrivate) : super(mwPrivate) {
    this.mwPrivate.tagProducer(
        PRODUCER,
        new UintData(ModuleType.SWITCH, STATE,
            new DataAttributes(Uint8List.fromList([1]), 1, 0, false)));
  }

  @override
  void init() {
    this.mwPrivate.addResponseHandler(
        Tuple2<int, int>(ModuleType.SWITCH.id, Util.setRead(STATE)),
        (Uint8List response) => _streamController.add(response[2]));
  }

  @override
  ActiveDataProducer state() {
    if (_state == null) {
      _state = _ActiveDataProducer(mwPrivate);
    }
    return _state!;
  }

  @override
  Future<int> readCurrentStateAsync() async {
    Stream<int> stream =
        _streamController.stream.timeout(ModuleType.RESPONSE_TIMEOUT);
    StreamIterator<int> iterator = StreamIterator(stream);
    mwPrivate.sendCommand(
        Uint8List.fromList([ModuleType.SWITCH.id, Util.setRead(STATE)]));
    TimeoutException exception = TimeoutException(
        "Did not received button state", ModuleType.RESPONSE_TIMEOUT);
    if (await iterator.moveNext().catchError((e) => throw exception,
            test: (e) => e is TimeoutException) ==
        false) throw exception;
    int current = iterator.current;
    await iterator.cancel();
    return current;
  }
}
