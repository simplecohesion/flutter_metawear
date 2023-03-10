import 'dart:typed_data';

import 'package:flutter_metawear/impl/platform/btle_gatt_characteristic.dart';

import 'guid.dart';

/// Listener for GATT characteristic notifications

abstract class NotificationListener {
  /// Called when the GATT characteristic's value changes
  /// @param value    New value for the characteristic
  void onChange(Uint8List value);
}

/// Handler for disconnect events

abstract class DisconnectHandler {
  /// Called when the connection with the BLE device has been closed
  void onDisconnect();

  /// Similar to {@link #onDisconnect()} except this variant handles instances where the connection
  /// was unexpectedly dropped i.e. not initiated by the API
  /// @param status    Status code reported by the btle stack
  void onUnexpectedDisconnect(int status);
}

/// Write types for the GATT characteristic

enum WriteType { WITHOUT_RESPONSE, DEFAULT }

/// Bluetooth GATT operations used by the API, must be implemented by the target platform

/// @version 2.0
abstract class BtleGatt {
  /// Register a handler for disconnect events
  /// @param handler    Handler to respond to the dc events
  void onDisconnect(DisconnectHandler handler);

  /// Checks if a service exists
  /// @param gattService    UUID identifying the service to lookup
  /// @return True if service exists, false if not
  bool serviceExists(Guid gattService);

  /// Writes a GATT characteristic and its value to the remote device
  /// @param characteristic    GATT characteristic to write
  /// @param type              Type of GATT write to use
  /// @param value             Value to be written
  /// @return Task holding the result of the operation
  Future<void> writeCharacteristicAsync(
      BtleGattCharacteristic characteristic, WriteType type, Uint8List value);

  /// Convenience method to do bulk characteristic reads
  /// @param characteristics    Array of characteristics to read
  /// @return Task which holds the characteristic values in order if all reads are successful
  Future<List<Uint8List>> readCharacteristicAsync(
      List<BtleGattCharacteristic> characteristics);
//    /**
//     * Reads the requested characteristic's value
//     * @param characteristic    Characteristic to read
//     * @return Task holding the characteristic's value if successful
//     */
//    Future<Uint8List> readCharacteristicAsync(BtleGattCharacteristic characteristic);

  /// Enable notifications for the characteristic
  /// @param characteristic    Characteristic to enable notifications for
  /// @param listener          Listener for handling characteristic notifications
  /// @return Task holding the result of the operation
  Future<void> enableNotificationsAsync(
      BtleGattCharacteristic characteristic, NotificationListener listener);

  /// A disconnect attempted initiated by the Android device
  /// @return Task holding the result of the disconnect attempt
  Future<void> localDisconnectAsync();

  /// A disconnect attempt that will be initiated by the remote device
  /// @return Task holding the result of the disconnect attempt
  Future<void> remoteDisconnectAsync();

  /// Connects to the GATT server on the remote device
  /// @return Task holding the result of the connect attempt
  Future<void> connectAsync();

  /// Read the remote device's RSSI value
  /// @return Task holding the RSSI value, if successful
  Future<int> readRssiAsync();
}
