/*
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights granted under the terms of a software
 * license agreement between the user who downloaded the software, his/her employer (which must be your
 * employer) and MbientLab Inc, (the "License").  You may not use this Software unless you agree to abide by the
 * terms of the License which can be found at www.mbientlab.com/terms.  The License limits your use, and you
 * acknowledge, that the Software may be modified, copied, and distributed when used in conjunction with an
 * MbientLab Inc, product.  Other than for the foregoing purpose, you may not use, reproduce, copy, prepare
 * derivative works of, modify, distribute, perform, display or sell this Software and/or its documentation for any
 * purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE PROVIDED "AS IS" WITHOUT WARRANTY
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL MBIENTLAB OR ITS LICENSORS BE LIABLE OR
 * OBLIGATED UNDER CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT,
 * PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software, contact MbientLab via email:
 * hello@mbientlab.com.
 */

import 'dart:typed_data';

import 'package:flutter_metawear/active_data_producer.dart';
import 'package:flutter_metawear/code_block.dart';
import 'package:flutter_metawear/config_editor_base.dart';
import 'package:flutter_metawear/forced_data_producer.dart';
import 'package:flutter_metawear/meta_wear_board.dart';
import 'package:flutter_metawear/observer.dart';
import 'package:flutter_metawear/impl/Util.dart';

import 'package:collection/collection.dart';
import 'package:sprintf/sprintf.dart';

/// Bluetooth LE advertising configuration

class BleAdvertisementConfig {
  /// Name the device advertises as
  final String deviceName;

  /// Time between each advertise event, in milliseconds (ms)
  final int interval;

  /// How long the device should advertise for with 0 indicating no timeout, in seconds (s)
  final int timeout;

  /// BLE radio's transmitting strength
  final int txPower;

  /// Scan response
  final Uint8List scanResponse;

  factory BleAdvertisementConfig.empty() {
    return BleAdvertisementConfig("", 0, 0, 0, Uint8List(0));
  }

  BleAdvertisementConfig(this.deviceName, this.interval, this.timeout,
      this.txPower, this.scanResponse);

  @override
  bool operator ==(other) {
    if (this == other) return true;

    Function eq = const ListEquality().equals;
    return other is BleAdvertisementConfig &&
        interval == other.interval &&
        timeout == other.timeout &&
        txPower == other.txPower &&
        deviceName == other.deviceName &&
        eq(scanResponse, other.scanResponse);
  }

  @override
  int get hashCode {
    int result = deviceName.hashCode;
    result = 31 * result + interval;
    result = 31 * result + timeout;
    result = 31 * result + txPower;
    result = 31 * result + scanResponse.hashCode;
    return result;
  }

  @override
  String toString() {
    return sprintf(
        "{Device Name: %s, Adv Interval: %d, Adv Timeout: %d, Tx Power: %d, Scan Response: %s}",
        [
          deviceName,
          interval,
          timeout,
          txPower,
          Util.arrayToHexString(scanResponse)
        ]);
  }
}

/// Interface for modifying the Bluetooth LE advertising configuration

abstract class BleAdvertisementConfigEditor extends ConfigEditorBase {
  /// Set the device's advertising name
  /// @param name    Device name, max of 8 ASCII characters
  /// @return Calling object
  BleAdvertisementConfigEditor deviceName(String name);

  /// Set the advertising interval
  /// @param interval    Time between advertise events
  /// @return Calling object
  BleAdvertisementConfigEditor interval(int interval);

  /// Set how long to advertise for
  /// @param timeout     How long to advertise for, between [0, 180] seconds where 0 indicates no timeout
  /// @return Calling object
  BleAdvertisementConfigEditor timeout(int timeout);

  /// Sets advertising transmitting power.  If a non valid value is set, the nearest valid value will be used instead
  /// @param power    Valid values are: 4, 0, -4, -8, -12, -16, -20, -30
  /// @return Calling object
  BleAdvertisementConfigEditor txPower(int power);

  /// Set a custom scan response packet
  /// @param response    Byte representation of the response
  /// @return Calling object
  BleAdvertisementConfigEditor scanResponse(Uint8List response);
}

/// Wrapper class containing the connection parameters

class BleConnectionParameters {
  /// Minimum time the central device asks for data from the peripheral, in milliseconds (ms)
  final double minConnectionInterval;

  /// Maximum time the central device asks for data from the peripheral, in milliseconds (ms
  final double maxConnectionInterval;

  /// How many times the peripheral can choose to discard data requests from the central device
  final int slaveLatency;

  /// Timeout from the last data exchange until the ble link is considered lost
  final int supervisorTimeout;

  BleConnectionParameters(this.minConnectionInterval,
      this.maxConnectionInterval, this.slaveLatency, this.supervisorTimeout);

