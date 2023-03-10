import 'guid.dart';

/// Bluetooth GATT characteristic

class BtleGattCharacteristic {
  /// UUID identifying the service the characteristic belongs to
  final Guid serviceUuid;

  /// UUID identifying the characteristic
  final Guid uuid;

  BtleGattCharacteristic({required this.serviceUuid, required this.uuid});

  @override
  int get hashCode => serviceUuid.hashCode * 31 + uuid.hashCode;

  @override
  bool operator ==(o) {
    if (this == o) return true;
    if (runtimeType != o.runtimeType) return false;

    BtleGattCharacteristic that = o as BtleGattCharacteristic;

    return serviceUuid == that.serviceUuid && uuid == that.uuid;
  }
//
//
//
//    @override
//    public boolean equals(Object o) {
//        if (this == o) return true;
//        if (o == null || getClass() != o.getClass()) return false;
//
//        BtleGattCharacteristic that = (BtleGattCharacteristic) o;
//
//        return serviceUuid.equals(that.serviceUuid) && uuid.equals(that.uuid);
//
//    }
//
//    @override
//    public int hashCode() {
//        int result = serviceUuid.hashCode();
//        result = 31 * result + uuid.hashCode();
//        return result;
//    }
}
