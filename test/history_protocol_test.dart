import 'package:flutter_test/flutter_test.dart';
import 'package:bluetooth_data_presenting/ble_protocol.dart';

/// CRC-16/Modbus (poly=0xA001, init=0xFFFF), little-endian output
int _crc16Modbus(List<int> data) {
  int crc = 0xFFFF;
  for (final b in data) {
    crc ^= b;
    for (int i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xA001;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc & 0xFFFF;
}

void main() {
  test('History frame parsing matches spec offsets and CRC', () {
    // Response guide prefix
    const guides = [0xBA, 0xBB, 0xBC, 0xBE, 0xBF];
    const cmdHistory = 0x03;

    // Payload values (raw encoded, little-endian fields)
    const dayOffset = 7; // uint8
    const solarEnergyWh = 12345; // uint32
    const solarMaxPowerW = 500; // uint32
    const solarMaxVoltageVx10 = 570; // 57.0V -> uint16 value*10
    const batteryMaxVoltageVx10 = 560; // 56.0V -> uint16 value*10
    const batteryMinVoltageVx10 = 510; // 51.0V -> uint16 value*10
    const loadConsumptionWh = 3456; // uint32
    const batteryChargeWhx10 = 7890; // 789.0Wh -> uint32 value*10
    const errorCount = 2; // uint16
    const totalGenerationWhx10 = 1000000; // 100000.0Wh -> uint64 value*10

    // Build payload (33 bytes) following spec
    final payload = <int>[];
    payload.add(dayOffset);
    payload.addAll(_u32le(solarEnergyWh));
    payload.addAll(_u32le(solarMaxPowerW));
    payload.addAll(_u16le(solarMaxVoltageVx10));
    payload.addAll(_u16le(batteryMaxVoltageVx10));
    payload.addAll(_u16le(batteryMinVoltageVx10));
    payload.addAll(_u32le(loadConsumptionWh));
    payload.addAll(_u32le(batteryChargeWhx10));
    payload.addAll(_u16le(errorCount));
    payload.addAll(_u64le(totalGenerationWhx10));

    expect(payload.length, 33);

    // Assemble full frame: guides + len + [cmd + payload] + crc
    final payloadWithCmd = <int>[cmdHistory, ...payload];
    final totalLen = guides.length + 1 + payloadWithCmd.length + 2;
    final frameNoCrc = <int>[...guides, totalLen & 0xFF, ...payloadWithCmd];
    final crc = _crc16Modbus(frameNoCrc);
    final frame = <int>[...frameNoCrc, crc & 0xFF, (crc >> 8) & 0xFF];

    // Sanity: len byte equals full frame length
    expect(frame.length, totalLen);
    expect(frame[guides.length], totalLen & 0xFF);

    // Parse via BleProtocol
    final parsed = BleProtocol.parseHistoryResponse(frame);
    expect(parsed, isNotNull);
    final h = parsed!;

    // Field assertions (raw parsed integers)
    expect(h.dayOffset, dayOffset);
    expect(h.solarEnergyWh, solarEnergyWh);
    expect(h.solarMaxPowerW, solarMaxPowerW);
    expect(h.solarMaxVoltageV, solarMaxVoltageVx10);
    expect(h.batteryMaxVoltageV, batteryMaxVoltageVx10);
    expect(h.batteryMinVoltageV, batteryMinVoltageVx10);
    expect(h.loadConsumptionWh, loadConsumptionWh);
    expect(h.batteryChargeWh, batteryChargeWhx10);
    expect(h.errorCount, errorCount);
    expect(h.totalGenerationWh, totalGenerationWhx10);
  });
}

List<int> _u16le(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _u32le(int v) => [
      v & 0xFF,
      (v >> 8) & 0xFF,
      (v >> 16) & 0xFF,
      (v >> 24) & 0xFF,
    ];
List<int> _u64le(int v) {
  final hi = 0; // using 32-bit value for simplicity in test
  return [
    v & 0xFF,
    (v >> 8) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 24) & 0xFF,
    hi & 0xFF,
    (hi >> 8) & 0xFF,
    (hi >> 16) & 0xFF,
    (hi >> 24) & 0xFF,
  ];
}