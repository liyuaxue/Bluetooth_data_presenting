import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ble_protocol.dart';

/// 蓝牙连接状态
enum BluetoothConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// 蓝牙服务管理类
// 页面上下文：用于标记请求来源页面，以便页面切换后忽略响应
enum UiPageContext { realtime, history, settings }

class BluetoothService extends ChangeNotifier {
  static bool get _bleSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
  BluetoothService() {
    // 捕获 FlutterBluePlus 的内部日志，便于定位通知与写入的底层行为
    if (_bleSupportedPlatform) {
      try {
        fbp.FlutterBluePlus.setLogLevel(fbp.LogLevel.verbose, color: false);
        fbp.FlutterBluePlus.logs.listen((String s) {
          _addLog("[FBP] ${s}");
        });
      } catch (e) {
        _addLog("设置FlutterBluePlus日志级别失败: ${e}");
      }
    } else {
      _addLog("当前平台不支持 BLE（FlutterBluePlus），已跳过插件初始化");
    }
  }
  static const String serviceUuid = "0000FFF0-0000-1000-8000-00805F9B34FB";
  static const String writeCharacteristicUuid =
      "0000FFF2-0000-1000-8000-00805F9B34FB";
  static const String notifyCharacteristicUuid =
      "0000FFF1-0000-1000-8000-00805F9B34FB";
  // 目标广播名称列表（用于扫描与连接过滤）
  // 目标广播名称模式：SY_ + 任意字符串 + AMPPT（不区分大小写）
  // 示例：SY_60AMPPT、SY_80AMPPT、SY_XYZ_AMPPT 等
  // 目标设备名称模式：SY_ + 任意字符串 + AMPPT（不区分大小写）
  static final RegExp targetAdvNameRegex = RegExp(
    r'^sy_.+amppt$',
    caseSensitive: false,
  );
  // static final RegExp targetAdvNameRegex = RegExp(r'^.+$', caseSensitive: false);
  static bool _matchesTargetAdvName(String? name) {
    final s = name?.trim();
    if (s == null || s.isEmpty) return false;
    return targetAdvNameRegex.hasMatch(s);
  }

  // Persistence keys for last connected device
  static const String _prefsKeyLastRemoteId = 'last_remote_id';
  static const String _prefsKeyLastDeviceName = 'last_device_name';
  static const String _prefsKeyDeviceAliases = 'device_aliases';

  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _writeCharacteristic;
  fbp.BluetoothCharacteristic? _notifyCharacteristic;

  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  String _statusMessage = "未连接";
  List<String> _logs = [];
  // 设备别名映射：remoteId -> alias
  Map<String, String> _deviceAliases = {};
  Map<String, String> get deviceAliases => Map.unmodifiable(_deviceAliases);
  // 当前正在尝试连接的设备ID（用于在UI中标记“连接中”的设备）
  String? _connectingRemoteId;
  String? get connectingRemoteId => _connectingRemoteId;

