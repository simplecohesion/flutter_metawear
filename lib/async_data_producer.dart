import 'package:flutter_metawear/data_producer.dart';

/// Data producer that emits data when new data is available.  Call {@link #start()} to begin gathering data
/// and {@link #stop()} to terminate the data measuring.
abstract class AsyncDataProducer implements DataProducer {
  /// Starts data creation
  void start();

  /// Stops data creation
  void stop();
}
