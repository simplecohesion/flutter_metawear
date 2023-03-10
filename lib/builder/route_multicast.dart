import 'package:flutter_metawear/builder/route_component.dart';

/// Route element for enforcing that users call {@link #to()} immediately after declaring a multicast
abstract class RouteMulticast {
  /// Signals the creation of a new multicast branch
  /// @return RouteComponent from the most recent multicast component
  RouteComponent to();
}