  // 发现的设备列表（用于设备选择 UI）
  final List<fbp.ScanResult> _discoveredDevices = [];
  List<fbp.ScanResult> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);

  StreamSubscription<List<int>>? _notificationSubscription;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  StreamSubscription<fbp.BluetoothConnectionState>? _deviceStateSubscription;
  bool _manualDisconnecting = false;
  bool _unexpectedDisconnected = false;
  bool get unexpectedDisconnected => _unexpectedDisconnected;

  // Getters
  BluetoothConnectionState get connectionState => _connectionState;
  String get statusMessage => _statusMessage;
  List<String> get logs => List.unmodifiable(_logs);
  bool get isConnected =>
      _connectionState == BluetoothConnectionState.connected;
  bool _filterEnabled = true;
  bool get filterEnabled => _filterEnabled;
  void setFilterEnabled(bool enabled) {
    _filterEnabled = enabled;
    _addLog("过滤开关: ${enabled ? '开启' : '关闭'}");
    notifyListeners();
  }

  // 根据别名解析显示名称：若存在别名则用别名，否则用传入的回退名称
  String resolveAlias(String remoteId, String fallbackName) {
    final a = _deviceAliases[remoteId];
    if (a != null && a.trim().isNotEmpty) {
      return a.trim();
    }
    return fallbackName;
  }

  String? getAlias(String remoteId) {
    final a = _deviceAliases[remoteId];
    if (a == null || a.trim().isEmpty) return null;
    return a.trim();
  }

  // 对外只读信息：设备名/ID与已选特征UUID
  String? get connectedDeviceName {
    final name = _connectedDevice?.platformName ?? '';
    return name.isEmpty ? null : name;
  }

  String? get connectedDeviceId => _connectedDevice?.remoteId.toString();
  String? get connectedServiceUuid =>
      _writeCharacteristic?.serviceUuid.toString() ??
      _notifyCharacteristic?.serviceUuid.toString();
  String? get writeCharacteristicSelectedUuid =>
      _writeCharacteristic?.uuid.toString();
  String? get notifyCharacteristicSelectedUuid =>
      _notifyCharacteristic?.uuid.toString();
  bool? get notifyEnabled => _notifyCharacteristic?.isNotifying;

  // 最近一次成功解析的主界面数据（用于实时展示）
  MainInterfaceData? latestMainData;
  // 最近一次成功收到并解析的主界面数据时间
  DateTime? lastMainDataAt;
  // 最近一次成功读取到设置数据的时间
  DateTime? lastSettingsDataAt;
  // 最近一次成功读取到历史数据的时间（单条）
  DateTime? lastHistoryDataAt;
  // 最近一次“完整拉取最近N天（默认30天）”的完成时间
  DateTime? lastHistoryPullAllAt;
  // 历史拉取状态
  bool isHistoryPulling = false;
  DateTime? historyPullStartAt;
  int historyPullExpectedDays = 0;
  // 最近拉取的历史数据（最多30天）
  List<HistoryData> latestHistoryDays = [];
  // 历史流式拉取状态与收集器（一次请求，设备逐帧发送）
  bool _historyStreamingActive = false;
  int _historyStreamingTargetDays = 0;
  List<HistoryData> _historyStreamingBuffer = [];
  Completer<List<HistoryData>>? _historyStreamingCompleter;
  Timer? _historyStreamingIdleTimer;
  // 历史拉取观测到的最大天数与稳定性判定（用于停止重试）
  int _observedMaxDay = -1; // 已观测到的最大 dayOffset
  int _lastMaxRoundMax = -1; // 上一轮请求开始时记录的最大 dayOffset
  int _stableMaxRoundCount = 0; // 连续两轮最大天数一致则结束（或最大天数为29）
  Timer? _delayedHistoryPullTimer;

  // 页面上下文与请求取消控制
  UiPageContext? _pendingContext;
  int _requestSeq = 0;
  int? _pendingRequestId;
  bool _pendingCanceled = false;
  int? _historyStreamRequestId;
  int? _pendingExpectedCmd;

  void _beginPending(UiPageContext ctx, [int? expectedCmd]) {
    _pendingContext = ctx;
    _pendingRequestId = ++_requestSeq;
    _pendingCanceled = false;
    _pendingExpectedCmd = expectedCmd;
  }

  bool _shouldAccept(UiPageContext expected, int? reqId) {
    if (_pendingCanceled) return false;
    if (_pendingContext != expected) return false;
    if (_pendingRequestId == null) return false;
    if (reqId == null) return false;
    return _pendingRequestId == reqId;
  }

  /// 取消当前挂起的响应接收（页面切换时调用）
  void cancelPendingResponse() {
    _pendingCanceled = true;
    _addLog("已标记取消当前挂起响应（页面切换）");
    // 若正在进行历史数据流式拉取，页面切换后需要立刻停止重试与计时器
    if (_historyStreamingActive) {
      _abortHistoryStreaming();
    }
    _delayedHistoryPullTimer?.cancel();
    _delayedHistoryPullTimer = null;
    _pendingExpectedCmd = null;
  }

  /// 判断是否已有完整历史缓存（默认30天）
  bool hasCompleteHistoryCache({int days = 30}) {
    // 改为仅按条数判断是否完整，缓存按天独立存储
    return latestHistoryDays.length >= days;
  }

  /// 判断自上次完整拉取是否已跨天
  bool _isCrossDaySinceLastPull() {
    // 改为按“最后一次成功获取到任意历史数据的时间”判断是否跨天
    final t = lastHistoryDataAt;
    if (t == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(t.year, t.month, t.day);
    return today.isAfter(lastDay);
  }

  /// 清空历史缓存（不持久化）
  void clearHistoryCache() {
    latestHistoryDays = [];
    lastHistoryPullAllAt = null;
    isHistoryPulling = false;
    historyPullStartAt = null;
    historyPullExpectedDays = 0;
    notifyListeners();
    _addLog("已清空历史缓存");
  }

  /// 若跨天则清理历史缓存
  void clearHistoryCacheIfCrossDay() {
    if (_isCrossDaySinceLastPull()) {
      _addLog("检测到跨天，清理历史缓存");
      clearHistoryCache();
    }
  }

  // UUID 等价匹配：支持 16-bit 短格式与完整 128-bit Bluetooth Base UUID 的等价比较
  String _normalizeUuid(String input) {
    final u = input.toUpperCase();
    final m = RegExp(
      r'^0000([0-9A-F]{4})-0000-1000-8000-00805F9B34FB$',
    ).firstMatch(u);
    if (m != null) {
      return m.group(1)!; // 提取短 UUID（4 位）
    }
    return u;
  }

  bool _isTargetServiceAdvertised(Iterable<fbp.Guid> guids) {
    final target = _normalizeUuid(serviceUuid);
    for (final g in guids) {
      if (_normalizeUuid(g.toString()) == target) {
        return true;
      }
    }
    return false;
  }

  bool _uuidEquals(String a, String b) {
    return _normalizeUuid(a) == _normalizeUuid(b);
  }

  /// 动态查找合适的写入和通知特征
  /// 优先级：1) 已知UUID匹配 2) 属性匹配（write/notify能力）
  void _findSuitableCharacteristics(
    List<fbp.BluetoothService> services, {
    bool isRetry = false,
  }) {
    final prefix = isRetry ? "[重试] " : "";

    // 首先尝试按已知UUID查找（向后兼容）
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        final charUuidStr = characteristic.uuid.toString();
        if (_writeCharacteristic == null &&
            _uuidEquals(charUuidStr, writeCharacteristicUuid)) {
          _writeCharacteristic = characteristic;
          _addLog(
            "${prefix}找到写入特征值(已知UUID): ${characteristic.uuid} 于服务 ${service.uuid}",
          );
          _addLog(
            "${prefix}写入特征属性: write=${characteristic.properties.write}, wwr=${characteristic.properties.writeWithoutResponse}",
          );
        }
        if (_notifyCharacteristic == null &&
            _uuidEquals(charUuidStr, notifyCharacteristicUuid)) {
          _notifyCharacteristic = characteristic;
          _addLog(
            "${prefix}找到通知特征值(已知UUID): ${characteristic.uuid} 于服务 ${service.uuid}",
          );
          _addLog(
            "${prefix}通知特征属性: notify=${characteristic.properties.notify}, indicate=${characteristic.properties.indicate}",
          );
        }
      }
      if (_writeCharacteristic != null && _notifyCharacteristic != null) {
        return; // 已找到所需特征
      }
    }

    // 如果按已知UUID未找到，则按属性动态查找
    _addLog("${prefix}按已知UUID未找到所有特征，开始按属性动态查找...");

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        final props = characteristic.properties;

        // 查找写入特征：优先选择支持write或writeWithoutResponse的特征
        if (_writeCharacteristic == null &&
            (props.write || props.writeWithoutResponse)) {
          _writeCharacteristic = characteristic;
          _addLog(
            "${prefix}找到写入特征值(按属性): ${characteristic.uuid} 于服务 ${service.uuid}",
          );
          _addLog(
            "${prefix}写入特征属性: write=${props.write}, wwr=${props.writeWithoutResponse}",
          );
        }

        // 查找通知特征：优先选择支持notify或indicate的特征
        if (_notifyCharacteristic == null && (props.notify || props.indicate)) {
          _notifyCharacteristic = characteristic;
          _addLog(
            "${prefix}找到通知特征值(按属性): ${characteristic.uuid} 于服务 ${service.uuid}",
          );
          _addLog(
            "${prefix}通知特征属性: notify=${props.notify}, indicate=${props.indicate}",
          );
        }
      }
      if (_writeCharacteristic != null && _notifyCharacteristic != null) {
        return; // 已找到所需特征
      }
    }

    // 如果仍未找到，记录详细信息
    if (_writeCharacteristic == null || _notifyCharacteristic == null) {
      final missing = [
        if (_writeCharacteristic == null)
          "写入特征(需要write或writeWithoutResponse属性)",
        if (_notifyCharacteristic == null) "通知特征(需要notify或indicate属性)",
      ].join(" 与 ");
      _addLog("${prefix}未找到: ${missing}");

      // 输出所有可用特征的详细信息，便于调试
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          final props = characteristic.properties;
          _addLog(
            "${prefix}可用特征: ${characteristic.uuid} 于服务 ${service.uuid} | 属性: read=${props.read}, write=${props.write}, wwr=${props.writeWithoutResponse}, notify=${props.notify}, indicate=${props.indicate}",
          );
        }
      }
    }
  }

  /// 请求蓝牙权限
  Future<bool> requestPermissions() async {
    try {
      if (!_bleSupportedPlatform) {
        _addLog("当前平台不支持 BLE，跳过权限请求");
        return false;
      }
      if (Platform.isAndroid) {
        _addLog("开始请求蓝牙权限(Android)");
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.location,
        ].request();
        _addLog("权限(bluetoothScan): ${statuses[Permission.bluetoothScan]}");
        _addLog(
          "权限(bluetoothConnect): ${statuses[Permission.bluetoothConnect]}",
        );
        _addLog(
          "权限(bluetoothAdvertise): ${statuses[Permission.bluetoothAdvertise]}",
        );
        _addLog("权限(location): ${statuses[Permission.location]}");
        try {
          final svc = await Permission.location.serviceStatus;
          _addLog("系统定位服务状态: ${svc}");
        } catch (_) {}

        bool allGranted = statuses.values.every(
          (status) =>
              status == PermissionStatus.granted ||
              status == PermissionStatus.limited,
        );

        if (!allGranted) {
          _addLog("蓝牙权限未完全授予(Android)");
          return false;
        }
        _addLog("蓝牙权限已授予(Android)");
        return true;
      } else if (Platform.isIOS || Platform.isMacOS) {
        try {
          final status = await Permission.bluetooth.status;
          _addLog("iOS/macOS 蓝牙权限状态: ${status}");
          if (status == PermissionStatus.granted ||
              status == PermissionStatus.limited) {
            _addLog("蓝牙权限已授予(iOS/macOS)");
            return true;
          }
          final r = await Permission.bluetooth.request();
          _addLog("iOS/macOS 蓝牙权限请求结果: ${r}");
          return true;
        } catch (_) {
          _addLog("蓝牙权限请求异常(iOS/macOS)");
          return true;
        }
      } else {
        _addLog("非 Android/Apple 平台无需显式权限请求，直接允许");
        return true;
      }
    } catch (e) {
      _addLog("请求权限失败: $e");
      return false;
    }
  }

  /// 清空已发现设备列表
  void clearDiscoveredDevices() {
    _discoveredDevices.clear();
    notifyListeners();
  }

  /// 开始扫描设备，仅收集设备列表（不自动连接）
  /// [nameFilter] 名称过滤；[duration] 扫描时长。
  /// 列表默认仅保留匹配目标广播/设备名称模式(SY_...AMPPT)的设备。
  Future<void> discoverDevices({
    String? nameFilter,
    Duration duration = const Duration(seconds: 30),
    bool filterTargetServiceOnly = false,
  }) async {
    try {
      if (!_bleSupportedPlatform) {
        _updateState(BluetoothConnectionState.error, "蓝牙不可用");
        return;
      }
      _addLog(
        "开始扫描(仅收集)，名称过滤: ${nameFilter?.trim().isNotEmpty == true ? nameFilter : '-'}",
      );
      // 检查蓝牙是否可用
      if (!await fbp.FlutterBluePlus.isSupported) {
        _updateState(BluetoothConnectionState.error, "蓝牙不可用");
        return;
      }
      // 检查蓝牙是否开启
      final adapter = await fbp.FlutterBluePlus.adapterState.first;
      _addLog("适配器状态: ${adapter.toString()}");
      if ((Platform.isAndroid && adapter != fbp.BluetoothAdapterState.on) ||
          (!Platform.isAndroid && adapter == fbp.BluetoothAdapterState.off)) {
        _updateState(BluetoothConnectionState.error, "请开启蓝牙");
        return;
      }
      // 请求权限
      if (!await requestPermissions()) {
        _updateState(BluetoothConnectionState.error, "权限不足");
        return;
      }

      // 不改变连接状态，保持当前连接；仅更新状态消息为“正在扫描...”
      _setStatus("正在扫描...");
      try {
        final svc = await Permission.location.serviceStatus;
        if (svc == ServiceStatus.disabled) {
          _addLog("提示: 系统定位服务处于关闭状态，可能导致扫描不到设备");
        }
      } catch (_) {}

      _discoveredDevices.clear();
      notifyListeners();

      await fbp.FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      try {
        await fbp.FlutterBluePlus.startScan(timeout: duration);
      } on PlatformException catch (e) {
        _addLog(
          "扫描异常(PlatformException): code=${e.code} message=${e.message} details=${e.details}",
        );
        _setStatus("已准备扫描");
        return;
      }
      _addLog("已调用 startScan (扫描所有设备，${duration.inSeconds}s 超时)");

      _scanSubscription?.cancel();
      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final device = result.device;
          final adv = result.advertisementData;
          final advName = adv.advName.isNotEmpty ? adv.advName : adv.localName;
          final nameForMatch = advName.isNotEmpty
              ? advName
              : device.platformName;
          final advLower = advName.toLowerCase();
          final devLower = device.platformName.toLowerCase();

          // 先按正则过滤（广播名优先，设备名回退），仅保留符合目标模式的设备；当过滤关闭时保留所有设备
          bool keep = _filterEnabled
              ? (_matchesTargetAdvName(nameForMatch))
              : true;
          if (!keep) {
            continue;
          }

          // 若提供 nameFilter，则在正则命中基础上再做包含匹配（广播名或设备名均可）
          bool matchFilter = true;
          if (_filterEnabled &&
              nameFilter != null &&
              nameFilter.trim().isNotEmpty) {
            final filter = nameFilter.trim().toLowerCase();
            matchFilter =
                advLower.contains(filter) || devLower.contains(filter);
          }
          if (!matchFilter) {
            continue;
          }

          // 更新/加入列表（以 remoteId 唯一）
          final remoteIdStr = device.remoteId.toString();
          final idx = _discoveredDevices.indexWhere(
            (r) => r.device.remoteId.toString() == remoteIdStr,
          );
          if (idx >= 0) {
            _discoveredDevices[idx] = result;
          } else {
            _discoveredDevices.add(result);
          }
        }
        notifyListeners();
      });

      // 超时后停止扫描但保留已发现列表
      Timer(duration, () async {
        await fbp.FlutterBluePlus.stopScan();
        _addLog("扫描定时器到期(${duration.inSeconds}s)，已停止扫描");
        // 保持连接状态不变，仅更新状态消息
        _setStatus("扫描结束");
      });
    } catch (e) {
      _addLog("扫描异常: $e");
      _setStatus("已准备扫描");
    }
  }

  /// 停止扫描
  Future<void> stopDiscovery() async {
    try {
      if (!_bleSupportedPlatform) {
        _setStatus("已停止扫描");
        return;
      }
      await fbp.FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      // 仅更新状态消息，避免打断现有连接状态
      _setStatus("已停止扫描");
    } catch (e) {
      _addLog("停止扫描异常: $e");
    }
  }

  /// 连接到已发现的指定设备
  Future<void> connectToRemoteId(String remoteId) async {
    try {
      if (!_bleSupportedPlatform) {
        _updateState(BluetoothConnectionState.error, "蓝牙不可用");
        return;
      }
      _addLog("准备通过 remoteId 连接: ${remoteId}");
      // 停止扫描
      await fbp.FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();

      final result = _discoveredDevices.firstWhere(
        (r) => r.device.remoteId.toString() == remoteId,
        orElse: () => throw Exception("未在已发现列表中找到设备: $remoteId"),
      );
      _addLog(
        "已选设备: 名称=${result.device.platformName.isEmpty ? '(无名设备)' : result.device.platformName}, remoteId=${result.device.remoteId}",
      );
      await _connectToDevice(result.device);
    } catch (e) {
      _updateState(BluetoothConnectionState.error, "连接失败: $e");
      _addLog("连接异常: $e");
    }
  }

  /// 扫描并连接设备
  /// 支持按 `remoteId` 精确匹配优先，其次按设备名包含匹配，最后按广播名称模式匹配
  Future<void> scanAndConnect({
    String? targetDeviceName,
    String? targetRemoteId,
  }) async {
    try {
      if (!_bleSupportedPlatform) {
        _updateState(BluetoothConnectionState.error, "蓝牙不可用");
        return;
      }
      _addLog(
        "开始扫描并连接，目标remoteId: ${targetRemoteId?.trim().isNotEmpty == true ? targetRemoteId : '-'}，目标设备名: ${targetDeviceName?.trim().isNotEmpty == true ? targetDeviceName : '-'}",
      );
      // 检查蓝牙是否可用
      if (!await fbp.FlutterBluePlus.isSupported) {
        _updateState(BluetoothConnectionState.error, "蓝牙不可用");
        return;
      }

      // 检查蓝牙是否开启
      final adapter = await fbp.FlutterBluePlus.adapterState.first;
      _addLog("适配器状态: ${adapter.toString()}");
      if ((Platform.isAndroid && adapter != fbp.BluetoothAdapterState.on) ||
          (!Platform.isAndroid && adapter == fbp.BluetoothAdapterState.off)) {
        _updateState(BluetoothConnectionState.error, "请开启蓝牙");
        return;
      }
      // 如需在 Android 上尝试自动开启蓝牙，可在此处调用平台方法。
      // 目前不调用以避免不兼容 API 导致编译失败。

      // 请求权限
      if (!await requestPermissions()) {
        _updateState(BluetoothConnectionState.error, "权限不足");
        return;
      }

      _updateState(BluetoothConnectionState.scanning, "正在扫描...");
      // Android 设备若未开启系统定位服务，BLE 扫描可能无结果（即使权限已授予）
      try {
        final svc = await Permission.location.serviceStatus;
        if (svc == ServiceStatus.disabled) {
          _addLog("提示: 系统定位服务处于关闭状态，可能导致扫描不到设备");
        }
      } catch (_) {}

      await fbp.FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      try {
        await fbp.FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 30),
        );
      } on PlatformException catch (e) {
        _addLog(
          "扫描异常(PlatformException): code=${e.code} message=${e.message} details=${e.details}",
        );
        _setStatus("已准备扫描");
        return;
      }
      _addLog("已调用 startScan (扫描所有设备，30s 超时)");

      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((
        results,
      ) async {
        for (fbp.ScanResult result in results) {
          final device = result.device;
          final adv = result.advertisementData;
          final advName = adv.advName.isNotEmpty ? adv.advName : adv.localName;
          final connectable = adv.connectable;
          final remoteIdStr = device.remoteId.toString();

          // 名称用于匹配：优先使用广播名；若为空则回退到设备名
          final nameForMatch = (advName.isNotEmpty
              ? advName
              : device.platformName);
          final advLower = advName.toLowerCase();
          final devLower = device.platformName.toLowerCase();

          // 记录发现日志（包含广播与设备名称）
          _addLog(
            "发现设备: ${device.platformName.isEmpty ? '(无名设备)' : device.platformName} (${remoteIdStr}) | 广播名: ${advName.isEmpty ? '-' : advName} | 可连接: ${connectable}",
          );

          // 目标匹配：优先remoteId，其次名称包含；默认按名称模式（广播或设备名）
          bool match;
          if (targetRemoteId != null && targetRemoteId.trim().isNotEmpty) {
            match = remoteIdStr == targetRemoteId.trim();
            if (!match) {
              continue;
            }
            _addLog("匹配到目标remoteId设备: ${remoteIdStr}");
          } else if (targetDeviceName != null &&
              targetDeviceName.trim().isNotEmpty) {
            final filter = targetDeviceName.trim().toLowerCase();
            // 名称匹配同时考虑广播名与设备名，提升命中率
            match = advLower.contains(filter) || devLower.contains(filter);
          } else {
            match = _filterEnabled
                ? (_matchesTargetAdvName(nameForMatch))
                : true;
          }
          if (!match) {
            continue;
          }

          // 匹配成功，尝试连接该设备
          await _connectToDevice(device);
          break;
        }
      });

      // 30秒后停止扫描
      Timer(const Duration(seconds: 30), () async {
        await fbp.FlutterBluePlus.stopScan();
        _addLog("扫描定时器到期，未匹配到设备，已停止扫描");
        if (_connectionState == BluetoothConnectionState.scanning) {
          _updateState(BluetoothConnectionState.disconnected, "未找到设备");
        }
      });
    } catch (e) {
      _addLog("扫描异常: $e");
      _setStatus("已准备扫描");
    }
  }

  /// 连接到指定设备
  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await fbp.FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();

      // 在连接新设备前，清理旧的通知订阅与特征引用，避免沿用旧设备的特征对象
      try {
        if (_notifyCharacteristic != null &&
            (_notifyCharacteristic!.isNotifying)) {
          _addLog("关闭旧通知: uuid=${_notifyCharacteristic!.uuid}");
          await _notifyCharacteristic!.setNotifyValue(false);
        }
      } catch (e) {
        _addLog("关闭旧通知失败: ${e}");
      }
      _notificationSubscription?.cancel();
      _notificationSubscription = null;
      _writeCharacteristic = null;
      _notifyCharacteristic = null;
      _lastReceivedData = null;
      _responseCompleter = null;

      // 如已有不同设备连接，则先断开旧连接，避免多设备并行导致写入/通知混乱
      if (_connectedDevice != null &&
          _connectedDevice!.remoteId.toString() != device.remoteId.toString()) {
        try {
          _addLog(
            "检测到旧连接设备，先断开: name=${_connectedDevice!.platformName.isEmpty ? '(无名设备)' : _connectedDevice!.platformName}, id=${_connectedDevice!.remoteId}",
          );
          _manualDisconnecting = true;
          _deviceStateSubscription?.cancel();
          await _connectedDevice!.disconnect();
          _addLog("已断开旧设备");
        } catch (e) {
          _addLog("断开旧设备异常: ${e}");
        } finally {
          _manualDisconnecting = false;
          _connectedDevice = null;
        }
      }

      // 记录“正在连接”的目标设备ID，供UI高亮显示
      _connectingRemoteId = device.remoteId.toString();
      notifyListeners();
      _updateState(
        BluetoothConnectionState.connecting,
        "正在连接 ${device.platformName}...",
      );
      _unexpectedDisconnected = false;

      // 在开始连接新设备前，清空旧设备相关数据缓存，避免旧数据短暂残留在界面
      latestMainData = null;
      lastMainDataAt = null;
      // 历史数据缓存重置
      latestHistoryDays = [];
      isHistoryPulling = false;
      historyPullStartAt = null;
      historyPullExpectedDays = 0;
      lastHistoryDataAt = null;
      lastHistoryPullAllAt = null;
      // 设置数据最近时间重置（表单由界面自行清空）
      lastSettingsDataAt = null;
      notifyListeners();

      // 连接设备
      // 提高超时时间，避免在部分设备上因初始化缓慢导致连接超时
      // 明确禁用 autoConnect（Android某些机型在 autoConnect=true 时连接不稳定）
      _addLog(
        "连接调用开始: name=${device.platformName.isEmpty ? '(无名设备)' : device.platformName}, remoteId=${device.remoteId}, timeout=20s, autoConnect=false, platform=${Platform.operatingSystem}",
      );
      await device.connect(
        timeout: const Duration(seconds: 20),
        autoConnect: false,
      );
      _connectedDevice = device;
      // 连接成功后清除连接中标记
      _connectingRemoteId = null;
      _unexpectedDisconnected = false;
      notifyListeners();

      _deviceStateSubscription?.cancel();
      _deviceStateSubscription = device.connectionState.listen((s) async {
        if (s == fbp.BluetoothConnectionState.disconnected) {
          if (!_manualDisconnecting) {
            _unexpectedDisconnected = true;
            _updateState(BluetoothConnectionState.disconnected, "连接已断开（异常）");
          }
        }
      });

      _addLog("已连接到设备: ${device.platformName}");

      // 某些设备连接后需要短暂延迟再发现服务
      await Future.delayed(const Duration(milliseconds: 300));

      // 发现服务（第1次）
      List<fbp.BluetoothService> services = await device.discoverServices();
      _addLog("已发现服务数量: ${services.length}");
      for (final s in services) {
        final chars = s.characteristics
            .map((c) => c.uuid.toString())
            .join(", ");
        _addLog("服务: ${s.uuid} | 特征: ${chars.isEmpty ? '-' : chars}");
      }

      // 动态查找合适的特征（不再依赖固定UUID）
      _findSuitableCharacteristics(services);

      // 若第一次发现后仍未找到两个特征，进行一次重试（部分设备首轮服务列表不完整）
      if (_writeCharacteristic == null || _notifyCharacteristic == null) {
        _addLog("首次服务发现未找到必要特征，准备重试...");
        await Future.delayed(const Duration(seconds: 1));
        services = await device.discoverServices();
        _addLog("重试发现服务数量: ${services.length}");
        for (final s in services) {
          final chars = s.characteristics
              .map((c) => c.uuid.toString())
              .join(", ");
          _addLog("[重试] 服务: ${s.uuid} | 特征: ${chars.isEmpty ? '-' : chars}");
        }
        // 重试动态查找合适的特征
        _findSuitableCharacteristics(services, isRetry: true);
      }

      // 启用通知（仅当支持 notify 属性）
      if (_notifyCharacteristic != null) {
        try {
          _addLog(
            "尝试启用通知: uuid=${_notifyCharacteristic!.uuid}, notify=${_notifyCharacteristic!.properties.notify}, indicate=${_notifyCharacteristic!.properties.indicate}",
          );
          final ok = await _notifyCharacteristic!.setNotifyValue(true);
          _addLog(
            "通知使能结果: ${ok} | isNotifying=${_notifyCharacteristic!.isNotifying}",
          );
          // 使用 onValueReceived 订阅通知，更贴近平台回包
          _notificationSubscription = _notifyCharacteristic!.onValueReceived
              .listen(_onNotificationReceived);
          _addLog("已启用通知");

          // 在通知启用成功后，立即发送一次主数据请求，避免仅依赖定时轮询
          // 这有助于连接后首帧尽快到达并验证写入/回包通路
          try {
            _addLog("通知启用后立即发送首帧主数据请求");
            await requestMainData();
          } catch (e) {
            _addLog("首帧主数据请求异常: ${e}");
          }
        } catch (e) {
          _addLog("启用通知失败: $e");
        }
      }

      if (_writeCharacteristic != null && _notifyCharacteristic != null) {
        _updateState(BluetoothConnectionState.connected, "已连接");
        _addLog("蓝牙连接建立成功");
        // 连接成功后，持久化最近连接的设备信息，便于下次启动自动匹配
        try {
          await _saveLastConnected(device);
        } catch (e) {
          _addLog('保存最近设备信息失败: ' + e.toString());
        }
      } else {
        // 输出更详细的错误信息，便于定位问题
        final svcList = services.map((s) => s.uuid.toString()).join(", ");
        final missing = [
          if (_writeCharacteristic == null)
            "写入特征(需要write或writeWithoutResponse属性)",
          if (_notifyCharacteristic == null) "通知特征(需要notify或indicate属性)",
        ].join(" 与 ");
        throw Exception(
          "未找到必要的特征值: ${missing}. 已发现服务: ${svcList.isEmpty ? '-(空)' : svcList}",
        );
      }
    } catch (e) {
      _updateState(BluetoothConnectionState.error, "连接失败: $e");
      _addLog("连接异常: $e");
      // 异常时清除连接中标记
      _connectingRemoteId = null;
      notifyListeners();
      await disconnect();
    }
  }

  /// 尝试在应用启动后自动连接：优先使用历史设备名匹配；否则回退按服务过滤扫描连接
  Future<void> autoConnectOnStartup() async {
    try {
      _addLog('启动自动连接尝试');
      if (!_bleSupportedPlatform) {
        _addLog('蓝牙插件在当前平台不支持，跳过自动连接');
        return;
      }
      // 环境检查
      if (!await fbp.FlutterBluePlus.isSupported) {
        _addLog('蓝牙不可用，跳过自动连接');
        return;
      }
      final adapter = await fbp.FlutterBluePlus.adapterState.first;
      _addLog('适配器状态: ${adapter.toString()}');
      if ((Platform.isAndroid && adapter != fbp.BluetoothAdapterState.on) ||
          (!Platform.isAndroid && adapter == fbp.BluetoothAdapterState.off)) {
        _addLog('蓝牙未开启，跳过自动连接');
        return;
      }
      // 权限
      if (!await requestPermissions()) {
        _addLog('权限不足，跳过自动连接');
        return;
      }

      // 1) 优先使用历史 remoteId 精确匹配（比设备名更稳定）
      final lastId = await _loadLastRemoteId();
      if (lastId != null && lastId.trim().isNotEmpty) {
        final targetId = lastId.trim();
        _addLog('自动连接：优先按历史remoteId匹配 -> ' + targetId);
        await scanAndConnect(targetRemoteId: targetId);
        Timer(const Duration(seconds: 5), () async {
          if (!isConnected) {
            _addLog('自动连接重试(5s) -> remoteId ' + targetId);
            await scanAndConnect(targetRemoteId: targetId);
          }
        });
      } else {
        // 2) 回退使用历史设备名包含匹配
        final lastName = await _loadLastDeviceName();
        if (lastName != null && lastName.trim().isNotEmpty) {
          final targetName = lastName.trim();
          _addLog('自动连接：回退按历史设备名匹配 -> ' + targetName);
          await scanAndConnect(targetDeviceName: targetName);
          Timer(const Duration(seconds: 5), () async {
            if (!isConnected) {
              _addLog('自动连接重试(5s) -> 名称 ' + targetName);
              await scanAndConnect(targetDeviceName: targetName);
            }
          });
        } else {
          _addLog('自动连接：无历史设备信息，扫描并连接第一个可用设备');
          // 直接使用扫描并连接逻辑（未提供名称时连接第一个发现的设备）
          await scanAndConnect();
          Timer(const Duration(seconds: 5), () async {
            if (!isConnected) {
              _addLog('自动连接重试(5s) -> 连接第一个可用设备');
              await scanAndConnect();
            }
          });
        }
      }
    } catch (e) {
      _addLog('自动连接流程异常: ' + e.toString());
    }
  }

  Future<void> _saveLastConnected(fbp.BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyLastRemoteId, device.remoteId.toString());
    final name = device.platformName;
    if (name.isNotEmpty) {
      await prefs.setString(_prefsKeyLastDeviceName, name);
    }
    _addLog(
      '已保存最近设备: name=' +
          (name.isEmpty ? '(无名设备)' : name) +
          ', id=' +
          device.remoteId.toString(),
    );
  }

  /// 检查蓝牙是否已开启（适配器状态为 on）
  Future<bool> isBluetoothOn() async {
    try {
      if (!_bleSupportedPlatform) {
        return false;
      }
      if (!await fbp.FlutterBluePlus.isSupported) {
        return false;
      }
      final adapter = await fbp.FlutterBluePlus.adapterState.first;
      if (Platform.isAndroid) {
        return adapter == fbp.BluetoothAdapterState.on;
      }
      return adapter != fbp.BluetoothAdapterState.off;
    } catch (_) {
      return false;
    }
  }

  /// 在 Android 上尝试弹出系统对话框以开启蓝牙
  Future<void> turnOnBluetoothOnAndroid() async {
    try {
      if (!_bleSupportedPlatform) {
        return;
      }
      if (Platform.isAndroid) {
        await fbp.FlutterBluePlus.turnOn();
      }
    } catch (e) {
      _addLog('请求开启蓝牙失败: ' + e.toString());
    }
  }

  Future<String?> _loadLastDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefsKeyLastDeviceName);
    _addLog('读取历史设备名: ' + (name ?? '(无)'));
    return name;
  }

  Future<String?> _loadLastRemoteId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKeyLastRemoteId);
    _addLog('读取历史设备ID: ' + (id ?? '(无)'));
    return id;
  }

  /// 加载设备别名映射（从持久化存储）
  Future<void> loadDeviceAliases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKeyDeviceAliases);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map) {
          _deviceAliases = decoded.map(
            (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
          );
        }
      }
      _addLog('已加载设备别名: ${_deviceAliases.length} 条');
      notifyListeners();
    } catch (e) {
      _addLog('加载设备别名失败: $e');
    }
  }

  /// 设置/更新指定设备的别名并持久化；空字符串将移除别名
  Future<void> setDeviceAlias(String remoteId, String alias) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trimmed = alias.trim();
      if (trimmed.isEmpty) {
        _deviceAliases.remove(remoteId);
      } else {
        _deviceAliases[remoteId] = trimmed;
      }
      await prefs.setString(_prefsKeyDeviceAliases, jsonEncode(_deviceAliases));
      _addLog(
        '设备别名已更新: id=$remoteId, alias=' + (trimmed.isEmpty ? '(清除)' : trimmed),
      );
      notifyListeners();
    } catch (e) {
      _addLog('保存设备别名失败: $e');
    }
  }

  /// 清除所有设备别名并持久化
  Future<void> clearAllAliases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceAliases.clear();
      await prefs.setString(_prefsKeyDeviceAliases, jsonEncode(_deviceAliases));
      _addLog('已清除所有设备别名');
      notifyListeners();
    } catch (e) {
      _addLog('清除设备别名失败: $e');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    try {
      _addLog("准备断开连接...");
      _manualDisconnecting = true;
      _notificationSubscription?.cancel();
      _scanSubscription?.cancel();
      _deviceStateSubscription?.cancel();

      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _addLog("已断开连接");
      }

      _connectedDevice = null;
      _connectingRemoteId = null; // 断开时也清除连接中标记
      _writeCharacteristic = null;
      _notifyCharacteristic = null;
      _notificationSubscription = null;
      latestMainData = null; // 清空缓存的主数据
      // 重置历史与设置状态
      latestHistoryDays = [];
      isHistoryPulling = false;
      historyPullStartAt = null;
      historyPullExpectedDays = 0;
      lastMainDataAt = null;
      lastSettingsDataAt = null;
      lastHistoryDataAt = null;
      lastHistoryPullAllAt = null;

      _updateState(BluetoothConnectionState.disconnected, "已断开连接");
    } catch (e) {
      _addLog("断开连接异常: $e");
    } finally {
      _manualDisconnecting = false;
      _unexpectedDisconnected = false;
    }
  }

  /// 发送数据
  Future<bool> sendData(List<int> data) async {
    if (!isConnected || _writeCharacteristic == null) {
      _addLog("设备未连接，无法发送数据");
      return false;
    }

    // 优先使用 Write（带响应），若不可用则回退到 Write Without Response
    final props = _writeCharacteristic!.properties;
    final supportsWrite = props.write;
    final supportsWWR = props.writeWithoutResponse;
    final previewHex = BleProtocol.toHexString(
      data.length > 12 ? data.sublist(0, 12) : data,
    );

    Future<void> _doWrite(bool withoutResponse) async {
      _addLog(
        "写入准备: mode=${withoutResponse ? 'WWR' : 'WW'} len=${data.length} preview=${previewHex} props(write=${supportsWrite}, wwr=${supportsWWR})",
      );
      await _writeCharacteristic!.write(data, withoutResponse: withoutResponse);
      _addLog(
        "写入完成: mode=${withoutResponse ? 'WWR' : 'WW'} len=${data.length}",
      );
    }

    try {
      if (supportsWrite) {
        try {
          await _doWrite(false);
          return true;
        } catch (e) {
          _addLog("写入失败(WW)，尝试回退到WWR: ${e}");
          if (supportsWWR) {
            try {
              await _doWrite(true);
              return true;
            } catch (e2) {
              _addLog("写入失败(WWR) 也失败: ${e2}");
              return false;
            }
          }
          return false;
        }
      } else if (supportsWWR) {
        try {
          await _doWrite(true);
          return true;
        } catch (e) {
          _addLog("写入失败(WWR): ${e}");
          return false;
        }
      } else {
        _addLog("当前特征不支持Write或WWR，无法发送");
        return false;
      }
    } catch (e) {
      _addLog("发送数据失败: ${e}");
      return false;
    }
  }

  /// 请求主界面数据
  Future<MainInterfaceData?> requestMainData({
    UiPageContext context = UiPageContext.realtime,
  }) async {
    // 先准备响应等待器，避免设备快速回包导致回调早于等待器创建
    _responseCompleter = Completer<List<int>>();
    _beginPending(context, BleProtocol.cmdMain);
    notifyListeners();
    final request = BleProtocol.buildMainDataRequest();
    if (await sendData(request)) {
      // 等待响应（实际应用中可能需要更复杂的响应处理机制）
      return await _waitForMainDataResponse(
        expectedContext: context,
        requestId: _pendingRequestId!,
      );
    }
    // 发送失败则清理等待器
    _responseCompleter = null;
    _pendingExpectedCmd = null;
    notifyListeners();
    return null;
  }

  /// 设置负载开关（实时页面控制）
  /// on=true 打开负载；on=false 关闭负载
  Future<bool> setLoadSwitch(bool on) async {
    // 等待主界面数据作为反馈（模拟端会回主数据）
    _responseCompleter = Completer<List<int>>();
    notifyListeners();
    final request = BleProtocol.buildLoadSwitchControl(on);
    if (await sendData(request)) {
      try {
        final resp = await _responseCompleter!.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _addLog("等待负载控制响应超时");
            throw TimeoutException("负载控制响应超时", const Duration(seconds: 5));
          },
        );
        final parsed = BleProtocol.parseMainDataResponse(resp);
        if (parsed != null) {
          latestMainData = parsed;
          lastMainDataAt = DateTime.now();
          notifyListeners();
        } else {
          _addLog("负载控制后主数据解析失败");
        }
        return true;
      } catch (e) {
        _addLog("负载控制等待异常: $e");
        return true; // 即便无回包也认为控制帧已发送
      } finally {
        _responseCompleter = null;
        notifyListeners();
      }
    }
    _responseCompleter = null;
    notifyListeners();
    return false;
  }

  /// 请求设置数据
  Future<SettingsData?> requestSettingsData({
    UiPageContext context = UiPageContext.settings,
  }) async {
    _responseCompleter = Completer<List<int>>();
    _beginPending(context, BleProtocol.cmdSettings);
    notifyListeners();
    final request = BleProtocol.buildSettingsReadRequest();
    if (await sendData(request)) {
      return await _waitForSettingsResponse(
        expectedContext: context,
        requestId: _pendingRequestId!,
      );
    }
    _responseCompleter = null;
    _pendingExpectedCmd = null;
    notifyListeners();
    return null;
  }

  /// 写入设置数据
  Future<bool> writeSettingsData(
    SettingsData settings, {
    UiPageContext context = UiPageContext.settings,
  }) async {
    _responseCompleter = Completer<List<int>>();
    _beginPending(context, BleProtocol.cmdSettings);
    notifyListeners();
    final request = BleProtocol.buildSettingsWriteRequest(settings);
    if (await sendData(request)) {
      // 等待写入确认响应
      return await _waitForWriteAck(
        expectedContext: context,
        requestId: _pendingRequestId!,
      );
    }
    _responseCompleter = null;
    _pendingExpectedCmd = null;
    notifyListeners();
    return false;
  }

  /// 请求历史数据
  Future<HistoryData?> requestHistoryData({
    UiPageContext context = UiPageContext.history,
  }) async {
    _responseCompleter = Completer<List<int>>();
    _beginPending(context, BleProtocol.cmdHistory);
    notifyListeners();
    final request = BleProtocol.buildHistoryRequest();
    if (await sendData(request)) {
      return await _waitForHistoryResponse(
        expectedContext: context,
        requestId: _pendingRequestId!,
      );
    }
    _responseCompleter = null;
    _pendingExpectedCmd = null;
    notifyListeners();
    return null;
  }

  /// 清除设备历史数据，并同步清空本地历史缓存
  Future<bool> clearHistoryOnDevice() async {
    _addLog("准备发送历史清除请求帧");
    final ok = await sendData(BleProtocol.buildHistoryClearRequest());
    if (ok) {
      // 若正在进行历史拉取（包含空闲重试计时器），先主动终止，避免在清除后延迟再次自动拉取
      if (_historyStreamingActive) {
        _addLog("清除历史期间，终止正在进行的历史拉取与重试计时器");
        _abortHistoryStreaming();
      }
      _addLog("历史清除请求已发送，清空本地历史缓存");
      clearHistoryCache();
      _delayedHistoryPullTimer?.cancel();
      _delayedHistoryPullTimer = Timer(const Duration(seconds: 2), () async {
        try {
          if (!isConnected) {
            _addLog("清除后自动拉取被跳过：未连接");
            return;
          }
          if (_historyStreamingActive) {
            _addLog("清除后自动拉取被跳过：已在拉取中");
            return;
          }
          if (_pendingCanceled) {
            _addLog("清除后自动拉取被跳过：页面已切换");
            return;
          }
          _addLog("清除后延迟2秒，自动请求最近30天历史");
          await requestHistoryLastDays(
            days: 30,
            context: UiPageContext.history,
          );
        } catch (e) {
          _addLog("清除后自动拉取异常: ${e}");
        } finally {
          _delayedHistoryPullTimer = null;
        }
      });
    } else {
      _addLog("历史清除请求发送失败");
    }
    return ok;
  }

  /// 连续请求最近N天历史数据（协议要求连续请求），默认30天
  Future<List<HistoryData>> requestHistoryLastDays({
    int days = 30,
    Duration interval = const Duration(milliseconds: 120),
    UiPageContext context = UiPageContext.history,
  }) async {
    // 改造为：一次请求，设备逐帧发送 30 天数据（协议草案约定）
    isHistoryPulling = true;
    historyPullStartAt = DateTime.now();
    historyPullExpectedDays = days;
    latestHistoryDays = [];
    notifyListeners();

    // 初始化流式收集器
    _historyStreamingActive = true;
    _historyStreamingTargetDays = days;
    _historyStreamingBuffer = [];
    _historyStreamingCompleter = Completer<List<HistoryData>>();
    _observedMaxDay = -1;
    _lastMaxRoundMax = -1;
    _stableMaxRoundCount = 0;

    // 记录本次流式拉取的上下文与请求 ID，用于页面切换后忽略响应
    _beginPending(context, BleProtocol.cmdHistory);
    _historyStreamRequestId = _pendingRequestId;

    // 发送一次历史请求帧
    final request = BleProtocol.buildHistoryRequest();
    final ok = await sendData(request);
    if (!ok) {
      _addLog("历史拉取请求发送失败");
      _historyStreamingActive = false;
      isHistoryPulling = false;
      _historyStreamingCompleter = null;
      return [];
    }

    // 设置空闲计时器：若一段时间未收到新历史帧，则自动重发请求直到收满
    _resetHistoryIdleTimer();

    try {
      // 不设置整体超时：按需求持续重试直到收满目标天数
      final results = await _historyStreamingCompleter!.future;
      _addLog("历史数据拉取完成，共${results.length}/${days}条");
      return results;
    } finally {
      _historyStreamingIdleTimer?.cancel();
      _historyStreamingIdleTimer = null;
      _historyStreamingCompleter = null;
      _historyStreamingActive = false;
      isHistoryPulling = false;
      if (latestHistoryDays.length >= days) {
        lastHistoryPullAllAt = DateTime.now();
      }
      notifyListeners();
    }
  }

  void _finishHistoryStreaming() {
    // 将收集到的数据写入最新缓存并完成 future
    latestHistoryDays = [..._historyStreamingBuffer];
    // 记录“最近一次拉取完成时间”（即按当前规则已结束本轮拉取），用于历史页显示
    lastHistoryPullAllAt = DateTime.now();
    if (_historyStreamingCompleter != null &&
        !_historyStreamingCompleter!.isCompleted) {
      _historyStreamingCompleter!.complete(_historyStreamingBuffer);
    }
    // 通知界面刷新，使“最近一次拉取时间”立即可见
    notifyListeners();
  }

  void _abortHistoryStreaming() {
    _addLog("历史流式拉取已因页面切换取消，忽略后续帧");
    _historyStreamingIdleTimer?.cancel();
    _historyStreamingIdleTimer = null;
    if (_historyStreamingCompleter != null &&
        !_historyStreamingCompleter!.isCompleted) {
      _historyStreamingCompleter!.complete(_historyStreamingBuffer);
    }
    _historyStreamingCompleter = null;
    _historyStreamingActive = false;
    isHistoryPulling = false;
    notifyListeners();
  }

  // 判断是否已收齐 0..maxDay 的连续天数
  bool _hasContiguousDaysUpTo(int maxDay) {
    if (maxDay < 0) return false;
    final set = _historyStreamingBuffer.map((e) => e.dayOffset).toSet();
    for (int d = 0; d <= maxDay; d++) {
      if (!set.contains(d)) return false;
    }
    return true;
  }

  // 重置历史拉取的空闲计时器，并在超时时根据“最大天数与连续性判定”进行重发或结束
  void _resetHistoryIdleTimer() {
    _historyStreamingIdleTimer?.cancel();
    _historyStreamingIdleTimer = Timer(const Duration(seconds: 5), () async {
      if (!_historyStreamingActive) return;
      // 页面切换后已标记取消，停止历史拉取重试
      if (_pendingCanceled) {
        _addLog("历史拉取空闲计时器检测到取消标记，停止重试");
        _abortHistoryStreaming();
        return;
      }

      final max = _observedMaxDay;
      final contiguous = _hasContiguousDaysUpTo(max);

      if (!contiguous || max < 0) {
        // 仍有缺失天数或尚未观测到最大天数，继续请求
        _addLog("历史拉取空闲超时，存在缺失天数或未观测到最大天数，重发请求");
        await sendData(BleProtocol.buildHistoryRequest());
        _resetHistoryIdleTimer();
        return;
      }

      // 已收齐 0..max 的连续天数
      if (max >= _historyStreamingTargetDays - 1) {
        // 最大天数已到 29（当目标为30天时），直接结束
        _addLog("已收齐0..$max，最大天=${max}==${_historyStreamingTargetDays - 1}，结束");
        _finishHistoryStreaming();
        return;
      }

      // 最大天数未到 29：允许进行“最大天数一致性”检查，每轮空闲时触发一次请求
      if (_lastMaxRoundMax == -1) {
        _lastMaxRoundMax = max;
        _stableMaxRoundCount = 0; // 开启一致性检查，从第1轮开始
      } else {
        if (max == _lastMaxRoundMax) {
          _stableMaxRoundCount++;
        } else {
          _lastMaxRoundMax = max;
          _stableMaxRoundCount = 0;
        }
      }

      if (_stableMaxRoundCount >= 2) {
        // 两次新请求后最大天数保持一致，认为设备最大天数稳定，结束
        _addLog("两次新请求后最大天数保持一致(${max})，结束");
        _finishHistoryStreaming();
        return;
      }

      _addLog(
        "已收齐0..$max 且最大天(${max})<${_historyStreamingTargetDays - 1}，继续请求以确认稳定性(第${_stableMaxRoundCount + 1}次)",
      );
      await sendData(BleProtocol.buildHistoryRequest());
      _resetHistoryIdleTimer();
    });
  }

  /// 处理接收到的通知数据
  void _onNotificationReceived(List<int> data) {
    _addLog("接收数据: ${BleProtocol.toHexString(data)}");
    if (data.isNotEmpty) {
      final prefixLen = BleProtocol.guideResponsePrefix.length;
      final guides = data.length >= prefixLen
          ? data.sublist(0, prefixLen)
          : data;
      final lenField = data.length > prefixLen ? data[prefixLen] : -1;
      final cmd = data.length > prefixLen + 1 ? data[prefixLen + 1] : -1;
      _addLog(
        "响应头: guides=${BleProtocol.toHexString(guides)} len=${lenField} cmd=0x${cmd.toRadixString(16).toUpperCase()} total=${data.length}",
      );

      // 历史流式拉取：设备在一次请求后逐帧发送历史数据
      if (_historyStreamingActive && cmd == BleProtocol.cmdHistory) {
        // 页面切换后不再接收响应数据
        if (!_shouldAccept(UiPageContext.history, _historyStreamRequestId)) {
          _abortHistoryStreaming();
          return;
        }
        final parsed = BleProtocol.parseHistoryResponse(data);
        if (parsed != null) {
          // 更新“最后获取历史数据时间”用于跨天清理判断
          lastHistoryDataAt = DateTime.now();
          // 按 dayOffset 去重，避免重复帧
          final exists = _historyStreamingBuffer.any(
            (e) => e.dayOffset == parsed.dayOffset,
          );
          if (!exists) {
            _historyStreamingBuffer = [..._historyStreamingBuffer, parsed];
            latestHistoryDays = [...latestHistoryDays, parsed];
            _addLog(
              "[历史流] 收到 dayOffset=${parsed.dayOffset}，累计 ${_historyStreamingBuffer.length}/${_historyStreamingTargetDays} 条",
            );
          } else {
            // 若收到重复日的数据，使用新数据替换旧条目（按天独立缓存）
            _historyStreamingBuffer = _historyStreamingBuffer
                .map((e) => e.dayOffset == parsed.dayOffset ? parsed : e)
                .toList();
            latestHistoryDays = latestHistoryDays
                .map((e) => e.dayOffset == parsed.dayOffset ? parsed : e)
                .toList();
            _addLog("[历史流] 替换已有 dayOffset=${parsed.dayOffset} 的数据");
          }
          // 更新最大天数观测值
          if (parsed.dayOffset > _observedMaxDay) {
            _observedMaxDay = parsed.dayOffset;
          }
          notifyListeners();

          // 若已收齐 0..max 且 max 达到目标（29），立即结束；否则重置空闲计时器按规则继续
          final max = _observedMaxDay;
          if (_hasContiguousDaysUpTo(max) &&
              max >= _historyStreamingTargetDays - 1) {
            _addLog("[历史流] 已收齐 0..$max 且最大天达到目标，结束");
            _finishHistoryStreaming();
          } else {
            _resetHistoryIdleTimer();
          }
        } else {
          _addLog("[历史流] 解析失败");
        }
        // 历史流式模式下，本帧已处理，不再走单次等待器逻辑
        return;
      }
    } else {
      _addLog("响应为空");
    }
    if (_responseCompleter == null) {
      _addLog("收到响应但当前无等待器(可能请求创建/发送时序问题)");
    }

    _lastReceivedData = data;
    if (_pendingExpectedCmd == null) {
      _responseCompleter?.complete(data);
    } else {
      final prefixLen2 = BleProtocol.guideResponsePrefix.length;
      final cmd2 = data.length > prefixLen2 + 1 ? data[prefixLen2 + 1] : -1;
      if (cmd2 == _pendingExpectedCmd) {
        _responseCompleter?.complete(data);
      } else {
        _addLog("忽略非期望命令响应");
      }
    }
  }

  List<int>? _lastReceivedData;
  Completer<List<int>>? _responseCompleter;

  // 对外暴露：是否正在等待一次请求的响应（用于全局 Loading）
  bool get isAwaitingResponse => _responseCompleter != null;

  /// 等待主界面数据响应
  Future<MainInterfaceData?> _waitForMainDataResponse({
    required UiPageContext expectedContext,
    required int requestId,
  }) async {
    // 等待已创建的响应等待器

    try {
      final responseData = await _responseCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _addLog("等待主界面数据响应超时");
          throw TimeoutException("响应超时", const Duration(seconds: 5));
        },
      );

      // 记录响应头摘要
      if (responseData.isNotEmpty) {
        final prefixLen = BleProtocol.guideResponsePrefix.length;
        final guides = responseData.length >= prefixLen
            ? responseData.sublist(0, prefixLen)
            : responseData;
        final lenField = responseData.length > prefixLen
            ? responseData[prefixLen]
            : -1;
        final cmd = responseData.length > prefixLen + 1
            ? responseData[prefixLen + 1]
            : -1;
        _addLog(
          "[主数据] 响应头: guides=${BleProtocol.toHexString(guides)} len=${lenField} cmd=0x${cmd.toRadixString(16).toUpperCase()} total=${responseData.length}",
        );
      }

      // 页面切换后不再处理该响应
      if (!_shouldAccept(expectedContext, requestId)) {
        _addLog("主界面数据响应已忽略（页面切换）");
        return null;
      }
      final result = BleProtocol.parseMainDataResponse(responseData);
      if (result != null) {
        _addLog("主界面数据解析成功");
        // 缓存并记录时间，用于实时界面展示
        latestMainData = result;
        lastMainDataAt = DateTime.now();
        notifyListeners();
      } else {
        _addLog("主界面数据解析失败");
      }
      return result;
    } catch (e) {
      _addLog("等待主界面数据响应异常: $e");
      return null;
    } finally {
      _responseCompleter = null;
      notifyListeners();
    }
  }

  /// 等待设置数据响应
  Future<SettingsData?> _waitForSettingsResponse({
    required UiPageContext expectedContext,
    required int requestId,
  }) async {
    // 等待已创建的响应等待器

    try {
      final responseData = await _responseCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _addLog("等待设置数据响应超时");
          throw TimeoutException("响应超时", const Duration(seconds: 5));
        },
      );
      if (responseData.isNotEmpty) {
        final prefixLen = BleProtocol.guideResponsePrefix.length;
        final guides = responseData.length >= prefixLen
            ? responseData.sublist(0, prefixLen)
            : responseData;
        final lenField = responseData.length > prefixLen
            ? responseData[prefixLen]
            : -1;
        final cmd = responseData.length > prefixLen + 1
            ? responseData[prefixLen + 1]
            : -1;
        _addLog(
          "[设置] 响应头: guides=${BleProtocol.toHexString(guides)} len=${lenField} cmd=0x${cmd.toRadixString(16).toUpperCase()} total=${responseData.length}",
        );
      }

      // 页面切换后不再处理该响应
      if (!_shouldAccept(expectedContext, requestId)) {
        _addLog("设置数据响应已忽略（页面切换）");
        return null;
      }
      final result = BleProtocol.parseSettingsResponse(responseData);
      if (result != null) {
        _addLog("设置数据解析成功");
        lastSettingsDataAt = DateTime.now();
      } else {
        _addLog("设置数据解析失败");
      }
      return result;
    } catch (e) {
      _addLog("等待设置数据响应异常: $e");
      return null;
    } finally {
      _responseCompleter = null;
      notifyListeners();
    }
  }

  /// 等待历史数据响应
  Future<HistoryData?> _waitForHistoryResponse({
    required UiPageContext expectedContext,
    required int requestId,
  }) async {
    // 等待已创建的响应等待器

    try {
      final responseData = await _responseCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _addLog("等待历史数据响应超时");
          throw TimeoutException("响应超时", const Duration(seconds: 5));
        },
      );
      if (responseData.isNotEmpty) {
        final prefixLen = BleProtocol.guideResponsePrefix.length;
        final guides = responseData.length >= prefixLen
            ? responseData.sublist(0, prefixLen)
            : responseData;
        final lenField = responseData.length > prefixLen
            ? responseData[prefixLen]
            : -1;
        final cmd = responseData.length > prefixLen + 1
            ? responseData[prefixLen + 1]
            : -1;
        _addLog(
          "[历史] 响应头: guides=${BleProtocol.toHexString(guides)} len=${lenField} cmd=0x${cmd.toRadixString(16).toUpperCase()} total=${responseData.length}",
        );
      }

      // 页面切换后不再处理该响应
      if (!_shouldAccept(expectedContext, requestId)) {
        _addLog("历史数据响应已忽略（页面切换）");
        return null;
      }
      final result = BleProtocol.parseHistoryResponse(responseData);
      if (result != null) {
        _addLog("历史数据解析成功");
        lastHistoryDataAt = DateTime.now();
      } else {
        _addLog("历史数据解析失败");
      }
      return result;
    } catch (e) {
      _addLog("等待历史数据响应异常: $e");
      return null;
    } finally {
      _responseCompleter = null;
      notifyListeners();
    }
  }

  /// 等待写入确认响应
  Future<bool> _waitForWriteAck({
    required UiPageContext expectedContext,
    required int requestId,
  }) async {
    // 等待已创建的响应等待器

    try {
      final responseData = await _responseCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _addLog("等待写入确认响应超时");
          throw TimeoutException("响应超时", const Duration(seconds: 5));
        },
      );
      if (responseData.isNotEmpty) {
        final prefixLen = BleProtocol.guideResponsePrefix.length;
        final guides = responseData.length >= prefixLen
            ? responseData.sublist(0, prefixLen)
            : responseData;
        final lenField = responseData.length > prefixLen
            ? responseData[prefixLen]
            : -1;
        final cmd = responseData.length > prefixLen + 1
            ? responseData[prefixLen + 1]
            : -1;
        _addLog(
          "[写入Ack] 响应头: guides=${BleProtocol.toHexString(guides)} len=${lenField} cmd=0x${cmd.toRadixString(16).toUpperCase()} total=${responseData.length}",
        );
      }

      // 完整校验ACK帧（前缀/长度/CRC/命令字），并读取状态码
      final statusCode = BleProtocol.parseSettingsAck(responseData);
      if (!_shouldAccept(expectedContext, requestId)) {
        _addLog("写入确认响应已忽略（页面切换）");
        return false;
      }
      if (statusCode == null) {
        _addLog("写入确认响应校验失败（前缀/长度/CRC/命令不匹配）");
        return false;
      }
      final success = statusCode == 0x00;
      _addLog(
        "写入${success ? '成功' : '失败'} (状态码: 0x${statusCode.toRadixString(16).toUpperCase()})",
      );
      return success;
    } catch (e) {
      _addLog("等待写入确认响应异常: $e");
      return false;
    } finally {
      _responseCompleter = null;
      notifyListeners();
    }
  }

  /// 更新连接状态
  void _updateState(BluetoothConnectionState state, String message) {
    _connectionState = state;
    _statusMessage = message;
    _addLog("状态更新: ${state.toString()} | ${message}");
    notifyListeners();
  }

  /// 仅更新状态消息，不改变连接状态（用于扫描等非连接操作）
  void _setStatus(String message) {
    _statusMessage = message;
    _addLog("状态更新(保持连接): ${_connectionState.toString()} | ${message}");
    notifyListeners();
  }

  /// 添加日志
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _logs.add("[$timestamp] $message");

    // 限制日志数量
    if (_logs.length > 100) {
      _logs.removeAt(0);
    }

    notifyListeners();

    // 调试输出
    if (kDebugMode) {
      print("BluetoothService: $message");
    }
  }

  /// 清空日志
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  /// 对外暴露调试日志接口
  void debugLog(String message) {
    _addLog(message);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
