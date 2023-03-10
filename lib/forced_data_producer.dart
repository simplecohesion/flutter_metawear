import 'package:flutter_metawear/data_producer.dart';

/// A data producer that only emits data when a {@link #read()} command is issued.  Using the {@link Timer} module,
/// a periodic read can be programmed onto the board to avoid having to repeatedly send the command from the local device.
abstract class ForcedDataProducer implements DataProducer {
  /// Sends a read command to the producer
  void read();
}
