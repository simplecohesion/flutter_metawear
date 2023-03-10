import 'package:flutter_metawear/impl/platform/btle_gatt_characteristic.dart';

import 'guid.dart';

/// Manufacturer and/or vendor information about a device

class DeviceInformationService {
  static final Guid _SERVICE_UUID =
      Guid("0000180a-0000-1000-8000-00805f9b34fb");

  /// Revision for the firmware within the device
  static final BtleGattCharacteristic FIRMWARE_REVISION =
      new BtleGattCharacteristic(
          serviceUuid: _SERVICE_UUID,
          uuid: Guid("00002a26-0000-1000-8000-00805f9b34fb"));

  /// Model number that is assigned by the device
  static final BtleGattCharacteristic MODEL_NUMBER = new BtleGattCharacteristic(
      serviceUuid: _SERVICE_UUID,
      uuid: Guid("00002a24-0000-1000-8000-00805f9b34fb"));

  /// Revision for the hardware within the device
  static final BtleGattCharacteristic HARDWARE_REVISION =
      new BtleGattCharacteristic(
          serviceUuid: _SERVICE_UUID,
          uuid: Guid("00002a27-0000-1000-8000-00805f9b34fb"));

  /// Name of the manufacturer of the device
  static final BtleGattCharacteristic MANUFACTURER_NAME =
      new BtleGattCharacteristic(
          serviceUuid: _SERVICE_UUID,
          uuid: Guid("00002a29-0000-1000-8000-00805f9b34fb"));

  /// Serial number for a particular instance of the device
  static final BtleGattCharacteristic SERIAL_NUMBER =
      new BtleGattCharacteristic(
          serviceUuid: _SERVICE_UUID,
          uuid: Guid("00002a25-0000-1000-8000-00805f9b34fb"));
}
