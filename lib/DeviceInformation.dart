import 'dart:core';

import 'package:sprintf/sprintf.dart';

/// Wrapper class holding Characteristics under the
/// <a href="https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.device_information.xml">Device Information</a>
/// GATT service

class DeviceInformation {
  /// Device's manufacturer name, characteristic 0x2A29
  final String manufacturer;

  /// Model number assigned by MbientLab, characteristic 0x2A24
  final String modelNumber;

  /// Device's serial number, characteristic 0x2A25
  final String serialNumber;

  /// Revision of the firmware on the device, characteristic 0x2A26
  final String firmwareRevision;

  /// Revision of the hardware on the device, characteristic 0x2A27
  final String hardwareRevision;

  DeviceInformation(
      {required this.manufacturer,
      required this.modelNumber,
      required this.serialNumber,
      required this.firmwareRevision,
      required this.hardwareRevision});

  @override
  String toString() => sprintf(
          "{manufacturer: %s, serialNumber: %s, firmwareRevision: %s, hardwareRevision: %s, modelNumber: %s}",
          [
            manufacturer,
            serialNumber,
            firmwareRevision,
            hardwareRevision,
            modelNumber
          ]);

  @override
  bool operator ==(other) =>
      other is DeviceInformation &&
      manufacturer == other.manufacturer &&
      modelNumber == other.modelNumber &&
      serialNumber == other.serialNumber &&
      firmwareRevision == other.firmwareRevision &&
      hardwareRevision == other.hardwareRevision;

  @override
  int get hashCode {
    int result = manufacturer.hashCode;
    result = 31 * result + modelNumber.hashCode;
    result = 31 * result + serialNumber.hashCode;
    result = 31 * result + firmwareRevision.hashCode;
    result = 31 * result + hardwareRevision.hashCode;
    return result;
  }
}
