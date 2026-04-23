import 'dart:typed_data';

/// BLE 协议处理类，负责构建请求帧和解析响应帧
class BleProtocol {
  // 命令字定义
  static const int cmdMain = 0x01;      // 主界面数据
  static const int cmdSettings = 0x02;  // 设置界面数据
  static const int cmdHistory = 0x03;   // 历史界面数据
  
  // 子命令定义
  static const int subCmdRead = 0x00;   // 读取
  static const int subCmdWrite = 0x01;  // 写入
  
  // 引导码前缀（5字节，按顺序拼接）
  static const List<int> guideRequestPrefix = [0xAA, 0xAB, 0xAC, 0xAE, 0xAF];
  static const List<int> guideResponsePrefix = [0xBA, 0xBB, 0xBC, 0xBE, 0xBF];
  
  /// 构建主界面数据请求帧
  static List<int> buildMainDataRequest() {
    return _buildFrame(guideRequestPrefix, [cmdMain]);
  }
  
  /// 构建设置数据读取请求帧
  static List<int> buildSettingsReadRequest() {
    return _buildFrame(guideRequestPrefix, [cmdSettings, subCmdRead]);
  }
  
  /// 构建设置数据写入请求帧
  static List<int> buildSettingsWriteRequest(SettingsData settings) {
    final payload = [cmdSettings, subCmdWrite] + settings.toBytes();
    return _buildFrame(guideRequestPrefix, payload);
  }
  
  /// 构建历史数据请求帧
  static List<int> buildHistoryRequest() {
    return _buildFrame(guideRequestPrefix, [cmdHistory, subCmdRead]);
  }

  /// 构建历史数据清除请求帧（子命令=0x01）
  static List<int> buildHistoryClearRequest() {
    return _buildFrame(guideRequestPrefix, [cmdHistory, subCmdWrite]);
  }

  /// 构建负载开关控制帧（主界面通道下）
  /// on=true 发送打开负载；on=false 发送关闭负载
  static List<int> buildLoadSwitchControl(bool on) {
    final payload = [cmdMain, on ? 0x01 : 0x00];
    return _buildFrame(guideRequestPrefix, payload);
  }
  
  /// 解析主界面数据响应
  static MainInterfaceData? parseMainDataResponse(List<int> frame) {
    if (!_validateFrame(frame, guideResponsePrefix, cmdMain)) return null;
    
    final payload = _extractPayload(frame);
    // 主数据 33 字节：与草案一致
    if (payload.length < 33) return null;
    
    return MainInterfaceData.fromBytes(payload);
  }
  
  /// 解析设置数据响应
  static SettingsData? parseSettingsResponse(List<int> frame) {
    if (!_validateFrame(frame, guideResponsePrefix, cmdSettings)) return null;
    
    final payload = _extractPayload(frame);
    // 设置响应长度应为 20 字节（与协议 md 对齐：10项，总20B）
    if (payload.length < 20) return null;
    
    return SettingsData.fromBytes(payload);
  }
  
  /// 解析历史数据响应
  static HistoryData? parseHistoryResponse(List<int> frame) {
    if (!_validateFrame(frame, guideResponsePrefix, cmdHistory)) return null;
    
    final payload = _extractPayload(frame);
    if (payload.length < 33) return null;
    
    return HistoryData.fromBytes(payload);
  }

  /// 解析设置写入操作的ACK响应（完整帧校验）
  /// 返回状态码：0x00=OK，0x01=ERROR；若帧非法则返回 null。
  static int? parseSettingsAck(List<int> frame) {
    // 校验响应前缀、命令字、长度与CRC
    if (!_validateFrame(frame, guideResponsePrefix, cmdSettings)) return null;
    final payload = _extractPayload(frame);
    if (payload.isEmpty) return null;
    return payload[0];
  }
  
  /// 构建完整帧（引导码前缀(5B) + 长度(1B=整帧总长) + 负载(含命令字) + CRC16(2B)）
  static List<int> _buildFrame(List<int> guidePrefix, List<int> payload) {
    final frame = <int>[];
    frame.addAll(guidePrefix);
    // 长度字段 = 整帧总字节数（含引导码、长度字段本身、负载(含命令字)、CRC16 两字节）
    final totalLen = guidePrefix.length + 1 + payload.length + 2;
    frame.add(totalLen & 0xFF);
    frame.addAll(payload);

    // CRC16 计算范围与《BLE报文协议草案》一致：
    // 从引导码开始到负载数据末尾（不含 CRC 两字节），输出为小端（低字节在前）。
    final crc = _calculateCrc16(frame);
    frame.add(crc & 0xFF);        // CRC16 低字节
    frame.add((crc >> 8) & 0xFF); // CRC16 高字节

    return frame;
  }
  
