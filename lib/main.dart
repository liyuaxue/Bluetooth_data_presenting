import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bluetooth_data_presenting/l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bluetooth_service.dart';
import 'ble_protocol.dart';
import 'widgets/rect_switch.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';

void main() {
  runApp(const SolarApp());
}

// 顶层格式化工具：统一给所有页面/方法使用
String _formatPowerW(num w) {
  final value = w.toDouble();
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(2)} kW';
  }
  return '${value.toStringAsFixed(1)} W';
}

String _formatEnergyWh(num wh) {
  final value = wh.toDouble();
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(2)} kWh';
  }
  return '${value.toStringAsFixed(1)} Wh';
}

String _formatScaled(
  num raw, {
  required num divider,
  required String unit,
  int fractionDigits = 1,
}) {
  final v = raw.toDouble() / divider;
  return '${v.toStringAsFixed(fractionDigits)} $unit';
}

String _formatTime(DateTime? t) {
  if (t == null) return '-';
  final s = t.toLocal().toString();
  return s.length >= 19 ? s.substring(0, 19) : s; // yyyy-MM-dd HH:mm:ss
}

class SolarApp extends StatelessWidget {
  const SolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh'),
              Locale('en'),
              Locale('de'),
              Locale('fr'),
              Locale('it'),
              Locale('es'),
            ],
            theme: themeManager.themeData, // 确保使用 themeManager 的主题
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}

// 全局：左侧标题/标签到列边框的水平内边距（可统一调节）
const double kLeftLabelPaddingX = 10.0;

class ColumnTelemetry {
  final double solarEnergyKWh;
  final double solarPowerW;
  final double solarVoltageV;
  final double solarMaxPowerW;
  final double solarMaxVoltageV; // 新增：太阳能板电压最大值
  final double batteryMaxV;
  final double batteryMinV;
  final double consumptionW;
  final int errorCount;

  const ColumnTelemetry({
    required this.solarEnergyKWh,
    required this.solarPowerW,
    required this.solarVoltageV,
    required this.solarMaxPowerW,
    required this.solarMaxVoltageV,
    required this.batteryMaxV,
    required this.batteryMinV,
    required this.consumptionW,
    required this.errorCount,
  });

  ColumnTelemetry copyWith({
    double? solarEnergyKWh,
    double? solarPowerW,
    double? solarVoltageV,
    double? solarMaxPowerW,
    double? solarMaxVoltageV,
    double? batteryMaxV,
    double? batteryMinV,
    double? consumptionW,
    int? errorCount,
  }) {
    return ColumnTelemetry(
      solarEnergyKWh: solarEnergyKWh ?? this.solarEnergyKWh,
      solarPowerW: solarPowerW ?? this.solarPowerW,
      solarVoltageV: solarVoltageV ?? this.solarVoltageV,
      solarMaxPowerW: solarMaxPowerW ?? this.solarMaxPowerW,
      solarMaxVoltageV: solarMaxVoltageV ?? this.solarMaxVoltageV,
      batteryMaxV: batteryMaxV ?? this.batteryMaxV,
      batteryMinV: batteryMinV ?? this.batteryMinV,
      consumptionW: consumptionW ?? this.consumptionW,
      errorCount: errorCount ?? this.errorCount,
    );
  }
}

class DataController extends ChangeNotifier {
  List<ColumnTelemetry> columns = List.generate(5, (i) {
    return ColumnTelemetry(
      solarEnergyKWh: 5.52 + i * 0.1,
      solarPowerW: 1159 + i * 10,
      solarVoltageV: 86.93 + i,
      solarMaxPowerW: 1210 + i * 5,
      solarMaxVoltageV: 86.93 + i,
      batteryMaxV: 54.2 - i * 0.2,
      batteryMinV: 48.7 - i * 0.2,
      consumptionW: 890 + i * 15,
      errorCount: i == 0 ? 1 : 0,
    );
  });

  double totalLifetimeKWh = 1215;
  double fromResetKWh = 1154;

  Timer? _mockTimer;
  final Random _rng = Random();

  DataController() {
    if (kIsWeb) {
      _startMockUpdates();
    }
  }

  // 将蓝牙报文解析到指定列（占位示例）
  void parseBluetoothPacket(int columnIndex, List<int> payload) {
    if (columnIndex < 0 || columnIndex >= columns.length) return;
    // TODO: 按协议解析 payload 字节，更新对应列的各字段
    // 例如：final parsedPower = ...;
    // columns[columnIndex] = columns[columnIndex].copyWith(solarPowerW: parsedPower, ...);
    // notifyListeners();
  }