  @override
  bool operator ==(other) {
    if (this == other) return true;
    if (other == null || this is! BleConnectionParameters) return false;

    BleConnectionParameters that = other as BleConnectionParameters;

    return that.minConnectionInterval == minConnectionInterval &&
        that.maxConnectionInterval == maxConnectionInterval &&
        slaveLatency == that.slaveLatency &&
        supervisorTimeout == that.supervisorTimeout;
  }

  @override
  int get hashCode {
    int result = minConnectionInterval.round();
    result = 31 * result + maxConnectionInterval.round();
    result = 31 * result + slaveLatency;
    result = 31 * result + supervisorTimeout;
    return result;
  }

  @override
  String toString() {
    return sprintf(
        "{min conn interval: %.2f, max conn interval: %.2f, slave latency: %d, supervisor timeout: %d}",
        [
          minConnectionInterval,
          maxConnectionInterval,
          slaveLatency,
          supervisorTimeout
        ]);
  }
}

/// Interface for editing the Bluetooth LE connection parameters

abstract class BleConnectionParametersEditor extends ConfigEditorBase {
  /// Sets the lower bound of the connection interval
  /// @param interval    Lower bound, at least 7.5ms
  /// @return Calling object
  BleConnectionParametersEditor minConnectionInterval(double interval);

  /// Sets the upper bound of the connection interval
  /// @param interval    Upper bound, at most 4000ms
  /// @return Calling object
  BleConnectionParametersEditor maxConnectionInterval(double interval);

  /// Sets the number of connection intervals to skip
  /// @param latency    Number of connection intervals to skip, between [0, 1000]
  /// @return Calling object
  BleConnectionParametersEditor slaveLatency(int latency);

  /// Sets the maximum amount of time between data exchanges until the connection is considered to be lost
  /// @param timeout    Timeout value between [10, 32000] ms
  /// @return Calling object
  BleConnectionParametersEditor supervisorTimeout(int timeout);
}

/// Wrapper class encapsulating the battery state data

class BatteryState {
  /// Percent charged, between [0, 100]
  final int charge;

  /// Battery voltage level in V
  final double voltage;

  BatteryState(this.charge, this.voltage);

  @override
  String toString() {
    return sprintf("{charge: %d%%, voltage: %.3fV}", [charge, voltage]);
  }

  @override
  bool equals(Object o) {
    if (this == o) return true;
    if (o == null || this is! BatteryState) return false;

    BatteryState that = o as BatteryState;

    return charge == that.charge && that.voltage == voltage;
  }

  @override
  int get hashCode {
    int result = charge.round();
    result = 31 * result + voltage.round();
    return result;
  }
}

/// Produces battery data that can be used with the firmware features

abstract class BatteryDataProducer extends ForcedDataProducer {
  /// Get the name for battery charge data
  /// @return Battery charge data name
  String chargeName();

  /// Get the name for battery voltage data
  /// @return Battery voltage data name
  String voltageName();
}

/// Configures Bluetooth settings and auxiliary hardware and firmware features

abstract class Settings implements Module {
  /// Starts ble advertising
  void startBleAdvertising();

  /// Edit the ble advertising configuration
  /// @return Editor object to modify the settings
  BleAdvertisementConfigEditor editBleAdConfig();

  /// Read the current ble advertising configuration
  /// @return Task that is completed once the advertising config has been received
  Future<BleAdvertisementConfig> readBleAdConfigAsync();

  /// Edit the ble connection parameters
  /// @return Editor object to modify the connection parameters
  BleConnectionParametersEditor editBleConnParams();

  /// Read the current ble connection parameters
  /// @return Task that is completed once the connection parameters have been received
  Future<BleConnectionParameters> readBleConnParamsAsync();

  /// Gets an object to use the battery data
  /// @return Object representing battery data, null if battery data is not supported
  BatteryDataProducer battery();

  /// Gets an object to control power status notifications
  /// @return Object representing power status notifications, null if power status not supported
  ActiveDataProducer powerStatus();

  /// Reads the current power status if available
  /// @return Task holding the power status; 1 if power source is attached, 0 otherwise
  Future<int> readCurrentPowerStatusAsync();

  /// Gets an object to control charging status notifications
  /// @return Object representing charging status notifications, null if charging status not supported
  ActiveDataProducer chargeStatus();

  /// Reads the current charge status
  /// @return Task holding the charge status; 1 if battery is charging, 0 otherwise
  Future<int> readCurrentChargeStatusAsync();

  /// Programs a task that will be execute on-board when a disconnect occurs
  /// @param codeBlock    MetaWear commands composing the task
  /// @return Task holding the result of the program request
  Future<Observer> onDisconnectAsync(CodeBlock codeBlock);
}