  /// 验证帧格式
  static bool _validateFrame(List<int> frame, List<int> expectedGuidePrefix, int expectedCmd) {
    final prefixLen = expectedGuidePrefix.length;
    if (frame.length < prefixLen + 1 + 1 + 2) return false; // 至少包含前缀、长度、命令字、CRC
    for (int i = 0; i < prefixLen; i++) {
      if (frame[i] != expectedGuidePrefix[i]) return false;
    }
    if (frame[prefixLen + 1] != expectedCmd) return false; // 命令字位置

    final length = frame[prefixLen];
    // 新语义：长度字段=整帧总长度
    if (frame.length != length) return false;

    // 验证 CRC16（计算范围：引导码到负载末尾，不含 CRC 两字节；小端输出），与《BLE报文协议草案》一致
    final expectedCrc = _calculateCrc16(frame.sublist(0, frame.length - 2));
    final actualCrc = frame[frame.length - 2] | (frame[frame.length - 1] << 8);

    return expectedCrc == actualCrc;
  }
  
  /// 提取负载数据（去除引导码、长度、命令字、CRC16）
  static List<int> _extractPayload(List<int> frame) {
    // 前缀(5B) + 长度(1B) + 命令字(1B) + 负载 ... CRC(2B)
    final prefixLen = guideResponsePrefix.length; // 用响应前缀长度，和请求相同
    return frame.sublist(prefixLen + 2, frame.length - 2);
  }
  
