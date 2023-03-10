import 'dart:async';

import 'package:flutter_metawear/Route.dart';
import 'package:flutter_metawear/builder/route_builder.dart';

/// A component that creates data, such as firmware features (battery level reporting) or sensors
abstract class DataProducer {
  /// Adds a route to direct where the data will go
  /// @param builder   Builder object to construct the route
  /// @return Task holding the created route if successful
  Future<Route> addRouteAsync(RouteBuilder builder);

  /// Unique name identifying the data for feedback loops
  /// @return Data name
  /// @see RouteComponent#filter(Comparison, ComparisonOutput, String...)
  /// @see RouteComponent#map(Function2, String...)
  String name();
}
