import 'package:flutter_metawear/builder/route_component.dart';

/// Builder class for creating a data route

abstract class RouteBuilder {
  /// Called by the API with the RouteComponent corresponding to the entry point of the data route
  /// @param source    Entry point for the route
  void configure(RouteComponent source);
}