  /// 计算 CRC16 (CRC-16/Modbus)
  /// 范围：调用方应传入“从引导码开始至负载末尾”的数据（不含 CRC 两字节）；输出小端（低字节在前）。
  static int _calculateCrc16(List<int> data) {
    int crc = 0xFFFF;
    
    for (int byte in data) {
      crc ^= byte;
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
  
  /// 将字节数组转换为十六进制字符串（用于调试）
  static String toHexString(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }
}

/// 主界面数据结构（草案定义的33字节负载）
class MainInterfaceData {
  final double solarPowerW;               // 太阳能功率 (uint32, W)
  final double solarVoltageV;             // 太阳能电压 (uint16, V)
  final double solarCurrentA;             // 太阳能电流 (uint16, A)
  final double todaysSolarEnergyWh;       // 当日太阳能发电量 (uint32, Wh)
  final double batteryVoltageV;           // 电池电压 (uint16, V)
  final double batteryCurrentA;           // 电池电流 (uint16, A)
  final double batteryTemperatureC;       // 电池温度 (uint16)
  final double todaysBatteryChargeAh;     // 当日电池充电电量 (uint32, Ah)
  final bool loadSwitchOn;                // 负载开关 (uint8)
  final double loadCurrentA;              // 负载电流 (uint16, A)
  final double loadPowerW;                // 负载功率 (uint32, W)
  final double todaysOutputEnergyWh;      // 当日输出电量 (uint32, Wh)

  const MainInterfaceData({
    required this.solarPowerW,
    required this.solarVoltageV,
    required this.solarCurrentA,
    required this.todaysSolarEnergyWh,
    required this.batteryVoltageV,
    required this.batteryCurrentA,
    required this.batteryTemperatureC,
    required this.todaysBatteryChargeAh,
    required this.loadSwitchOn,
    required this.loadCurrentA,
    required this.loadPowerW,
    required this.todaysOutputEnergyWh,
  });

  factory MainInterfaceData.fromBytes(List<int> bytes) {
    final data = Uint8List.fromList(bytes);
    final view = ByteData.sublistView(data);

    return MainInterfaceData(
      solarPowerW: view.getUint32(0, Endian.little) / 10.0,
      solarVoltageV: view.getUint16(4, Endian.little) / 10.0,
      solarCurrentA: view.getUint16(6, Endian.little) / 10.0,
      todaysSolarEnergyWh: view.getUint32(8, Endian.little) / 10.0,
      batteryVoltageV: view.getUint16(12, Endian.little) / 10.0,
      batteryCurrentA: view.getUint16(14, Endian.little) / 10.0,
      batteryTemperatureC: (() {
        final raw = view.getUint16(16, Endian.little);
        final neg = (raw & 0x8000) != 0;
        final mag = (raw & 0x7FFF).toDouble() / 10.0;
        return neg ? -mag : mag;
      })(),
      todaysBatteryChargeAh: view.getUint32(18, Endian.little) / 10.0,
      loadSwitchOn: view.getUint8(22) != 0,
      loadCurrentA: view.getUint16(23, Endian.little) / 10.0,
      loadPowerW: view.getUint32(25, Endian.little) / 10.0,
      todaysOutputEnergyWh: view.getUint32(29, Endian.little) / 10.0,
    );
  }
}

/// 设置数据结构（与协议 md 对齐：10项，20B）
class SettingsData {
  final int modeSelection;            // 模式选择：0=AUTO, 1=12V, 2=24V, 3=48V, 4=96V
  final int batteryType;              // 电池类型：SLD/GLE/FLD/LifeP04/USE/USE LI
  final double equalizingChargeV;     // 均衡充电电压 (V)
  final double boostChargeV;          // 提升充电电压 (V)
  final double floatChargeV;          // 浮充充电电压 (V)
  final double chargeReturnV;         // 充电返回电压 (V)
  final double overDischargeReturnV;  // 过放返回电压 (V)
  final double overDischargeV;        // 过放电压 (V)
  final int loadMode;                 // 负载模式：0、1~14、15、17
  final int systemVersion;            // 系统版本号 (uint32)
  final int reserved;                 // 保留字段（为保持总18字节，置于末尾）

  const SettingsData({
    required this.modeSelection,
    required this.batteryType,
    required this.equalizingChargeV,
    required this.boostChargeV,
    required this.floatChargeV,
    required this.chargeReturnV,
    required this.overDischargeReturnV,
    required this.overDischargeV,
    required this.loadMode,
    required this.systemVersion,
    required this.reserved,
  });

  factory SettingsData.fromBytes(List<int> bytes) {
    final data = Uint8List.fromList(bytes);
    final view = ByteData.sublistView(data);

    return SettingsData(
      modeSelection: view.getUint8(0),
      batteryType: view.getUint8(1),
      equalizingChargeV: view.getUint16(2, Endian.little) / 10.0,
      boostChargeV: view.getUint16(4, Endian.little) / 10.0,
      floatChargeV: view.getUint16(6, Endian.little) / 10.0,
      chargeReturnV: view.getUint16(8, Endian.little) / 10.0,
      overDischargeReturnV: view.getUint16(10, Endian.little) / 10.0,
      overDischargeV: view.getUint16(12, Endian.little) / 10.0,
      loadMode: view.getUint8(14),
      systemVersion: view.getUint32(15, Endian.little),
      reserved: view.getUint8(19),
    );
  }

  List<int> toBytes() {
    final data = ByteData(20);
    data.setUint8(0, modeSelection);
    data.setUint8(1, batteryType);
    data.setUint16(2, (equalizingChargeV * 10).round(), Endian.little);
    data.setUint16(4, (boostChargeV * 10).round(), Endian.little);
    data.setUint16(6, (floatChargeV * 10).round(), Endian.little);
    data.setUint16(8, (chargeReturnV * 10).round(), Endian.little);
    data.setUint16(10, (overDischargeReturnV * 10).round(), Endian.little);
    data.setUint16(12, (overDischargeV * 10).round(), Endian.little);
    data.setUint8(14, loadMode);
    data.setUint32(15, systemVersion, Endian.little);
    data.setUint8(19, reserved);

    return data.buffer.asUint8List();
  }
}

/// 历史数据结构（草案定义的33字节负载）
class HistoryData {
  final int dayOffset;                  // 天数偏移 (uint8)
  final double solarEnergyWh;           // 太阳能发电量 (scaled Wh)
  final double solarMaxPowerW;          // 太阳能最大功率 (scaled W)
  final double solarMaxVoltageV;        // 太阳能最大电压 (scaled V)
  final double batteryMaxVoltageV;      // 电池最大电压 (scaled V)
  final double batteryMinVoltageV;      // 电池最小电压 (scaled V)
  final double loadConsumptionWh;       // 负载消耗电量 (scaled Wh)
  final double batteryChargeWh;         // 电池充电量 (scaled Wh)
  final int errorCount;                 // 错误提示次数 (uint16)
  final double totalGenerationWh;       // 总发电量 (scaled Wh)

  const HistoryData({
    required this.dayOffset,
    required this.solarEnergyWh,
    required this.solarMaxPowerW,
    required this.solarMaxVoltageV,
    required this.batteryMaxVoltageV,
    required this.batteryMinVoltageV,
    required this.loadConsumptionWh,
    required this.batteryChargeWh,
    required this.errorCount,
    required this.totalGenerationWh,
  });

  factory HistoryData.fromBytes(List<int> bytes) {
    final data = Uint8List.fromList(bytes);
    final view = ByteData.sublistView(data);

    return HistoryData(
      dayOffset: view.getUint8(0),
      solarEnergyWh: view.getUint32(1, Endian.little) / 10.0,
      solarMaxPowerW: view.getUint32(5, Endian.little) / 10.0,
      solarMaxVoltageV: view.getUint16(9, Endian.little) / 10.0,
      batteryMaxVoltageV: view.getUint16(11, Endian.little) / 10.0,
      batteryMinVoltageV: view.getUint16(13, Endian.little) / 10.0,
      loadConsumptionWh: view.getUint32(15, Endian.little) / 10.0,
      batteryChargeWh: view.getUint32(19, Endian.little) / 10.0,
      errorCount: view.getUint16(23, Endian.little),
      totalGenerationWh: view.getUint64(25, Endian.little) / 10.0,
    );
  }
}