  void _startMockUpdates() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      columns = List.generate(columns.length, (i) {
        final c = columns[i];
        final v = 80 + _rng.nextDouble() * 10; // 太阳能电压随机值
        return c.copyWith(
          solarPowerW: (1000 + _rng.nextInt(300)).toDouble(),
          solarVoltageV: v,
          solarMaxPowerW: 1200 + _rng.nextInt(100).toDouble(),
          solarMaxVoltageV: max(c.solarMaxVoltageV, v),
          batteryMaxV: 52 + _rng.nextDouble() * 3,
          batteryMinV: 47 + _rng.nextDouble() * 3,
          consumptionW: (700 + _rng.nextInt(400)).toDouble(),
          errorCount: _rng.nextDouble() < 0.1 ? 1 : 0,
          solarEnergyKWh: c.solarEnergyKWh + 0.01,
        );
      });
      totalLifetimeKWh += 0.02;
      fromResetKWh += 0.02;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const String _privacyPolicyUrl = 'http://gw.059.lifala.com.cn/';
  static const String _privacyPolicyFallbackHtml = '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>隐私政策 - SolarPV</title>
</head>
<body>
  <h1>隐私政策</h1>
  <p>本政策仅适用于东莞市三义科技有限公司提供的产品和服务及其延伸功能（以下简称“SolarPV”）。</p>
  <p>我们会在法律法规允许范围内收集和使用必要信息，用于提供服务、保障安全与改进体验。</p>
  <p>如需完整版本，请在网络可用时查看在线隐私政策页面。</p>
</body>
</html>
''';
  bool _privacyPolicyShownThisLaunch = false;

  // 顶部横幅消息（显示在抬头下方）
  String? _topMessage;
  Color _topMessageBg = const Color(0xFFE3F2FD);
  Color _topMessageFg = const Color(0xFF0D47A1);
  Timer? _topMessageTimer;

  void _showTopMessage(
    String message, {
    Color? background,
    Color? foreground,
    Duration duration = const Duration(seconds: 3),
  }) {
    _topMessageTimer?.cancel();
    setState(() {
      _topMessage = message;
      _topMessageBg = background ?? const Color(0xFFE3F2FD);
      _topMessageFg = foreground ?? const Color(0xFF0D47A1);
    });
    _topMessageTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _topMessage = null;
        });
      }
    });
  }

  late final DataController controller;
  late final BluetoothService bluetoothService;
  Timer? _pollTimer;
  Timer? _autoScanTimer;
  bool _pollingBusy = false;
  int _tabIndex = 0;
  String? _lastConnectedDeviceId;
  bool _disconnectAlertShown = false;
  final GlobalKey<TooltipState> _historyTitleTooltipKey =
      GlobalKey<TooltipState>();

  // 设置页表单状态
  // 根据协议 md：5 个电压设置项
  final TextEditingController _equalizingChargeCtrl = TextEditingController();
  final TextEditingController _boostChargeCtrl = TextEditingController();
  final TextEditingController _floatChargeCtrl = TextEditingController();
  final TextEditingController _chargeReturnCtrl = TextEditingController();
  final TextEditingController _overDischargeReturnCtrl =
      TextEditingController();
  final TextEditingController _overDischargeCtrl = TextEditingController();
  final TextEditingController _systemVersionCtrl = TextEditingController();
  int _modeSelection = 0;
  int _batteryType = 0;
  int _loadMode = 0;
  int _systemVersion = 0; // 只读展示
  int _reserved = 0; // 只读展示
  bool _settingsSubmitting = false; // 设置提交loading

  @override
  void initState() {
    super.initState();
    controller = DataController();
    controller.addListener(_onData);

    bluetoothService = BluetoothService();
    bluetoothService.addListener(_onBluetoothStateChanged);
    // 加载设备别名映射
    bluetoothService.loadDeviceAliases();
    // 启动后检测蓝牙是否开启，未开启则弹窗提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPrivacyPolicyLinkOnce();
      _checkBluetoothOnAtStartup();
    });
    // 启动后尝试自动连接：优先历史设备
    bluetoothService.autoConnectOnStartup();

    // 进入主页面后，每2秒轮询主数据（仅在已连接时触发），避免并发请求
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      // 仅在“实时数据”页（索引0）进行轮询；历史与设置页面不轮询
      if (_tabIndex != 0) return;
      if (!bluetoothService.isConnected) return;
      if (_pollingBusy) return;
      _pollingBusy = true;
      try {
        bluetoothService.debugLog('轮询主数据请求开始');
        await bluetoothService.requestMainData();
        bluetoothService.debugLog('轮询主数据请求结束');
        // 解析成功后，BluetoothService.latestMainData 会更新并通知监听者
      } catch (_) {}
      _pollingBusy = false;
    });

    // 自动定期扫描：未连接且未在扫描/连接中时，每35秒触发一次短扫描（10秒），并仅保留含目标服务的设备
    _autoScanTimer = Timer.periodic(const Duration(seconds: 35), (_) async {
      if (!mounted) return;
      final state = bluetoothService.connectionState;
      if (state == BluetoothConnectionState.disconnected) {
        try {
          // 定时自动尝试扫描并连接匹配设备（使用广播名过滤规则）
          await bluetoothService.scanAndConnect();
        } catch (_) {}
      }
    });
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  Future<void> _showPrivacyPolicyLinkOnce() async {
    if (_privacyPolicyShownThisLaunch || !mounted) return;
    _privacyPolicyShownThisLaunch = true;
    final privacyContentFuture = _fetchPrivacyPolicyContent();
    bool usingFallback = false;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 24,
              ),
              contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text('隐私政策'),
              content: SizedBox(
                width: MediaQuery.of(ctx).size.width * 0.9,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 460),
                  child: FutureBuilder<String>(
                    future: privacyContentFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      String html = _privacyPolicyFallbackHtml;
                      if (snapshot.hasData &&
                          (snapshot.data ?? '').trim().isNotEmpty) {
                        usingFallback = false;
                        html = snapshot.data!;
                      } else {
                        usingFallback = true;
                      }
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (usingFallback)
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '在线内容加载失败，当前显示本地兜底内容。\n链接：$_privacyPolicyUrl',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            Html(
                              data: html,
                              style: {
                                'html': Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(13),
                                  lineHeight: const LineHeight(1.35),
                                ),
                                'body': Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                ),
                                'h1': Style(
                                  fontSize: FontSize(18),
                                  margin: Margins.only(bottom: 8),
                                  lineHeight: const LineHeight(1.25),
                                ),
                                'h2': Style(
                                  fontSize: FontSize(16),
                                  margin: Margins.only(top: 10, bottom: 6),
                                  lineHeight: const LineHeight(1.25),
                                ),
                                'h3': Style(
                                  fontSize: FontSize(14),
                                  margin: Margins.only(top: 8, bottom: 4),
                                  lineHeight: const LineHeight(1.25),
                                ),
                                'p': Style(
                                  margin: Margins.only(bottom: 6),
                                  lineHeight: const LineHeight(1.35),
                                ),
                                'ul': Style(
                                  margin: Margins.only(bottom: 6),
                                  padding: HtmlPaddings.only(left: 14),
                                ),
                                'ol': Style(
                                  margin: Margins.only(bottom: 6),
                                  padding: HtmlPaddings.only(left: 14),
                                ),
                                'li': Style(
                                  margin: Margins.only(bottom: 4),
                                  lineHeight: const LineHeight(1.3),
                                ),
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await SystemNavigator.pop();
                  },
                  child: const Text('不同意并退出'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('同意并继续'),
                ),
              ],
            );
      },
    );
  }

  Future<String> _fetchPrivacyPolicyContent() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  Future<void> _checkBluetoothOnAtStartup() async {
    try {
      final on = await bluetoothService.isBluetoothOn();
      if (!on && mounted) {
        _showBluetoothEnableDialog();
      }
    } catch (_) {}
  }

  void _showBluetoothEnableDialog() {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.bluetoothUnavailable),
          content: Text(l.pleaseEnableBluetooth),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.closeAction),
            ),
            TextButton(
              onPressed: () async {
                await bluetoothService.turnOnBluetoothOnAndroid();
                Navigator.of(ctx).pop();
              },
              child: Text(l.turnOn),
            ),
          ],
        );
      },
    );
  }

  void _onBluetoothStateChanged() {
    final svc = bluetoothService;
    // 连接过程中，先清空设置表单，避免显示旧设备设置
    if (svc.connectionState == BluetoothConnectionState.connecting) {
      _clearSettingsForm();
    }
    // 断开连接时也清空设置表单
    if (svc.connectionState == BluetoothConnectionState.disconnected) {
      _clearSettingsForm();
    }
    // 连接成功后，如设备发生变化：
    if (svc.connectionState == BluetoothConnectionState.connected) {
      final newId = svc.connectedDeviceId;
      if (newId != null && newId != _lastConnectedDeviceId) {
        // 若当前在历史页，自动清空并拉取近30天历史
        if (_tabIndex == 1) {
          svc.clearHistoryCache();
          // 非阻塞触发拉取，界面会显示“正在拉取”状态
          svc.requestHistoryLastDays(days: 30);
        }
        _lastConnectedDeviceId = newId;
      }
    }
    if (svc.connectionState != BluetoothConnectionState.disconnected ||
        !svc.unexpectedDisconnected) {
      _disconnectAlertShown = false;
    }
    if (svc.connectionState == BluetoothConnectionState.disconnected &&
        svc.unexpectedDisconnected &&
        !_disconnectAlertShown) {
      _disconnectAlertShown = true;
      final l = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            title: Text(l.disconnectedStatus),
            content: Text(l.unexpectedDisconnectDialogMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l.closeAction),
              ),
            ],
          );
        },
      );
    }
    if (mounted) setState(() {});
  }

  // 清空设置表单内容（在连接新设备或断开时调用）
  void _clearSettingsForm() {
    _equalizingChargeCtrl.text = '';
    _boostChargeCtrl.text = '';
    _floatChargeCtrl.text = '';
    _chargeReturnCtrl.text = '';
    _overDischargeReturnCtrl.text = '';
    _overDischargeCtrl.text = '';
    _modeSelection = 0;
    _batteryType = 0;
    _loadMode = 0;
    _systemVersion = 0;
    _reserved = 0;
  }

  @override
  void dispose() {
    controller.removeListener(_onData);
    controller.dispose();

    bluetoothService.removeListener(_onBluetoothStateChanged);
    bluetoothService.dispose();
    _pollTimer?.cancel();
    _autoScanTimer?.cancel();
    _equalizingChargeCtrl.dispose();
    _boostChargeCtrl.dispose();
    _floatChargeCtrl.dispose();
    _chargeReturnCtrl.dispose();
    _overDischargeReturnCtrl.dispose();
    _overDischargeCtrl.dispose();
    _topMessageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final currentTheme = themeManager.currentTheme;

    return Scaffold(
      backgroundColor: currentTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: currentTheme.primaryColor,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _statusColor(bluetoothService.connectionState),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded( 
              child: Text(
                _localizedStatusText(AppLocalizations.of(context)!),
                style: TextStyle(color: currentTheme.textColor),
                overflow: TextOverflow.ellipsis, // 添加溢出处理
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          // 主题选择按钮
          IconButton(
            onPressed: _showThemeSelectionDialog,
            icon: const Icon(Icons.palette, color: Colors.white),
            tooltip: '选择主题颜色',
          ),
          TextButton.icon(
            onPressed: _openDevicePickerSheet,
            icon: const Icon(Icons.bluetooth, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.connectDevice,
              style: const TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Builder(
              builder: (_) {
                if (!bluetoothService.isConnected) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.notConnected,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: currentTheme.textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                final name = bluetoothService.connectedDeviceName ?? '-';
                final id = bluetoothService.connectedDeviceId ?? '-';
                final resolvedName = bluetoothService.resolveAlias(
                  id,
                  name,
                );
                final infoLine = resolvedName;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.deviceNameTitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          infoLine,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (_) {
            final page = () {
              switch (_tabIndex) {
                case 0:
                  return _buildRealtimePage();
                case 1:
                  return _buildHistoryPage();
                case 2:
                default:
                  return _buildSettingsPage();
              }
            }();
            return page;
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: currentTheme.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 22,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.white70,
          size: 20,
        ),
        type: BottomNavigationBarType.fixed,
        currentIndex: _tabIndex,
        onTap: (i) async {
          final prev = _tabIndex;
          bluetoothService.cancelPendingResponse();
          setState(() => _tabIndex = i);
          if (i == 1 && prev != 1) {
            if (!bluetoothService.isConnected) {
              _showTopMessage(
                AppLocalizations.of(context)!.pleaseConnectDevice,
                background: const Color(0xFFFFCDD2),
                foreground: const Color(0xFFB71C1C),
              );
              return;
            }
            bluetoothService.clearHistoryCache();
            try {
              await bluetoothService.requestHistoryLastDays(
                days: 30,
                context: UiPageContext.history,
              );
              if (mounted) {
                setState(() {});
              }
            } catch (_) {}
          }
          if (i == 2 && prev != 2) {
            if (!bluetoothService.isConnected) {
              _showTopMessage(
                AppLocalizations.of(context)!.pleaseConnectDevice,
                background: const Color(0xFFFFCDD2),
                foreground: const Color(0xFFB71C1C),
              );
              return;
            }
            try {
              final d = await bluetoothService.requestSettingsData(
                context: UiPageContext.settings,
              );
              if (d != null) {
                _populateSettingsForm(d);
                if (mounted) {
                  setState(() {});
                }
              }
            } catch (_) {}
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.speed),
            label: AppLocalizations.of(context)!.navRealtime,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: AppLocalizations.of(context)!.navHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.navSettings,
          ),
        ],
      ),
    );
  }

  // AppBar 状态指示颜色
  Color _statusColor(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.connected:
        return Colors.green;
      case BluetoothConnectionState.connecting:
      case BluetoothConnectionState.scanning:
        return Colors.orange;
      case BluetoothConnectionState.error:
        return Colors.red;
      case BluetoothConnectionState.disconnected:
      default:
        return Colors.grey;
    }
  }

  String _localizedStatusText(AppLocalizations l) {
    final msg = bluetoothService.statusMessage;
    final state = bluetoothService.connectionState;

    if (msg.contains('连接失败')) {
      final idx = msg.indexOf(':');
      final err = idx >= 0 ? msg.substring(idx + 1).trim() : '';
      return l.connectionFailed(err.isEmpty ? '-' : err);
    }
    if (msg.contains('扫描失败')) {
      final idx = msg.indexOf(':');
      final err = idx >= 0 ? msg.substring(idx + 1).trim() : '';
      return l.scanFailed(err.isEmpty ? '-' : err);
    }
    if (msg.startsWith('正在连接')) {
      final name = msg.replaceFirst('正在连接', '').replaceAll('...', '').trim();
      final pure = name.startsWith(' ') ? name.substring(1) : name;
      return l.connectingTo(pure.isEmpty ? '-' : pure);
    }

    switch (state) {
      case BluetoothConnectionState.scanning:
        if (msg.contains('扫描结束')) return l.scanEnded;
        if (msg.contains('已停止扫描')) return l.scanStopped;
        return l.scanningInProgress;
      case BluetoothConnectionState.connecting:
        return l.connectingTo('-');
      case BluetoothConnectionState.connected:
        return l.connectedStatus;
      case BluetoothConnectionState.disconnected:
        if (bluetoothService.unexpectedDisconnected)
          return l.unexpectedDisconnectStatus;
        if (msg.contains('已准备扫描')) return l.scanReady;
        return l.disconnectedStatus;
      case BluetoothConnectionState.error:
        if (msg.contains('蓝牙不可用')) return l.bluetoothUnavailable;
        if (msg.contains('请开启蓝牙')) return l.pleaseEnableBluetooth;
        if (msg.contains('权限不足')) return l.insufficientPermissions;
        if (msg.contains('未找到设备')) return l.notFoundDevice;
        return msg;
    }
  }

  void _showThemeSelectionDialog() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, // 限制最大高度
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '选择主题颜色',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded( // 使用 Expanded 确保网格在可用空间内
                    child: _buildThemeSelectionGrid(themeManager),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建主题选择网格
  Widget _buildThemeSelectionGrid(ThemeManager themeManager) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // 调整宽高比
      ),
      itemCount: themeManager.themes.length,
      itemBuilder: (context, index) {
        return _buildThemeOptionDialog(index, themeManager);
      },
    );
  }

  // 构建单个主题选项（弹窗版本）
  Widget _buildThemeOptionDialog(int index, ThemeManager themeManager) {
    final theme = themeManager.themes[index];
    final isSelected = themeManager.selectedThemeIndex == index;

    return GestureDetector(
      onTap: () {
        themeManager.setTheme(index);
        Navigator.of(context).pop();
        _showTopMessage(
          '已切换到${theme.name}',
          background: theme.primaryColor.withOpacity(0.2),
          foreground: theme.textColor,
        );
      },
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 100, // 限制最大高度
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主题颜色预览
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.textColor.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 8),
            // 主题名称
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                theme.name,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // 选中指示器
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  // 打开设备选择弹层
  void _openDevicePickerSheet() {
    // 打开弹层时自动开始扫描
    bluetoothService.discoverDevices();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFDE7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedBuilder(
            animation: bluetoothService,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bluetooth, color: Color(0xFF0D47A1)),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.chooseDeviceToConnect,
                        style: const TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // TextButton(
                      //   onPressed: _exportLogs,
                      //   child: Text(AppLocalizations.of(context)!.exportLogs, style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 12)),
                      // ),
                      const SizedBox(width: 8),
                      // 移除顶部“清除别名”按钮
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            _localizedStatusText(AppLocalizations.of(context)!),
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (bluetoothService.connectionState ==
                                  BluetoothConnectionState.error &&
                              bluetoothService.statusMessage.contains('权限不足'))
                            TextButton(
                              onPressed: () async {
                                await openAppSettings();
                              },
                              child: const Text(
                                '打开设置',
                                style: TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => bluetoothService.discoverDevices(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF90CAF9),
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.startScan,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      // 移除“停止扫描”按钮
                      // const SizedBox(width: 8),
                      // Text(
                      //   AppLocalizations.of(context)!.deviceNameFilterLabel,
                      //   style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 12),
                      // ),
                      // const SizedBox(width: 6),
                      // Transform.scale(
                      //   scale: 0.9,
                      //   child: Switch.adaptive(
                      //     value: bluetoothService.filterEnabled,
                      //     onChanged: (v) => bluetoothService.setFilterEnabled(v),
                      //     activeColor: const Color(0xFF64B5F6),
                      //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //   ),
                      // ),
                      const SizedBox(width: 8),
                      if (bluetoothService.isConnected)
                        ElevatedButton(
                          onPressed: () async {
                            await bluetoothService.disconnect();
                            if (mounted) Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.disconnect,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        AppLocalizations.of(context)!.discoveredCount(
                          bluetoothService.discoveredDevices.length,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          await bluetoothService.clearAllAliases();
                          if (mounted) {
                            _showTopMessage(
                              AppLocalizations.of(context)!.aliasesCleared,
                              background: const Color(0xFFA5D6A7),
                              foreground: const Color(0xFF1B5E20),
                            );
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.clearAliases,
                          style: const TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: Builder(
                      builder: (ctx) {
                        final discovered = bluetoothService.discoveredDevices;
                        final cid = bluetoothService.connectedDeviceId;
                        final hasConnected =
                            cid != null &&
                            discovered.any(
                              (r) => r.device.remoteId.toString() == cid,
                            );
                        final showConnectedRow =
                            bluetoothService.isConnected &&
                            cid != null &&
                            !hasConnected;
                        if (discovered.isEmpty && !showConnectedRow) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noDevicesTip,
                              style: const TextStyle(
                                color: Color(0xFF0D47A1),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        final total =
                            discovered.length + (showConnectedRow ? 1 : 0);
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: total,
                          itemBuilder: (context, index) {
                            // 额外在列表顶部插入“当前已连接设备”一行（若其不在扫描结果中）
                            if (showConnectedRow && index == 0) {
                              final remoteIdStr = cid!;
                              final fallbackName =
                                  bluetoothService.connectedDeviceName ??
                                  AppLocalizations.of(context)!.unnamedDevice;
                              final displayName = bluetoothService.resolveAlias(
                                remoteIdStr,
                                fallbackName,
                              );
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF2EB872),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                              color: Color(0xFF0D47A1),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.remoteIdLabel(remoteIdStr),
                                            style: const TextStyle(
                                              color: Color(0xFF455A64),
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xFF0D47A1),
                                      ),
                                      tooltip: AppLocalizations.of(
                                        context,
                                      )!.editNameTooltip,
                                      onPressed: () async {
                                        final initial =
                                            bluetoothService.getAlias(
                                              remoteIdStr,
                                            ) ??
                                            fallbackName;
                                        final newAlias =
                                            await showDialog<String>(
                                              context: context,
                                              builder: (ctx) {
                                                final controller =
                                                    TextEditingController(
                                                      text: initial,
                                                    );
                                                return AlertDialog(
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.editDeviceNameTitle,
                                                  ),
                                                  content: TextField(
                                                    controller: controller,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.aliasInputHint,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            ctx,
                                                          ).pop(),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.cancelAction,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx).pop(
                                                            controller.text
                                                                .trim(),
                                                          ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.saveAction,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                        if (newAlias != null) {
                                          await bluetoothService.setDeviceAlias(
                                            remoteIdStr,
                                            newAlias,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2EB872,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF0D47A1,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.connectedStatus,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final idx = showConnectedRow ? index - 1 : index;
                            final result = discovered[idx];
                            final device = result.device;
                            final adv = result.advertisementData;
                            final localName = adv.advName.isNotEmpty
                                ? adv.advName
                                : adv.localName;
                            final serviceUuids = adv.serviceUuids
                                .map((g) => g.toString())
                                .join(',');
                            final hasTargetService = false; // 不再基于固定UUID检查目标服务
                            final remoteIdStr = device.remoteId.toString();
                            // 显示名优先使用“已连接设备名”(connectedDeviceName)（当此项为当前已连接设备时），否则回退为设备名(platformName)
                            final useConnectedName =
                                bluetoothService.connectedDeviceId ==
                                    remoteIdStr &&
                                (bluetoothService.connectedDeviceName != null &&
                                    bluetoothService
                                        .connectedDeviceName!
                                        .isNotEmpty);
                            final fallbackName = useConnectedName
                                ? bluetoothService.connectedDeviceName!
                                : (device.platformName.isNotEmpty
                                      ? device.platformName
                                      : AppLocalizations.of(
                                          context,
                                        )!.unnamedDevice);
                            final displayName = bluetoothService.resolveAlias(
                              remoteIdStr,
                              fallbackName,
                            );
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: hasTargetService
                                      ? const Color(0xFF2EB872)
                                      : const Color(0xFF90CAF9),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: const TextStyle(
                                            color: Color(0xFF0D47A1),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.advertisedNameLabel(
                                            localName.isEmpty ? '-' : localName,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF455A64),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.remoteIdLabel(
                                            device.remoteId.toString(),
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF455A64),
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.rssiServicesLabel(
                                            result.rssi,
                                            serviceUuids.isEmpty
                                                ? '-'
                                                : serviceUuids,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF455A64),
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (hasTargetService) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.matchTargetService,
                                            style: const TextStyle(
                                              color: Color(0xFF2EB872),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF0D47A1),
                                        ),
                                        tooltip: AppLocalizations.of(
                                          context,
                                        )!.editNameTooltip,
                                        onPressed: () async {
                                          final initial =
                                              bluetoothService.getAlias(
                                                remoteIdStr,
                                              ) ??
                                              fallbackName;
                                          final newAlias =
                                              await showDialog<String>(
                                                context: context,
                                                builder: (ctx) {
                                                  final controller =
                                                      TextEditingController(
                                                        text: initial,
                                                      );
                                                  return AlertDialog(
                                                    title: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.editDeviceNameTitle,
                                                    ),
                                                    content: TextField(
                                                      controller: controller,
                                                      decoration: InputDecoration(
                                                        hintText:
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.aliasInputHint,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.cancelAction,
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(
                                                              controller.text
                                                                  .trim(),
                                                            ),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.saveAction,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                          if (newAlias != null) {
                                            await bluetoothService
                                                .setDeviceAlias(
                                                  remoteIdStr,
                                                  newAlias,
                                                );
                                          }
                                        },
                                      ),
                                      Builder(
                                        builder: (ctx) {
                                          final isConnectedItem =
                                              bluetoothService
                                                  .connectedDeviceId ==
                                              remoteIdStr;
                                          final isConnectingItem =
                                              bluetoothService
                                                  .connectingRemoteId ==
                                              remoteIdStr;
                                          final disabled =
                                              isConnectedItem ||
                                              isConnectingItem;
                                          final bg = isConnectedItem
                                              ? const Color(
                                                  0xFF2EB872,
                                                ) // 绿色，表示已连接
                                              : const Color(0xFF64B5F6);
                                          final label = isConnectedItem
                                              ? AppLocalizations.of(
                                                  ctx,
                                                )!.connectedStatus
                                              : AppLocalizations.of(
                                                  ctx,
                                                )!.connectAction;
                                          return ElevatedButton(
                                            onPressed: disabled
                                                ? null
                                                : () async {
                                                    await bluetoothService
                                                        .connectToRemoteId(
                                                          device.remoteId
                                                              .toString(),
                                                        );
                                                    if (mounted)
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: bg,
                                              foregroundColor: const Color(
                                                0xFF0D47A1,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                            ),
                                            child: Text(
                                              label,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _exportLogs() async {
    final logs = bluetoothService.logs;
    if (logs.isEmpty) {
      if (mounted) {
        _showTopMessage(AppLocalizations.of(context)!.noLogsToExport);
      }
      return;
    }
    final content = logs.join('\n');
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) {
      _showTopMessage(
        AppLocalizations.of(context)!.logsCopiedToClipboard(logs.length),
        background: const Color(0xFFA5D6A7),
        foreground: const Color(0xFF1B5E20),
      );
    }
  }

  Widget _buildRealtimePage() {
    final themeManager = Provider.of<ThemeManager>(context);
    final currentTheme = themeManager.currentTheme;

    return SafeArea(
      // 添加 SafeArea
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: currentTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: currentTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (_) {
                      final d = bluetoothService.latestMainData;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(
                            icon: Icons.wb_sunny,
                            title: AppLocalizations.of(
                              context,
                            )!.sectionSolarPanel,
                            color: currentTheme.primaryColor, // 使用动态颜色
                            iconSize: 24,
                            titleFontSize: 16,
                          ),
                          const SizedBox(height: 4),
                          _twoColumnMetrics([
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.power,
                              value: d != null
                                  ? _formatPowerW(d.solarPowerW)
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.voltage,
                              value: d != null
                                  ? _formatScaled(
                                      d.solarVoltageV,
                                      divider: 1,
                                      unit: 'V',
                                      fractionDigits: 1,
                                    )
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.current,
                              value: d != null
                                  ? _formatScaled(
                                      d.solarCurrentA,
                                      divider: 1,
                                      unit: 'A',
                                      fractionDigits: 1,
                                    )
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(
                                context,
                              )!.todaysSolarEnergy,
                              value: d != null
                                  ? _formatEnergyWh(d.todaysSolarEnergyWh)
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                          ]),
                          GreenStripeDivider(color: currentTheme.primaryColor),
                          SectionLabel(
                            icon: Icons.battery_full,
                            title: AppLocalizations.of(context)!.sectionBattery,
                            color: currentTheme.primaryColor, // 使用动态颜色
                            iconSize: 24,
                            titleFontSize: 16,
                          ),
                          const SizedBox(height: 4),
                          _twoColumnMetrics([
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.voltage,
                              value: d != null
                                  ? _formatScaled(
                                      d.batteryVoltageV,
                                      divider: 1,
                                      unit: 'V',
                                      fractionDigits: 1,
                                    )
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.current,
                              value: d != null
                                  ? _formatScaled(
                                      d.batteryCurrentA,
                                      divider: 1,
                                      unit: 'A',
                                      fractionDigits: 1,
                                    )
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.temperature,
                              value: d != null
                                  ? _formatScaled(
                                      d.batteryTemperatureC,
                                      divider: 1,
                                      unit: '°C',
                                      fractionDigits: 1,
                                    )
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(
                                context,
                              )!.todaysBatteryCharge,
                              value: d != null
                                  ? _formatScaled(
                                      d.todaysBatteryChargeAh,
                                      divider: 1,
                                      unit: 'Ah',
                                      fractionDigits: 1,
                                    )
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                          ]),
                          GreenStripeDivider(color: currentTheme.primaryColor),
                          Row(
                            children: [
                              Expanded(
                                child: SectionLabel(
                                  icon: Icons.outlet,
                                  title: AppLocalizations.of(
                                    context,
                                  )!.sectionLoad,
                                  color: currentTheme.primaryColor, // 使用动态颜色
                                  iconSize: 24,
                                  titleFontSize: 16,
                                ),
                              ),
                              RectSwitch(
                                value: d?.loadSwitchOn ?? false,
                                enabled:
                                    bluetoothService.isConnected && d != null,
                                offLabel: AppLocalizations.of(context)!.turnOff,
                                onLabel: AppLocalizations.of(context)!.turnOn,
                                width: 92,
                                height: 28,
                                activeTrackColor: currentTheme.primaryColor,
                                inactiveTrackColor: const Color(0xFFB0BEC5),
                                onChanged:
                                    !(bluetoothService.isConnected && d != null)
                                    ? null
                                    : (bool next) async {
                                        final ok = await bluetoothService
                                            .setLoadSwitch(next);
                                        if (mounted) {
                                          if (!ok) {
                                            _showTopMessage(
                                              AppLocalizations.of(
                                                context,
                                              )!.sendFailed,
                                              background: const Color(
                                                0xFFFFCDD2,
                                              ),
                                              foreground: const Color(
                                                0xFFB71C1C,
                                              ),
                                            );
                                          }
                                          setState(() {});
                                        }
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _twoColumnMetrics([
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.current,
                              value: d != null
                                  ? _formatScaled(
                                      d.loadCurrentA,
                                      divider: 1,
                                      unit: 'A',
                                      fractionDigits: 1,
                                    )
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(context)!.power,
                              value: d != null
                                  ? _formatPowerW(d.loadPowerW)
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                            InlineMetricRow(
                              label: AppLocalizations.of(
                                context,
                              )!.todaysOutputEnergy,
                              value: d != null
                                  ? _formatEnergyWh(d.todaysOutputEnergyWh)
                                  : '',
                              textColor: currentTheme.textColor,
                            ),
                          ]),
                          const SizedBox(height: 6),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 指标列表：改为单列多行，并靠左对齐
  Widget _twoColumnMetrics(List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          items[i],
          if (i != items.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _buildHistoryPage() {
    final themeManager = Provider.of<ThemeManager>(context);
    final currentTheme = themeManager.currentTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox.shrink(),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: bluetoothService,
              builder: (context, _) {
                final svc = bluetoothService;
                // 移除历史拉取过程中的抬头"正在拉取数据"提示
                if (svc.isHistoryPulling) {
                  return const SizedBox.shrink();
                }
                // 不完整且超时，提示重试
                final expected = svc.historyPullExpectedDays;
                final got = svc.latestHistoryDays.length;
                final startedAt = svc.historyPullStartAt;
                if (startedAt != null && expected > 0) {
                  final threshold = Duration(seconds: expected * 5);
                  if (DateTime.now().difference(startedAt) > threshold &&
                      got < expected) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.incompletePullTip,
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: currentTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: currentTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (bluetoothService.latestHistoryDays.isNotEmpty)
                    _buildHistoryColumns(bluetoothService.latestHistoryDays)
                  else
                    _buildHistoryColumns(const <HistoryData>[]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    final themeManager = Provider.of<ThemeManager>(context);
    final currentTheme = themeManager.currentTheme;

    return SafeArea(
      // 添加 SafeArea
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: currentTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // 表单：基础枚举（单列靠左）
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SettingsDropdown(
                              label: AppLocalizations.of(
                                context,
                              )!.modeSelection,
                              value: _modeSelection,
                              options: const [0, 1, 2, 3, 4],
                              optionTexts: [
                                AppLocalizations.of(context)!.modeAuto,
                                AppLocalizations.of(context)!.mode12V,
                                AppLocalizations.of(context)!.mode24V,
                                AppLocalizations.of(context)!.mode48V,
                                AppLocalizations.of(context)!.mode96V,
                              ],
                              onChanged: (v) =>
                                  setState(() => _modeSelection = v ?? 0),
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                            _SettingsDropdown(
                              label: AppLocalizations.of(context)!.batteryType,
                              value: _batteryType,
                              options: const [0, 1, 2, 3, 4, 5],
                              optionTexts: [
                                AppLocalizations.of(context)!.batterySLD,
                                AppLocalizations.of(context)!.batteryGLE,
                                AppLocalizations.of(context)!.batteryFLD,
                                AppLocalizations.of(context)!.batteryLiFePO4,
                                AppLocalizations.of(context)!.batteryUSE,
                                AppLocalizations.of(context)!.batteryUSELI,
                              ],
                              onChanged: (v) =>
                                  setState(() => _batteryType = v ?? 0),
                              textColor: currentTheme.textColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SettingsDropdown(
                              label: AppLocalizations.of(context)!.loadMode,
                              value: _loadMode,
                              options: const [
                                0,
                                1,
                                2,
                                3,
                                4,
                                5,
                                6,
                                7,
                                8,
                                9,
                                10,
                                11,
                                12,
                                13,
                                14,
                                15,
                                17,
                              ],
                              optionTexts: [
                                '${AppLocalizations.of(context)!.loadLightControl}(0)',
                                for (int n = 1; n <= 14; n++)
                                  AppLocalizations.of(
                                    context,
                                  )!.lightControlTimed(n),
                                '${AppLocalizations.of(context)!.loadAlwaysOn}(15)',
                                '${AppLocalizations.of(context)!.loadManual}(17)',
                              ],
                              onChanged: (v) =>
                                  setState(() => _loadMode = v ?? 0),
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 表单：电压参数（单列靠左，单位V）
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SettingsNumberField(
                              label: AppLocalizations.of(
                                context,
                              )!.equalizingChargeV,
                              controller: _equalizingChargeCtrl,
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                            _SettingsNumberField(
                              label: AppLocalizations.of(context)!.boostChargeV,
                              controller: _boostChargeCtrl,
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                            _SettingsNumberField(
                              label: AppLocalizations.of(context)!.floatChargeV,
                              controller: _floatChargeCtrl,
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                            _SettingsNumberField(
                              label: AppLocalizations.of(
                                context,
                              )!.chargeReturnV,
                              controller: _chargeReturnCtrl,
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                            _SettingsNumberField(
                              label: AppLocalizations.of(
                                context,
                              )!.overDischargeReturnV,
                              controller: _overDischargeReturnCtrl,
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                            _SettingsNumberField(
                              label: AppLocalizations.of(
                                context,
                              )!.overDischargeV,
                              controller: _overDischargeCtrl,
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 8),
                            _SettingsVersionField(
                              label: AppLocalizations.of(
                                context,
                              )!.systemVersion,
                              controller: _systemVersionCtrl,
                              textColor: currentTheme.textColor,
                            ),
                            const SizedBox(height: 16),
                            // 底部操作按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (!bluetoothService.isConnected) {
                                          _showTopMessage(
                                            AppLocalizations.of(
                                              context,
                                            )!.pleaseConnectDevice,
                                            background: const Color(0xFFFFCDD2),
                                            foreground: const Color(0xFFB71C1C),
                                          );
                                          return;
                                        }
                                        final d = await bluetoothService
                                            .requestSettingsData();
                                        if (d != null) {
                                          _populateSettingsForm(d);
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        } else {
                                          if (mounted) {
                                            _showTopMessage(
                                              AppLocalizations.of(
                                                context,
                                              )!.readFailedOrTimeout,
                                              background: const Color(
                                                0xFFFFCDD2,
                                              ),
                                              foreground: const Color(
                                                0xFFB71C1C,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            currentTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.readSettings,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: _settingsSubmitting
                                          ? null
                                          : () async {
                                              if (!bluetoothService
                                                  .isConnected) {
                                                _showTopMessage(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.pleaseConnectDevice,
                                                  background: const Color(
                                                    0xFFFFCDD2,
                                                  ),
                                                  foreground: const Color(
                                                    0xFFB71C1C,
                                                  ),
                                                );
                                                return;
                                              }
                                              setState(
                                                () =>
                                                    _settingsSubmitting = true,
                                              );
                                              _pollingBusy = true;
                                              final settings =
                                                  _collectSettingsFromForm();
                                              final success =
                                                  await bluetoothService
                                                      .writeSettingsData(
                                                        settings,
                                                      );
                                              if (mounted) {
                                                _showTopMessage(
                                                  success
                                                      ? AppLocalizations.of(
                                                          context,
                                                        )!.settingsWriteSuccess
                                                      : AppLocalizations.of(
                                                          context,
                                                        )!.settingsWriteFailedOrTimeout,
                                                  background: success
                                                      ? const Color(0xFFA5D6A7)
                                                      : const Color(0xFFFFCDD2),
                                                  foreground: success
                                                      ? const Color(0xFF1B5E20)
                                                      : const Color(0xFFB71C1C),
                                                );
                                              }
                                              _pollingBusy = false;
                                              if (mounted)
                                                setState(
                                                  () => _settingsSubmitting =
                                                      false,
                                                );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: _settingsSubmitting
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.submitSettings,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.submitSettings,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 历史数据列视图：每天一列，风格与实时页面数据相似
  Widget _buildHistoryColumns(List<HistoryData> history) {
    final sorted = [...history];
    sorted.sort((a, b) => a.dayOffset.compareTo(b.dayOffset));
    final Map<int, HistoryData> byDay = {
      for (final h in sorted) h.dayOffset: h,
    };
    // 动态按当前收到的最大天数偏移生成列（右侧最大列为当前最大天数）
    final bool noData = byDay.isEmpty;
    final int maxOffset = noData
        ? 0
        : byDay.keys.reduce((a, b) => a > b ? a : b);
    final List<int> displayOffsets = noData
        ? <int>[]
        : List.generate(maxOffset + 1, (i) => i);
    Color _bgForCol(int i) =>
        i.isEven ? const Color(0xFFE3F2FD) : const Color(0xFFEBF5FF);
    final l = AppLocalizations.of(context)!;
    // 累计发电量（来源任意一天的总发电量字段）：无需取最大或求和
    final double? cumulativeTotalGenWh = byDay.isEmpty
        ? null
        : (byDay[0]?.totalGenerationWh ?? sorted.first.totalGenerationWh);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.history30DaysColumnsTitle,
            style: const TextStyle(
              color: Color(0xFF0D47A1),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧固定列（无数据时仅显示该标题列）
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期左列
                  Table(
                    border: const TableBorder(
                      horizontalInside: BorderSide.none,
                      verticalInside: BorderSide.none,
                    ),
                    columnWidths: {0: FixedColumnWidth(95)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [LabelCell(text: l.dayOffset)]),
                    ],
                  ),
                  // 太阳能板标题左列
                  Table(
                    border: const TableBorder(),
                    columnWidths: {0: FixedColumnWidth(95)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          SectionHeaderCell(
                            icon: Icons.wb_sunny,
                            title: l.sectionSolarPanel,
                            color: const Color(0xFFFFD54F),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // 太阳能板数据左列（最大电压、最大功率、发电量）
                  Table(
                    border: const TableBorder(),
                    columnWidths: {0: FixedColumnWidth(95)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [LabelCell(text: l.voltageMax)]),
                      TableRow(children: [LabelCell(text: l.maxPower)]),
                      TableRow(children: [LabelCell(text: l.powerGeneration)]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 电池标题左列
                  Table(
                    border: const TableBorder(),
                    columnWidths: {0: FixedColumnWidth(95)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          SectionHeaderCell(
                            icon: Icons.bolt,
                            title: l.sectionBattery,
                            color: const Color(0xFF64B5F6),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // 电池数据左列（最大电压、最小电压、充电量）
                  Table(
                    border: const TableBorder(),
                    columnWidths: {0: FixedColumnWidth(95)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [LabelCell(text: l.voltageMax)]),
                      TableRow(children: [LabelCell(text: l.voltageMin)]),
                      TableRow(
                        children: [LabelCell(text: l.todaysBatteryCharge)],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 负载标题与数据左列（负载消耗、警告）
                  Table(
                    border: const TableBorder(),
                    columnWidths: {0: FixedColumnWidth(95)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          SectionHeaderCell(
                            icon: Icons.outlet,
                            title: l.sectionLoad,
                            color: const Color(0xFF80CBC4),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Table(
                    border: const TableBorder(),
                    columnWidths: {0: FixedColumnWidth(95)},
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [LabelCell(text: l.loadConsumption)]),
                      TableRow(children: [LabelCell(text: l.errorCount)]),
                    ],
                  ),
                ],
              ),
              if (!noData) const SizedBox(width: 8),
              // 右侧可横向滚动的数据列（无数据时不显示）
              if (!noData)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 日期右侧值
                        Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide.none,
                            verticalInside: BorderSide.none,
                          ),
                          defaultColumnWidth: const FixedColumnWidth(90),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.daysAgoLabel(displayOffsets[i]),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        // 太阳能板标题右侧占位
                        Table(
                          border: const TableBorder(),
                          defaultColumnWidth: const FixedColumnWidth(90),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              children: [
                                for (int i = 0; i < sorted.length; i++)
                                  const SpacerCell(),
                              ],
                            ),
                          ],
                        ),
                        // 太阳能板数据右侧值（最大电压、最大功率、发电量）
                        Table(
                          border: const TableBorder(),
                          defaultColumnWidth: const FixedColumnWidth(90),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : _formatScaled(
                                            byDay[displayOffsets[i]]!
                                                .solarMaxVoltageV,
                                            divider: 1,
                                            unit: 'V',
                                            fractionDigits: 1,
                                          ),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : _formatPowerW(
                                            byDay[displayOffsets[i]]!
                                                .solarMaxPowerW,
                                          ),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : _formatEnergyWh(
                                            byDay[displayOffsets[i]]!
                                                .solarEnergyWh,
                                          ),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 电池标题右侧占位
                        Table(
                          border: const TableBorder(),
                          defaultColumnWidth: const FixedColumnWidth(90),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              children: [
                                for (int i = 0; i < sorted.length; i++)
                                  const SpacerCell(),
                              ],
                            ),
                          ],
                        ),
                        // 电池数据右侧值（最大电压、最小电压、充电量）
                        Table(
                          border: const TableBorder(),
                          defaultColumnWidth: const FixedColumnWidth(90),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : _formatScaled(
                                            byDay[displayOffsets[i]]!
                                                .batteryMaxVoltageV,
                                            divider: 1,
                                            unit: 'V',
                                            fractionDigits: 1,
                                          ),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : _formatScaled(
                                            byDay[displayOffsets[i]]!
                                                .batteryMinVoltageV,
                                            divider: 1,
                                            unit: 'V',
                                            fractionDigits: 1,
                                          ),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : _formatEnergyWh(
                                            byDay[displayOffsets[i]]!
                                                .batteryChargeWh,
                                          ),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 负载标题右侧占位
                        Table(
                          border: const TableBorder(),
                          defaultColumnWidth: const FixedColumnWidth(90),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              children: [
                                for (int i = 0; i < sorted.length; i++)
                                  const SpacerCell(),
                              ],
                            ),
                          ],
                        ),
                        // 负载数据右侧值（负载消耗、警告）
                        Table(
                          border: const TableBorder(),
                          defaultColumnWidth: const FixedColumnWidth(90),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : _formatEnergyWh(
                                            byDay[displayOffsets[i]]!
                                                .loadConsumptionWh,
                                          ),
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                            TableRow(
                              children: [
                                for (int i = 0; i < displayOffsets.length; i++)
                                  ValueCell(
                                    text: (byDay[displayOffsets[i]] == null)
                                        ? ''
                                        : '${byDay[displayOffsets[i]]!.errorCount}',
                                    backgroundColor: _bgForCol(i),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 表格下方：累计发电量 + 清除历史按钮（按钮黄色，字体黑色）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l.cumulativePowerGeneration}: ${cumulativeTotalGenWh == null ? '—' : _formatEnergyWh(cumulativeTotalGenWh)}',
                style: const TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final ok = await bluetoothService.clearHistoryOnDevice();
                  if (ok) {
                    // 清除历史后不再自动拉取数据，保持空状态，等待用户手动拉取
                  }
                  if (mounted) setState(() {});
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 28),
                ),
                child: Text(
                  AppLocalizations.of(context)!.clearHistory,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 将 SettingsData 映射到表单
  void _populateSettingsForm(SettingsData d) {
    _modeSelection = d.modeSelection;
    _batteryType = d.batteryType;
    _equalizingChargeCtrl.text = d.equalizingChargeV.toStringAsFixed(1);
    _boostChargeCtrl.text = d.boostChargeV.toStringAsFixed(1);
    _floatChargeCtrl.text = d.floatChargeV.toStringAsFixed(1);
    _chargeReturnCtrl.text = d.chargeReturnV.toStringAsFixed(1);
    _overDischargeReturnCtrl.text = d.overDischargeReturnV.toStringAsFixed(1);
    _overDischargeCtrl.text = d.overDischargeV.toStringAsFixed(1);
    _loadMode = d.loadMode;
    _systemVersion = d.systemVersion;
    _systemVersionCtrl.text = d.systemVersion.toString();
    _reserved = d.reserved;
  }

  // 从表单采集 SettingsData
  SettingsData _collectSettingsFromForm() {
    double _parse(String s) => double.tryParse(s.trim()) ?? 0.0;
    final int parsedVersion =
        int.tryParse(_systemVersionCtrl.text.trim()) ?? _systemVersion;
    return SettingsData(
      modeSelection: _modeSelection,
      batteryType: _batteryType,
      equalizingChargeV: _parse(_equalizingChargeCtrl.text),
      boostChargeV: _parse(_boostChargeCtrl.text),
      floatChargeV: _parse(_floatChargeCtrl.text),
      chargeReturnV: _parse(_chargeReturnCtrl.text),
      overDischargeReturnV: _parse(_overDischargeReturnCtrl.text),
      overDischargeV: _parse(_overDischargeCtrl.text),
      loadMode: _loadMode,
      systemVersion: parsedVersion,
      reserved: _reserved,
    );
  }

  // 显示格式化：功率（W/kW 自动切换）
  String _formatPowerW(num w) {
    final value = w.toDouble();
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)} kW';
    }
    return '${value.toStringAsFixed(1)} W';
  }

  // 显示格式化：能量（Wh/kWh 自动切换）
  String _formatEnergyWh(num wh) {
    final value = wh.toDouble();
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)} kWh';
    }
    return '${value.toStringAsFixed(1)} Wh';
  }

  // 显示格式化：按比例缩放并附单位（例如除以10）
  String _formatScaled(
    num raw, {
    required num divider,
    required String unit,
    int fractionDigits = 1,
  }) {
    final v = raw.toDouble() / divider;
    return '${v.toStringAsFixed(fractionDigits)} $unit';
  }

  String _fmt(num n, {String? suffix}) {
    final s = n is int ? n.toString() : n.toStringAsFixed(2);
    return suffix == null ? s : '$s$suffix';
  }

  // 主题选择部分
  Widget _buildThemeSelectionSection() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
              icon: Icons.palette,
              title: '主题颜色',
              color: Theme.of(context).colorScheme.primary,
              iconSize: 24,
              titleFontSize: 16,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (int i = 0; i < themeManager.themes.length; i++)
                  _buildThemeOption(context, i, themeManager),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    int index,
    ThemeManager themeManager,
  ) {
    final theme = themeManager.themes[index];
    final isSelected = themeManager.selectedThemeIndex == index;

    return GestureDetector(
      onTap: () => themeManager.setTheme(index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme.name,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle, color: theme.primaryColor, size: 16),
            ],
          ],
        ),
      ),
    );
  }

}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Widget? headerTrailing;
  final double? titleFontSize;
  final double? headerIconSize;
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.headerTrailing,
    this.titleFontSize,
    this.headerIconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: backgroundColor == null
            ? const LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.trim().isNotEmpty) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Builder(
                    builder: (_) {
                      final base = iconColor ?? Colors.white70;
                      final double _iconSize = headerIconSize ?? 16;
                      final double _bubbleSize = _iconSize + 12;
                      return Container(
                        width: _bubbleSize,
                        height: _bubbleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              base.withOpacity(0.85),
                              base.withOpacity(0.45),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, color: Colors.white, size: _iconSize),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF0D47A1),
                      fontSize: titleFontSize ?? 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                const Spacer(),
                if (headerTrailing != null) headerTrailing!,
              ],
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final String label;
  final int value;
  final List<int> options;
  final List<String> optionTexts;
  final ValueChanged<int?> onChanged;
  final Color? textColor;

  const _SettingsDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.optionTexts,
    required this.onChanged,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = textColor ?? theme.colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: effectiveColor),
                items: options
                    .asMap()
                    .entries
                    .map(
                      (entry) => DropdownMenuItem<int>(
                        value: entry.value,
                        child: Text(
                          optionTexts.length > entry.key
                              ? optionTexts[entry.key]
                              : entry.value.toString(),
                          style: TextStyle(color: effectiveColor),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color? textColor;

  const _SettingsNumberField({
    super.key,
    required this.label,
    required this.controller,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final currentTheme = themeManager.currentTheme;
    final effectiveColor = textColor ?? currentTheme.textColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: TextField(
            controller: controller,
            style: TextStyle(color: effectiveColor),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: currentTheme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: currentTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: currentTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: currentTheme.primaryColor,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsVersionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color? textColor;

  const _SettingsVersionField({
    super.key,
    required this.label,
    required this.controller,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final currentTheme = themeManager.currentTheme;
    final effectiveColor = textColor ?? currentTheme.textColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: TextField(
            controller: controller,
            style: TextStyle(color: effectiveColor),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: currentTheme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: currentTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: currentTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: currentTheme.primaryColor,
                  width: 1,
                ),
              ),
              prefixText: 'REV-', // 使用 prefixText 而不是额外的 Row
              prefixStyle: TextStyle(
                color: effectiveColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsReadOnly extends StatelessWidget {
  final String label;
  final String value;
  const _SettingsReadOnly({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF607D8B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF90CAF9), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ColumnCard extends StatelessWidget {
  final ColumnTelemetry data;
  const ColumnCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90CAF9), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 太阳能板分组标题 + 图标
          SectionLabel(
            icon: Icons.wb_sunny,
            title: AppLocalizations.of(context)!.sectionSolarPanel,
            color: const Color(0xFFFFD54F),
          ),
          const SizedBox(height: 6),
          MetricRow(
            label: AppLocalizations.of(context)!.powerGeneration,
            value: _fmt(data.solarEnergyKWh, suffix: 'kWh'),
          ),
          MetricRow(
            label: AppLocalizations.of(context)!.power,
            value: _fmt(data.solarPowerW, suffix: 'W'),
          ),
          MetricRow(
            label: AppLocalizations.of(context)!.voltage,
            value: _formatScaled(
              data.solarVoltageV,
              divider: 1,
              unit: 'V',
              fractionDigits: 1,
            ),
          ),
          MetricRow(
            label: AppLocalizations.of(context)!.maxPower,
            value: _fmt(data.solarMaxPowerW, suffix: 'W'),
          ),
          MetricRow(
            label: AppLocalizations.of(context)!.consumption,
            value: _fmt(data.consumptionW, suffix: 'Wh'),
          ),

          Container(height: 1, color: Colors.white12),

          // 电池分组标题 + 图标
          SectionLabel(
            icon: Icons.bolt,
            title: AppLocalizations.of(context)!.sectionBattery,
            color: const Color(0xFF64B5F6),
          ),
          const SizedBox(height: 6),
          MetricRow(
            label: AppLocalizations.of(context)!.batteryMaxVLabel,
            value: _formatScaled(
              data.batteryMaxV,
              divider: 1,
              unit: 'V',
              fractionDigits: 1,
            ),
          ),
          MetricRow(
            label: AppLocalizations.of(context)!.batteryMinVLabel,
            value: _formatScaled(
              data.batteryMinV,
              divider: 1,
              unit: 'V',
              fractionDigits: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num n, {String? suffix}) {
    final s = n is int ? n.toString() : n.toStringAsFixed(2);
    return suffix == null ? s : '$s$suffix';
  }
}

class MetricRow extends StatelessWidget {
  final String label;
  final String value;
  const MetricRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF455A64), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0D47A1),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// 实时页专用：在同一行显示 label 和 value，左右对齐
class InlineMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? textColor;

  const InlineMetricRow({
    super.key,
    required this.label,
    required this.value,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = textColor ?? theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: effectiveColor.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color; // 改为可选参数
  final double? iconSize;
  final double? titleFontSize;

  const SectionLabel({
    super.key,
    required this.icon,
    required this.title,
    this.color,
    this.iconSize,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary; // 使用主题色或指定颜色

    return Row(
      children: [
        Icon(icon, color: effectiveColor, size: iconSize ?? 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: effectiveColor, // 使用动态颜色
            fontSize: titleFontSize ?? 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class GreenStripeDivider extends StatelessWidget {
  final Color? color;

  const GreenStripeDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Container(
      height: 8,
      width: double.infinity,
      color: effectiveColor.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}

class OverviewTable extends StatelessWidget {
  final List<ColumnTelemetry> columns;
  const OverviewTable({super.key, required this.columns});

  @override
  Widget build(BuildContext context) {
    Color _bgForCol(int i) =>
        i.isEven ? const Color(0xFFE3F2FD) : const Color(0xFFEBF5FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题：太阳能板（左侧 100）
        Table(
          border: const TableBorder(
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide.none,
          ),
          columnWidths: const {0: FixedColumnWidth(80)},
          defaultColumnWidth: const FixedColumnWidth(90),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                SectionHeaderCell(
                  icon: Icons.wb_sunny,
                  title: AppLocalizations.of(context)!.sectionSolarPanel,
                  color: const Color(0xFFFFD54F),
                ),
                for (int i = 0; i < columns.length; i++) const SpacerCell(),
              ],
            ),
          ],
        ),

        // 次级：太阳能板数据行（左侧 80），去掉左侧偏移
        Table(
          border: const TableBorder(
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide.none,
          ),
          columnWidths: const {0: FixedColumnWidth(80)},
          defaultColumnWidth: const FixedColumnWidth(90),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                LabelCell(text: AppLocalizations.of(context)!.powerGeneration),
                for (int i = 0; i < columns.length; i++)
                  ValueCell(
                    text: _fmt(columns[i].solarEnergyKWh, suffix: 'kWh'),
                    backgroundColor: _bgForCol(i),
                  ),
              ],
            ),
            TableRow(
              children: [
                LabelCell(text: AppLocalizations.of(context)!.maxPower),
                for (int i = 0; i < columns.length; i++)
                  ValueCell(
                    text: _fmt(columns[i].solarMaxPowerW, suffix: 'W'),
                    backgroundColor: _bgForCol(i),
                  ),
              ],
            ),
            TableRow(
              children: [
                LabelCell(text: AppLocalizations.of(context)!.voltageMax),
                for (int i = 0; i < columns.length; i++)
                  ValueCell(
                    text: _formatScaled(
                      columns[i].solarMaxVoltageV,
                      divider: 1,
                      unit: 'V',
                      fractionDigits: 1,
                    ),
                    backgroundColor: _bgForCol(i),
                  ),
              ],
            ),
          ],
        ),

        // 标题：电池（左侧 100）
        Table(
          border: const TableBorder(
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide.none,
          ),
          columnWidths: const {0: FixedColumnWidth(80)},
          defaultColumnWidth: const FixedColumnWidth(90),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                SectionHeaderCell(
                  icon: Icons.bolt,
                  title: AppLocalizations.of(context)!.sectionBattery,
                  color: const Color(0xFF64B5F6),
                ),
                for (int i = 0; i < columns.length; i++) const SpacerCell(),
              ],
            ),
          ],
        ),

        // 次级：电池数据行（左侧 80），去掉左侧偏移
        Table(
          border: const TableBorder(
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide.none,
          ),
          columnWidths: const {0: FixedColumnWidth(80)},
          defaultColumnWidth: const FixedColumnWidth(90),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                LabelCell(text: AppLocalizations.of(context)!.batteryMaxVLabel),
                for (int i = 0; i < columns.length; i++)
                  ValueCell(
                    text: _formatScaled(
                      columns[i].batteryMaxV,
                      divider: 1,
                      unit: 'V',
                      fractionDigits: 1,
                    ),
                    backgroundColor: _bgForCol(i),
                  ),
              ],
            ),
            TableRow(
              children: [
                LabelCell(text: AppLocalizations.of(context)!.batteryMinVLabel),
                for (int i = 0; i < columns.length; i++)
                  ValueCell(
                    text: _formatScaled(
                      columns[i].batteryMinV,
                      divider: 1,
                      unit: 'V',
                      fractionDigits: 1,
                    ),
                    backgroundColor: _bgForCol(i),
                  ),
              ],
            ),
            TableRow(
              children: [
                LabelCell(text: AppLocalizations.of(context)!.consumption),
                for (int i = 0; i < columns.length; i++)
                  ValueCell(
                    text: _fmt(columns[i].consumptionW, suffix: 'Wh'),
                    backgroundColor: _bgForCol(i),
                  ),
              ],
            ),
            TableRow(
              children: [
                LabelCell(text: AppLocalizations.of(context)!.errors),
                for (int i = 0; i < columns.length; i++)
                  ValueCell(
                    text: columns[i].errorCount.toString(),
                    backgroundColor: _bgForCol(i),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static String _fmt(num n, {String? suffix}) {
    final s = n is int ? n.toString() : n.toStringAsFixed(2);
    return suffix == null ? s : '$s$suffix';
  }
}

class HeaderLabelCell extends StatelessWidget {
  final String text;
  const HeaderLabelCell({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0D47A1),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}

class HeaderValueHeaderCell extends StatelessWidget {
  final String label;
  final int errorCount;
  const HeaderValueHeaderCell({
    super.key,
    required this.label,
    required this.errorCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              errorCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeaderCell extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const SectionHeaderCell({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: kLeftLabelPaddingX,
      ),
      height: 40,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

class LabelCell extends StatelessWidget {
  final String text;
  const LabelCell({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: kLeftLabelPaddingX),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}

class LabelActionCell extends StatelessWidget {
  final String text;
  final VoidCallback onAction;
  const LabelActionCell({
    super.key,
    required this.text,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: kLeftLabelPaddingX),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              minimumSize: const Size(0, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppLocalizations.of(context)!.clearHistory,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class ValueCell extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  const ValueCell({super.key, required this.text, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final t = text.trim();
    String unit = '';
    String number = t;
    final match = RegExp(r'([A-Za-z]+)$').firstMatch(t);
    if (match != null) {
      unit = match.group(1)!;
      number = t.substring(0, t.length - unit.length);
    }

    return Container(
      color: backgroundColor,
      height: 36,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: number,
              style: const TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (unit.isNotEmpty)
              TextSpan(
                text: unit,
                style: const TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SpacerCell extends StatelessWidget {
  final Color? backgroundColor;
  const SpacerCell({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: backgroundColor ?? Colors.transparent),
    );
  }
}

class SeparatorCell extends StatelessWidget {
  const SeparatorCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFF90CAF9));
  }
}

/// 蓝牙测试组件
class BluetoothTestWidget extends StatefulWidget {
  final BluetoothService bluetoothService;

  const BluetoothTestWidget({super.key, required this.bluetoothService});

  @override
  State<BluetoothTestWidget> createState() => _BluetoothTestWidgetState();
}

class _BluetoothTestWidgetState extends State<BluetoothTestWidget> {
  bool _showLogs = false;
  String _targetName = '';
  // 显示格式化：功率（W/kW 自动切换）
  String _formatPowerW(num w) {
    final value = w.toDouble();
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)} kW';
    }
    return '${value.toStringAsFixed(1)} W';
  }

  // 显示格式化：能量（Wh/kWh 自动切换）
  String _formatEnergyWh(num wh) {
    final value = wh.toDouble();
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)} kWh';
    }
    return '${value.toStringAsFixed(1)} Wh';
  }

  // 显示格式化：按比例缩放并附单位（例如除以10）
  String _formatScaled(
    num raw, {
    required num divider,
    required String unit,
    int fractionDigits = 1,
  }) {
    final v = raw.toDouble() / divider;
    return '${v.toStringAsFixed(fractionDigits)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.bluetoothService;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 连接状态和控制按钮
        Row(
          children: [
            // 状态指示器
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(service.connectionState),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (() {
                      final l = AppLocalizations.of(context)!;
                      final msg = service.statusMessage;
                      switch (service.connectionState) {
                        case BluetoothConnectionState.scanning:
                          if (msg.contains('扫描结束')) return l.scanEnded;
                          if (msg.contains('已停止扫描')) return l.scanStopped;
                          return l.scanningInProgress;
                        case BluetoothConnectionState.connecting:
                          if (msg.startsWith('正在连接')) {
                            final name = msg
                                .replaceFirst('正在连接', '')
                                .replaceAll('...', '')
                                .trim();
                            final pure = name.startsWith(' ')
                                ? name.substring(1)
                                : name;
                            return l.connectingTo(pure.isEmpty ? '-' : pure);
                          }
                          return l.connectingTo('-');
                        case BluetoothConnectionState.connected:
                          return l.connectedStatus;
                        case BluetoothConnectionState.disconnected:
                          return l.disconnectedStatus;
                        case BluetoothConnectionState.error:
                          if (msg.contains('蓝牙不可用'))
                            return l.bluetoothUnavailable;
                          if (msg.contains('请开启蓝牙'))
                            return l.pleaseEnableBluetooth;
                          if (msg.contains('权限不足'))
                            return l.insufficientPermissions;
                          if (msg.contains('未找到设备')) return l.notFoundDevice;
                          if (msg.contains('连接失败')) {
                            final idx = msg.indexOf(':');
                            final err = idx >= 0
                                ? msg.substring(idx + 1).trim()
                                : '';
                            return l.connectionFailed(err.isEmpty ? '-' : err);
                          }
                          if (msg.contains('扫描失败')) {
                            final idx = msg.indexOf(':');
                            final err = idx >= 0
                                ? msg.substring(idx + 1).trim()
                                : '';
                            return l.scanFailed(err.isEmpty ? '-' : err);
                          }
                          return l.disconnectedStatus;
                      }
                    })(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  // 设备名过滤输入
                  Row(
                    children: [
                      // Text(
                      //   AppLocalizations.of(context)!.deviceNameFilterLabel,
                      //   style: const TextStyle(color: Colors.white60, fontSize: 12),
                      // ),
                      // const SizedBox(width: 6),
                      // Transform.scale(
                      //   scale: 0.9,
                      //   child: Switch.adaptive(
                      //     value: service.filterEnabled,
                      //     onChanged: (v) => service.setFilterEnabled(v),
                      //     activeColor: const Color(0xFF64B5F6),
                      //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //   ),
                      // ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: TextField(
                            enabled: service.filterEnabled,
                            onChanged: (v) => setState(() => _targetName = v),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.deviceNameFilterPlaceholder,
                              hintStyle: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0A1A2A),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1F4B8A),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1F4B8A),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3A78D4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 连接/断开按钮
            ElevatedButton(
              onPressed:
                  service.connectionState == BluetoothConnectionState.connected
                  ? () => service.disconnect()
                  : service.connectionState ==
                            BluetoothConnectionState.scanning ||
                        service.connectionState ==
                            BluetoothConnectionState.connecting
                  ? null
                  : () => service.scanAndConnect(
                      targetDeviceName:
                          (service.filterEnabled &&
                              _targetName.trim().isNotEmpty)
                          ? _targetName.trim()
                          : null,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: service.isConnected
                    ? Colors.red
                    : const Color(0xFF64B5F6),
                foregroundColor: service.isConnected
                    ? Colors.white
                    : const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
              ),
              child: Text(
                service.isConnected
                    ? AppLocalizations.of(context)!.disconnect
                    : AppLocalizations.of(context)!.connectAction,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 设备列表选择区
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF90CAF9), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => service.discoverDevices(
                      nameFilter:
                          (service.filterEnabled &&
                              _targetName.trim().isNotEmpty)
                          ? _targetName.trim()
                          : null,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1677FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.startScan,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  // 移除“停止扫描”按钮
                  const Spacer(),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.discoveredCount(service.discoveredDevices.length),
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await service.clearAllAliases();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.aliasesCleared,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.clearAliases,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: Builder(
                  builder: (ctx) {
                    final discovered = service.discoveredDevices;
                    final cid = service.connectedDeviceId;
                    final hasConnected =
                        cid != null &&
                        discovered.any(
                          (r) => r.device.remoteId.toString() == cid,
                        );
                    final showConnectedRow =
                        service.isConnected && cid != null && !hasConnected;
                    final total =
                        discovered.length + (showConnectedRow ? 1 : 0);
                    return ListView.builder(
                      itemCount: total,
                      itemBuilder: (context, index) {
                        if (showConnectedRow && index == 0) {
                          final remoteIdStr = cid!;
                          final fallbackName =
                              service.connectedDeviceName ??
                              AppLocalizations.of(context)!.unnamedDevice;
                          final displayName = service.resolveAlias(
                            remoteIdStr,
                            fallbackName,
                          );
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E2238),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2EB872),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: $remoteIdStr',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2EB872),
                                    foregroundColor: const Color(0xFF0D47A1),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.connectedStatus,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        final idx = showConnectedRow ? index - 1 : index;
                        final result = discovered[idx];
                        final device = result.device;
                        final adv = result.advertisementData;
                        final localName = adv.advName.isNotEmpty
                            ? adv.advName
                            : adv.localName;
                        final serviceUuids = adv.serviceUuids
                            .map((g) => g.toString())
                            .join(',');
                        final hasTargetService = false; // 不再基于固定UUID检查目标服务
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E2238),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hasTargetService
                                  ? const Color(0xFF2EB872)
                                  : const Color(0xFF1F4B8A),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 对于当前已连接设备，标题使用 connectedDeviceName；否则回退为设备名（platformName）。广播名单独展示
                                    Builder(
                                      builder: (ctx) {
                                        final remoteIdStr = device.remoteId
                                            .toString();
                                        final useConnectedName =
                                            service.connectedDeviceId ==
                                                remoteIdStr &&
                                            (service.connectedDeviceName !=
                                                    null &&
                                                service
                                                    .connectedDeviceName!
                                                    .isNotEmpty);
                                        final fallbackName = useConnectedName
                                            ? service.connectedDeviceName!
                                            : (device.platformName.isNotEmpty
                                                  ? device.platformName
                                                  : AppLocalizations.of(
                                                      ctx,
                                                    )!.unnamedDevice);
                                        final displayName = service
                                            .resolveAlias(
                                              remoteIdStr,
                                              fallbackName,
                                            );
                                        return Text(
                                          displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    Builder(
                                      builder: (ctx2) {
                                        final nameText = localName.isEmpty
                                            ? '-'
                                            : localName;
                                        return Text(
                                          AppLocalizations.of(
                                            ctx2,
                                          )!.advertisedNameLabel(nameText),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    Builder(
                                      builder: (ctx2) {
                                        return Text(
                                          AppLocalizations.of(
                                            ctx2,
                                          )!.remoteIdLabel(
                                            device.remoteId.toString(),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.rssiServicesLabel(
                                        result.rssi,
                                        serviceUuids.isEmpty
                                            ? '-'
                                            : serviceUuids,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (hasTargetService) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.matchTargetService,
                                        style: const TextStyle(
                                          color: Color(0xFF2EB872),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Builder(
                                builder: (ctx) {
                                  final remoteIdStr = device.remoteId
                                      .toString();
                                  final isConnectedItem =
                                      service.connectedDeviceId == remoteIdStr;
                                  final isConnectingItem =
                                      service.connectingRemoteId == remoteIdStr;
                                  final disabled =
                                      isConnectedItem || isConnectingItem;
                                  final bg = isConnectedItem
                                      ? const Color(0xFF2EB872)
                                      : const Color(0xFF64B5F6);
                                  final label = isConnectedItem
                                      ? AppLocalizations.of(
                                          ctx,
                                        )!.connectedStatus
                                      : AppLocalizations.of(ctx)!.connectAction;
                                  return ElevatedButton(
                                    onPressed: disabled
                                        ? null
                                        : () => service.connectToRemoteId(
                                            remoteIdStr,
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: bg,
                                      foregroundColor: const Color(0xFF0D47A1),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        if (service.isConnected) ...[
          const SizedBox(height: 16),

          // 测试按钮组
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTestButton(
                AppLocalizations.of(context)!.realtimeDataTitle,
                () => _requestMainData(),
              ),
              _buildTestButton(
                AppLocalizations.of(context)!.settingsTitle,
                () => _requestSettingsData(),
              ),
              _buildTestButton(
                AppLocalizations.of(context)!.historyTitle,
                () => _requestHistoryData(),
              ),
              _buildTestButton(
                AppLocalizations.of(context)!.submitSettings,
                () => _writeTestSettings(),
              ),
              // 注释：隐藏历史数据拉取按钮（拉取近30天历史）。如需恢复，请取消以下注释。
              // _buildTestButton(AppLocalizations.of(context)!.pullRecent30DaysAction, () async {
              //   await widget.bluetoothService.requestHistoryLastDays(days: 30);
              //   if (mounted) setState(() {});
              // }),
            ],
          ),
          const SizedBox(height: 12),
          if (service.latestHistoryDays.isNotEmpty) ...[
            buildHistoryColumnsStandalone(context, service.latestHistoryDays),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.cumulativePowerGeneration}: ${service.latestHistoryDays.isEmpty ? '—' : _formatEnergyWh(service.latestHistoryDays.map((h) => h.totalGenerationWh).reduce((a, b) => a > b ? a : b))}',
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final ok = await service.clearHistoryOnDevice();
                    if (mounted) setState(() {});
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 28),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.clearHistory,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ],

        const SizedBox(height: 16),

        // 日志控制
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _showLogs = !_showLogs),
              icon: Icon(
                _showLogs ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
              label: Text(
                '${AppLocalizations.of(context)!.logsLabel} (${service.logs.length})',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const Spacer(),
            if (service.logs.isNotEmpty)
              TextButton(
                onPressed: () => _exportLogs(),
                child: Text(
                  AppLocalizations.of(context)!.exportLogs,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            if (service.logs.isNotEmpty)
              TextButton(
                onPressed: () => service.clearLogs(),
                child: Text(
                  AppLocalizations.of(context)!.clearAction,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
          ],
        ),

        // 日志显示
        if (_showLogs && service.logs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF90CAF9), width: 1),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: service.logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    service.logs[index],
                    style: const TextStyle(
                      color: Color(0xFF455A64),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _exportLogs() async {
    final logs = widget.bluetoothService.logs;
    if (logs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noLogsToExport)),
        );
      }
      return;
    }

    final content = logs.join('\n');
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.logsCopiedToClipboard(logs.length),
          ),
        ),
      );
    }
  }

  Widget _buildTestButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1677FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }

  Color _getStatusColor(BluetoothConnectionState state) {
    switch (state) {
      case BluetoothConnectionState.connected:
        return Colors.green;
      case BluetoothConnectionState.connecting:
      case BluetoothConnectionState.scanning:
        return Colors.orange;
      case BluetoothConnectionState.error:
        return Colors.red;
      case BluetoothConnectionState.disconnected:
      default:
        return Colors.grey;
    }
  }

  Future<void> _requestMainData() async {
    final data = await widget.bluetoothService.requestMainData(
      context: UiPageContext.realtime,
    );
    if (data != null) {
      _showDataDialog(
        AppLocalizations.of(context)!.realtimeDataTitle,
        _formatMainData(data),
      );
    }
  }

  Future<void> _requestSettingsData() async {
    final data = await widget.bluetoothService.requestSettingsData(
      context: UiPageContext.settings,
    );
    if (data != null) {
      _showDataDialog(
        AppLocalizations.of(context)!.settingsTitle,
        _formatSettingsData(data),
      );
    }
  }

  Future<void> _requestHistoryData() async {
    final data = await widget.bluetoothService.requestHistoryData(
      context: UiPageContext.history,
    );
    if (data != null) {
      _showDataDialog(
        AppLocalizations.of(context)!.historyTitle,
        _formatHistoryData(data),
      );
    }
  }

  Future<void> _writeTestSettings() async {
    // 创建测试设置数据
    const testSettings = SettingsData(
      modeSelection: 1,
      batteryType: 2,
      equalizingChargeV: 14.8,
      boostChargeV: 14.6,
      floatChargeV: 13.8,
      chargeReturnV: 13.2,
      overDischargeReturnV: 11.0,
      overDischargeV: 10.5,
      loadMode: 1,
      systemVersion: 1,
      reserved: 0,
    );

    final success = await widget.bluetoothService.writeSettingsData(
      testSettings,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppLocalizations.of(context)!.settingsWriteSuccess
                : AppLocalizations.of(context)!.settingsWriteFailed,
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showDataDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.closeAction),
          ),
        ],
      ),
    );
  }

  String _formatMainData(MainInterfaceData data) {
    final loc = AppLocalizations.of(context)!;
    return '''
${loc.solarPower}: ${_formatPowerW(data.solarPowerW)}
${loc.solarVoltage}: ${_formatScaled(data.solarVoltageV, divider: 1, unit: 'V', fractionDigits: 1)}
${loc.solarCurrent}: ${_formatScaled(data.solarCurrentA, divider: 1, unit: 'A', fractionDigits: 1)}
${loc.todaysSolarEnergy}: ${_formatEnergyWh(data.todaysSolarEnergyWh)}
${loc.batteryVoltage}: ${_formatScaled(data.batteryVoltageV, divider: 1, unit: 'V', fractionDigits: 1)}
${loc.batteryCurrent}: ${_formatScaled(data.batteryCurrentA, divider: 1, unit: 'A', fractionDigits: 1)}
${loc.loadCurrent}: ${_formatScaled(data.loadCurrentA, divider: 1, unit: 'A', fractionDigits: 1)}
${loc.loadPower}: ${_formatPowerW(data.loadPowerW)}
${loc.batteryTemperature}: ${_formatScaled(data.batteryTemperatureC, divider: 1, unit: '°C', fractionDigits: 1)}
${loc.loadSwitchLabel}: ${data.loadSwitchOn ? loc.turnOn : loc.turnOff}
${loc.todaysBatteryCharge}: ${_formatScaled(data.todaysBatteryChargeAh, divider: 1, unit: 'Ah', fractionDigits: 1)}
${loc.todaysOutputEnergy}: ${_formatEnergyWh(data.todaysOutputEnergyWh)}
''';
  }

  String _formatSettingsData(SettingsData data) {
    final loc = AppLocalizations.of(context)!;
    return '''
${loc.modeSelection}: ${data.modeSelection}
${loc.batteryType}: ${data.batteryType}
${loc.equalizingChargeV}: ${data.equalizingChargeV.toStringAsFixed(1)}
${loc.boostChargeV}: ${data.boostChargeV.toStringAsFixed(1)}
${loc.floatChargeV}: ${data.floatChargeV.toStringAsFixed(1)}
${loc.chargeReturnV}: ${data.chargeReturnV.toStringAsFixed(1)}
${loc.overDischargeReturnV}: ${data.overDischargeReturnV.toStringAsFixed(1)}
${loc.loadMode}: ${data.loadMode}
${loc.systemVersion}: ${data.systemVersion}
${loc.reservedField}: ${data.reserved}
''';
  }

  String _formatHistoryData(HistoryData data) {
    final loc = AppLocalizations.of(context)!;
    return '''
${loc.dayOffset}: ${data.dayOffset}
${loc.powerGeneration}: ${_formatEnergyWh(data.solarEnergyWh)}
${loc.sectionSolarPanel} ${loc.voltageMax}: ${_formatScaled(data.solarMaxVoltageV, divider: 1, unit: 'V', fractionDigits: 1)}
${loc.sectionBattery} ${loc.voltageMax}: ${_formatScaled(data.batteryMaxVoltageV, divider: 1, unit: 'V', fractionDigits: 1)}
${loc.sectionBattery} ${loc.voltageMin}: ${_formatScaled(data.batteryMinVoltageV, divider: 1, unit: 'V', fractionDigits: 1)}
${loc.todaysBatteryCharge}: ${_formatEnergyWh(data.batteryChargeWh)}
${loc.sectionSolarPanel} ${loc.maxPower}: ${_formatPowerW(data.solarMaxPowerW)}
${loc.loadConsumption}: ${_formatEnergyWh(data.loadConsumptionWh)}
${loc.totalPowerGeneration}: ${_formatEnergyWh(data.totalGenerationWh)}
''';
  }
}

// 顶层方法：历史数据列视图（供各页面/组件复用）
Widget buildHistoryColumnsStandalone(
  BuildContext context,
  List<HistoryData> history,
) {
  final sorted = [...history];
  sorted.sort((a, b) => a.dayOffset.compareTo(b.dayOffset));
  final Map<int, HistoryData> byDay = {for (final h in sorted) h.dayOffset: h};
  // 动态按当前收到的最大天数偏移生成列（右侧最大列为当前最大天数）
  final bool noData = byDay.isEmpty;
  final int maxOffset = noData ? 0 : byDay.keys.reduce((a, b) => a > b ? a : b);
  final List<int> displayOffsets = noData
      ? <int>[]
      : List.generate(maxOffset + 1, (i) => i);
  // 逐日累计发电：若前序天数缺失则该列留空
  bool _hasCompleteUpTo(int i) =>
      List.generate(i + 1, (j) => j).every((d) => byDay[d] != null);
  String _cumulativeAt(int i) {
    if (!_hasCompleteUpTo(i)) return '';
    double sum = 0;
    for (int j = 0; j <= i; j++) {
      sum += byDay[j]!.solarEnergyWh;
    }
    return _formatEnergyWh(sum);
  }

  Color _bgForCol(int i) =>
      i.isEven ? const Color(0xFFE3F2FD) : const Color(0xFFEBF5FF);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.history30DaysColumnsTitle,
          style: const TextStyle(
            color: Color(0xFF0D47A1),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧固定列
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日期左列
                Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide.none,
                    verticalInside: BorderSide.none,
                  ),
                  columnWidths: const {0: FixedColumnWidth(80)},
                  children: [
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(context)!.dayOffset,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 太阳能板
                SectionHeaderCell(
                  title: AppLocalizations.of(context)!.sectionSolarPanel,
                  icon: Icons.wb_sunny,
                  color: const Color(0xFFFFD54F),
                ),
                Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide.none,
                    verticalInside: BorderSide.none,
                  ),
                  columnWidths: const {0: FixedColumnWidth(80)},
                  children: [
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(context)!.powerGeneration,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        LabelCell(text: AppLocalizations.of(context)!.maxPower),
                      ],
                    ),
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(context)!.voltageMax,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 电池
                SectionHeaderCell(
                  title: AppLocalizations.of(context)!.sectionBattery,
                  icon: Icons.battery_full,
                  color: Colors.lightGreenAccent,
                ),
                Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide.none,
                    verticalInside: BorderSide.none,
                  ),
                  columnWidths: const {0: FixedColumnWidth(80)},
                  children: [
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(context)!.voltageMin,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(context)!.voltageMax,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(context)!.loadConsumption,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(
                            context,
                          )!.todaysBatteryCharge,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(context)!.errorCount,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 概览（仅显示总发电量；累计发电量移至表格下方的汇总行）
                SectionHeaderCell(
                  title: AppLocalizations.of(context)!.overview,
                  icon: Icons.dashboard,
                  color: Colors.cyanAccent,
                ),
                Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide.none,
                    verticalInside: BorderSide.none,
                  ),
                  columnWidths: const {0: FixedColumnWidth(80)},
                  children: [
                    TableRow(
                      children: [
                        LabelCell(
                          text: AppLocalizations.of(
                            context,
                          )!.totalPowerGeneration,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (!noData) const SizedBox(width: 8),
            // 右侧横向滚动数据列（无数据时不显示）
            if (!noData)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期右侧值
                      Table(
                        border: const TableBorder(
                          horizontalInside: BorderSide.none,
                          verticalInside: BorderSide.none,
                        ),
                        defaultColumnWidth: const FixedColumnWidth(90),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: '${displayOffsets[i]}',
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 太阳能板占位与数据
                      SectionHeaderCell(
                        title: AppLocalizations.of(context)!.sectionSolarPanel,
                        icon: Icons.wb_sunny,
                        color: const Color(0xFFFFD54F),
                      ),
                      Table(
                        border: const TableBorder(
                          horizontalInside: BorderSide.none,
                          verticalInside: BorderSide.none,
                        ),
                        defaultColumnWidth: const FixedColumnWidth(90),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatEnergyWh(
                                          byDay[displayOffsets[i]]!
                                              .solarEnergyWh,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatPowerW(
                                          byDay[displayOffsets[i]]!
                                              .solarMaxPowerW,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatScaled(
                                          byDay[displayOffsets[i]]!
                                              .solarMaxVoltageV,
                                          divider: 1,
                                          unit: 'V',
                                          fractionDigits: 1,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 电池
                      SectionHeaderCell(
                        title: AppLocalizations.of(context)!.sectionBattery,
                        icon: Icons.battery_full,
                        color: Colors.lightGreenAccent,
                      ),
                      Table(
                        border: const TableBorder(
                          horizontalInside: BorderSide.none,
                          verticalInside: BorderSide.none,
                        ),
                        defaultColumnWidth: const FixedColumnWidth(90),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatScaled(
                                          byDay[displayOffsets[i]]!
                                              .batteryMinVoltageV,
                                          divider: 1,
                                          unit: 'V',
                                          fractionDigits: 1,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatScaled(
                                          byDay[displayOffsets[i]]!
                                              .batteryMaxVoltageV,
                                          divider: 1,
                                          unit: 'V',
                                          fractionDigits: 1,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatEnergyWh(
                                          byDay[displayOffsets[i]]!
                                              .loadConsumptionWh,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatEnergyWh(
                                          byDay[displayOffsets[i]]!
                                              .batteryChargeWh,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : '${byDay[displayOffsets[i]]!.errorCount}',
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 概览（右侧仅显示总发电量；累计发电量移至表格下方）
                      SectionHeaderCell(
                        title: AppLocalizations.of(context)!.overview,
                        icon: Icons.dashboard,
                        color: Colors.cyanAccent,
                      ),
                      Table(
                        border: const TableBorder(
                          horizontalInside: BorderSide.none,
                          verticalInside: BorderSide.none,
                        ),
                        defaultColumnWidth: const FixedColumnWidth(90),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              for (int i = 0; i < displayOffsets.length; i++)
                                ValueCell(
                                  text: (byDay[displayOffsets[i]] == null)
                                      ? ''
                                      : _formatEnergyWh(
                                          byDay[displayOffsets[i]]!
                                              .totalGenerationWh,
                                        ),
                                  backgroundColor: _bgForCol(i),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
