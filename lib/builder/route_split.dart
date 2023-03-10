import 'package:flutter_metawear/builder/route_component.dart';

/// RouteComponent for enforcing that users call {@link #index(int)} immediately after splitting data
abstract class RouteSplit {
  /// Gets a specific component value from the split data value
  /// @param i    Position in the split values array to return
  /// @return Object representing the component value
  RouteComponent index(int i);
}
