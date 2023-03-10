import 'package:flutter_metawear/async_data_producer.dart';
import 'package:flutter_metawear/route.dart';
import 'package:flutter_metawear/builder/route_builder.dart';
import 'package:flutter_metawear/impl/module_impl_base.dart';
import 'package:flutter_metawear/impl/ModuleType.dart';
import 'package:flutter_metawear/module/AmbientLightLtr329.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';
import 'package:flutter_metawear/impl/DataTypeBase.dart';
import 'package:flutter_metawear/impl/MilliUnitsUFloatData.dart';
import 'package:flutter_metawear/impl/DataAttributes.dart';
import 'dart:typed_data';

class _configEditor extends ConfigEditor {
  Gain ltr329Gain = Gain.LTR329_1X;
  IntegrationTime ltr329Time = IntegrationTime.LTR329_TIME_100MS;
  MeasurementRate ltr329Rate = MeasurementRate.LTR329_RATE_500MS;
  final MetaWearBoardPrivate mwPrivate;

  _configEditor(this.mwPrivate);

  @override
  ConfigEditor gain(Gain sensorGain) {
    ltr329Gain = sensorGain;
    return this;
  }

  @override
  ConfigEditor integrationTime(IntegrationTime time) {
    ltr329Time = time;
    return this;
  }

  @override
  ConfigEditor measurementRate(MeasurementRate rate) {
    ltr329Rate = rate;
    return this;
  }

  @override
  void commit() {
    int alsContr = (ltr329Gain.bitmask << 2);
    int alsMeasRate = ((ltr329Time.bitmask << 3) | ltr329Rate.index);

    mwPrivate.sendCommand(Uint8List.fromList([
      ModuleType.AMBIENT_LIGHT.id,
      AmbientLightLtr329Impl.CONFIG,
      alsContr,
      alsMeasRate
    ]));
  }
}

class _AsyncDataProducer extends AsyncDataProducer {
  final MetaWearBoardPrivate mwPrivate;

  _AsyncDataProducer(this.mwPrivate);

  @override
  Future<Route> addRouteAsync(RouteBuilder builder) {
    return mwPrivate.queueRouteBuilder(
        builder, AmbientLightLtr329Impl.ILLUMINANCE_PRODUCER);
  }

  @override
  String name() {
    return AmbientLightLtr329Impl.ILLUMINANCE_PRODUCER;
  }

  @override
  void start() {
    mwPrivate.sendCommand(Uint8List.fromList(
        [ModuleType.AMBIENT_LIGHT.id, AmbientLightLtr329Impl.ENABLE, 0x1]));
  }

  @override
  void stop() {
    mwPrivate.sendCommand(Uint8List.fromList(
        [ModuleType.AMBIENT_LIGHT.id, AmbientLightLtr329Impl.ENABLE, 0x0]));
  }
}

/**
 * Created by etsai on 9/20/16.
 */
class AmbientLightLtr329Impl extends ModuleImplBase
    implements AmbientLightLtr329 {
  static String createUri(DataTypeBase dataType) {
    switch (dataType.eventConfig[1]) {
      case OUTPUT:
        return "illuminance";
      default:
        return null;
    }
  }

  static const String ILLUMINANCE_PRODUCER =
      "com.mbientlab.metawear.impl.AmbientLightLtr329Impl.ILLUMINANCE_PRODUCER";
  static const int ENABLE = 1, CONFIG = 2, OUTPUT = 3;

  AsyncDataProducer illuminanceProducer;

  AmbientLightLtr329Impl(MetaWearBoardPrivate mwPrivate) : super(mwPrivate) {
    mwPrivate.tagProducer(
        ILLUMINANCE_PRODUCER,
        new MilliUnitsUFloatData(ModuleType.AMBIENT_LIGHT, OUTPUT,
            new DataAttributes(Uint8List.fromList([4]), 1, 0, false)));
  }

  @override
  ConfigEditor configure() {
    return _configEditor(mwPrivate);
  }

  @override
  AsyncDataProducer illuminance() {
    if (illuminanceProducer == null) {
      illuminanceProducer = _AsyncDataProducer(mwPrivate);
    }
    return illuminanceProducer;
  }
}
