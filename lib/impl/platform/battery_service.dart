import 'package:flutter_metawear/impl/platform/btle_gatt_characteristic.dart';

import 'guid.dart';

/// Characteristics under the Battery GATT service
class BatteryService {
  /// Battery level characteristic
  static final BtleGattCharacteristic BATTERY_LEVEL =
      new BtleGattCharacteristic(
          serviceUuid: Guid("0000180f-0000-1000-8000-00805f9b34fb"),
          uuid: Guid("00002a19-0000-1000-8000-00805f9b34fb"));
}
