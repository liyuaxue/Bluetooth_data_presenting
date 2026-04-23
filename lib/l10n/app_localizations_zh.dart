// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'SolarPV';

  @override
  String get navRealtime => '实时';

  @override
  String get navHistory => '30天历史';

  @override
  String get navSettings => '设置';

  @override
  String get connectDevice => '连接设备';

  @override
  String get notConnected => '未连接设备';

  @override
  String get chooseDeviceToConnect => '选择设备连接';

  @override
  String get exportLogs => '导出日志';

  @override
  String get logsLabel => '日志';

  @override
  String get startScan => '开始扫描';

  @override
  String get stopAction => '停止';

  @override
  String get disconnect => '断开';

  @override
  String discoveredCount(int count) {
    return '已发现: $count';
  }

  @override
  String get noDevicesTip => '暂无设备，点击“开始扫描”';

  @override
  String get pleaseConnectDevice => '请先连接设备';

  @override
  String get pullingHistoryStarted => '已开始拉取近30天历史数据';

  @override
  String get settingsRead => '设置已读取';

  @override
  String get enabled => '已启用';

  @override
  String get disabledUnknown => '未启用/未知';

  @override
  String deviceNameLabel(Object name) {
    return '设备名称: $name';
  }

  @override
  String remoteIdLabel(Object id) {
    return '远程ID: $id';
  }

  @override
  String serviceUuidLabel(Object uuid) {
    return '服务UUID: $uuid';
  }

  @override
  String writeCharacteristicLabel(Object char) {
    return '写入特征: $char';
  }

  @override
  String notifyCharacteristicLabel(Object char) {
    return '通知特征: $char';
  }

  @override
  String notifyStatusLabel(Object status) {
    return '通知状态: $status';
  }

  @override
  String get unnamedDevice => '(无名设备)';

  @override
  String advertisedNameLabel(Object name) {
    return '广播名: $name';
  }

  @override
  String rssiServicesLabel(Object rssi, Object services) {
    return 'RSSI: $rssi | 服务: $services';
  }

  @override
  String get matchTargetService => '匹配目标服务';

  @override
  String get connectAction => '连接';

  @override
  String get noLogsToExport => '暂无日志可导出';

  @override
  String logsCopiedToClipboard(Object count) {
    return '日志已复制到剪贴板（共$count条）';
  }

  @override
  String get realtimeDataTitle => '实时数据';

  @override
  String get notConnectedNoData => '未连接设备，无法获取数据';

  @override
  String get connectedWaitingData => '已连接，等待数据...';

  @override
  String get sectionSolarPanel => '太阳能板';

  @override
  String get sectionBattery => '电池';

  @override
  String get sectionLoad => '负载';

  @override
  String get power => '功率';

  @override
  String get voltage => '电压';

  @override
  String get current => '电流';

  @override
  String get temperature => '温度';

  @override
  String get batterySoc => '电量(SOC)';

  @override
  String get switchLabel => '开关';

  @override
  String get loadOnSent => '已发送打开负载';

  @override
  String get loadOffSent => '已发送关闭负载';

  @override
  String get sendFailed => '发送失败';

  @override
  String get openLoad => '打开负载';

  @override
  String get closeLoad => '关闭负载';

  @override
  String get turnOn => '已开启';

  @override
  String get turnOff => '已关闭';

  @override
  String get loadSwitchLabel => '负载开关';

  @override
  String get deviceTemperature => '设备温度';

  @override
  String get historyTitle => '30天历史';

  @override
  String get pullRecent30DaysAction => '拉取近30天历史';

  @override
  String get noHistoryDataTip => '暂无历史数据，请先拉取。';

  @override
  String get settingsTitle => '设置参数';

  @override
  String get readFailedOrTimeout => '读取失败或超时';

  @override
  String get readSettings => '读取设置';

  @override
  String get settingsSentAssumed => '设置已发送（视为成功）';

  @override
  String get submitSettings => '提交设置';

  @override
  String get modeSelection => '模式选择';

  @override
  String get modeAuto => '自动';

  @override
  String get modeManual => '手动';

  @override
  String get modeTimed => '定时';

  @override
  String get modeEconomy => '节能';

  @override
  String get mode12V => '12V';

  @override
  String get mode24V => '24V';

  @override
  String get mode48V => '48V';

  @override
  String get mode96V => '96V';

  @override
  String get batteryType => '电池类型';

  @override
  String get batteryLeadAcid => '铅酸';

  @override
  String get batteryLithium => '锂电';

  @override
  String get batteryGel => '胶体';

  @override
  String get batterySLD => 'SLD';

  @override
  String get batteryGLE => 'GEL';

  @override
  String get batteryFLD => 'FLD';

  @override
  String get batteryLiFePO4 => 'LiFePO4';

  @override
  String get batteryUSE => 'USE';

  @override
  String get batteryUSELI => 'USE LI';

  @override
  String get loadMode => '负载模式';

  @override
  String get loadAlwaysOn => '常开';

  @override
  String get loadLightControl => '光控';

  @override
  String get loadPeriod => '时段';

  @override
  String get loadManual => '手动';

  @override
  String get systemVersion => '系统版本';

  @override
  String get overVoltageProtectionV => '过压保护电压(V)';

  @override
  String get chargingLimitV => '充电限制电压(V)';

  @override
  String get overDischargeV => '过放电压(V)';

  @override
  String get dischargeLimitV => '放电限制电压(V)';

  @override
  String get reservedField => '保留字段';

  @override
  String get history30DaysColumnsTitle => '近30天历史（每列为一天）';

  @override
  String get dayOffset => '日偏移';

  @override
  String get powerGeneration => '发电量';

  @override
  String get totalAmount => '累计总量';

  @override
  String get voltageMax => '最大电压';

  @override
  String get voltageMin => '最小电压';

  @override
  String get maxChargingCurrent => '最大充电电流';

  @override
  String get maxDischargingCurrent => '最大放电电流';

  @override
  String get powerSection => '功率';

  @override
  String get maxChargingPower => '最大充电功率';

  @override
  String get maxDischargingPower => '最大放电功率';

  @override
  String get overview => '概览';

  @override
  String get totalPowerGeneration => '总发电量';

  @override
  String get cumulativePowerGeneration => '累计发电量';

  @override
  String get scanningInProgress => '正在扫描...';

  @override
  String get scanEnded => '扫描结束';

  @override
  String get scanStopped => '已停止扫描';

  @override
  String get scanReady => '已准备扫描';

  @override
  String scanFailed(String error) {
    return '扫描失败: $error';
  }

  @override
  String connectingTo(String name) {
    return '正在连接 $name...';
  }

  @override
  String get connectedStatus => '已连接';

  @override
  String connectionFailed(String error) {
    return '连接失败: $error';
  }

  @override
  String get bluetoothUnavailable => '蓝牙不可用';

  @override
  String get pleaseEnableBluetooth => '请开启蓝牙';

  @override
  String get insufficientPermissions => '权限不足';

  @override
  String get notFoundDevice => '未找到设备';

  @override
  String get disconnectedStatus => '已断开连接';

  @override
  String get unexpectedDisconnectStatus => '连接已断开（异常）';

  @override
  String get unexpectedDisconnectDialogMessage => '连接异常断开，蓝牙可能中断或设备关闭。';

  @override
  String recentResponseTimeLabel(String time) {
    return '最近响应时间: $time';
  }

  @override
  String get closeAction => '关闭';

  @override
  String get clearAction => '清空';

  @override
  String get deviceNameFilterLabel => '过滤:';

  @override
  String get deviceNameFilterPlaceholder => '例如: mock 或 设备名片段';

  @override
  String get editNameTooltip => '编辑名称';

  @override
  String get editDeviceNameTitle => '编辑设备名称';

  @override
  String get aliasInputHint => '请输入别名';

  @override
  String get cancelAction => '取消';

  @override
  String get saveAction => '保存';

  @override
  String get aliasesCleared => '已清除所有设备别名';

  @override
  String get clearAliases => '清除别名';

  @override
  String get deviceNameTitle => '设备名称';

  @override
  String get clearHistory => '清除历史';

  @override
  String get settingsWriteSuccess => '设置写入成功';

  @override
  String get settingsWriteFailedOrTimeout => '设置失败或超时';

  @override
  String get settingsWriteFailed => '设置写入失败';

  @override
  String get pullingData => '正在拉取数据';

  @override
  String get lastFullPullTimeLabel => '最近一次完整拉取时间';

  @override
  String get todaysBatteryCharge => '充电量';

  @override
  String get todaysOutputEnergy => '当日输出电量';

  @override
  String get batteryMaxVLabel => '电池最大 (V)';

  @override
  String get batteryMinVLabel => '电池最小 (V)';

  @override
  String get solarPower => '太阳能功率';

  @override
  String get solarVoltage => '太阳能电压';

  @override
  String get solarCurrent => '太阳能电流';

  @override
  String get todaysSolarEnergy => '当日太阳能发电量';

  @override
  String get batteryVoltage => '电池电压';

  @override
  String get batteryCurrent => '电池电流';

  @override
  String get batteryTemperature => '电池温度';

  @override
  String get loadCurrent => '负载电流';

  @override
  String get loadPower => '负载功率';

  @override
  String get floatChargeV => '浮充充电电压(V)';

  @override
  String get chargeReturnV => '充电返回电压(V)';

  @override
  String get overDischargeReturnV => '过放返回电压(V)';

  @override
  String get consumption => '消耗';

  @override
  String get loadConsumption => '负载消耗电量';

  @override
  String get maxPower => '最大功率';

  @override
  String get errors => '错误';

  @override
  String get errorCount => '错误次数';

  @override
  String get equalizingChargeV => '均衡充电电压(V)';

  @override
  String get boostChargeV => '提升充电电压(V)';

  @override
  String get incompletePullTip => '数据拉取未完整，请再点击拉取';

  @override
  String daysAgoLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天前',
      zero: '当天',
    );
    return '$_temp0';
  }

  @override
  String lightControlTimed(Object n) {
    return '光控定时$n';
  }
}
