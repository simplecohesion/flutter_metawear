import 'package:flutter_metawear/data.dart';
import 'package:flutter_metawear/subscriber.dart';
import 'package:flutter_metawear/impl/data_type_base.dart';
import 'package:flutter_metawear/impl/MetaWearBoardPrivate.dart';

abstract class DeviceDataConsumer {
  final DataTypeBase source;
  Subscriber? subscriber;
  List<Object>? environment;

  DeviceDataConsumer(this.source, [this.subscriber]);

  void call(Data msg) {
    if (subscriber != null && environment != null) {
      subscriber!.apply(msg, environment!);
    }
  }

  void enableStream(final MetaWearBoardPrivate mwPrivate);
  void disableStream(MetaWearBoardPrivate mwPrivate);
  void addDataHandler(final MetaWearBoardPrivate mwPrivate);
}
