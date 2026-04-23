// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SolarPV';

  @override
  String get navRealtime => 'Realtime';

  @override
  String get navHistory => '30-day History';

  @override
  String get navSettings => 'Settings';

  @override
  String get connectDevice => 'Connect Device';

  @override
  String get notConnected => 'Not connected';

  @override
  String get chooseDeviceToConnect => 'Choose Device to Connect';

  @override
  String get exportLogs => 'Export Logs';

  @override
  String get logsLabel => 'Logs';

  @override
  String get startScan => 'Start Scan';

  @override
  String get stopAction => 'Stop';

  @override
  String get disconnect => 'Disconnect';

  @override
  String discoveredCount(int count) {
    return 'Discovered: $count';
  }

  @override
  String get noDevicesTip => 'No devices, tap “Start Scan”';

  @override
  String get pleaseConnectDevice => 'Please connect device first';

  @override
  String get pullingHistoryStarted => 'Started pulling last 30 days of history';

  @override
  String get settingsRead => 'Settings loaded';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabledUnknown => 'Disabled/Unknown';

  @override
  String deviceNameLabel(Object name) {
    return 'Device Name: $name';
  }

  @override
  String remoteIdLabel(Object id) {
    return 'Remote ID: $id';
  }

  @override
  String serviceUuidLabel(Object uuid) {
    return 'Service UUID: $uuid';
  }

  @override
  String writeCharacteristicLabel(Object char) {
    return 'Write Characteristic: $char';
  }

  @override
  String notifyCharacteristicLabel(Object char) {
    return 'Notify Characteristic: $char';
  }

  @override
  String notifyStatusLabel(Object status) {
    return 'Notify Status: $status';
  }

  @override
  String get unnamedDevice => '(Unnamed device)';

  @override
  String advertisedNameLabel(Object name) {
    return 'Advertised Name: $name';
  }

  @override
  String rssiServicesLabel(Object rssi, Object services) {
    return 'RSSI: $rssi | Services: $services';
  }

  @override
  String get matchTargetService => 'Matches target service';

  @override
  String get connectAction => 'Connect';

  @override
  String get noLogsToExport => 'No logs to export';

  @override
  String logsCopiedToClipboard(Object count) {
    return 'Logs copied to clipboard ($count items)';
  }

  @override
  String get realtimeDataTitle => 'Realtime Data';

  @override
  String get notConnectedNoData => 'Not connected; cannot fetch data';

  @override
  String get connectedWaitingData => 'Connected, waiting for data...';

  @override
  String get sectionSolarPanel => 'Solar Panel';

  @override
  String get sectionBattery => 'Battery';

  @override
  String get sectionLoad => 'Load';

  @override
  String get power => 'Power';

  @override
  String get voltage => 'Voltage';

  @override
  String get current => 'Current';

  @override
  String get temperature => 'Temperature';

  @override
  String get batterySoc => 'Battery (SOC)';

  @override
  String get switchLabel => 'Switch';

  @override
  String get loadOnSent => 'Sent: turn load on';

  @override
  String get loadOffSent => 'Sent: turn load off';

  @override
  String get sendFailed => 'Send failed';

  @override
  String get openLoad => 'Turn load on';

  @override
  String get closeLoad => 'Turn load off';

  @override
  String get turnOn => 'On';

  @override
  String get turnOff => 'Off';

  @override
  String get loadSwitchLabel => 'Load Switch';

  @override
  String get deviceTemperature => 'Device Temperature';

  @override
  String get historyTitle => '30-Day History';

  @override
  String get pullRecent30DaysAction => 'Pull last 30 days';

  @override
  String get noHistoryDataTip => 'No history yet; pull data first.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get readFailedOrTimeout => 'Read failed or timed out';

  @override
  String get readSettings => 'Read Settings';

  @override
  String get settingsSentAssumed => 'Settings sent (assumed success)';

  @override
  String get submitSettings => 'Submit Settings';

  @override
  String get modeSelection => 'Mode Selection';

  @override
  String get modeAuto => 'Auto';

  @override
  String get modeManual => 'Manual';

  @override
  String get modeTimed => 'Timed';

  @override
  String get modeEconomy => 'Eco';

  @override
  String get mode12V => '12V';

  @override
  String get mode24V => '24V';

  @override
  String get mode48V => '48V';

  @override
  String get mode96V => '96V';

  @override
  String get batteryType => 'Battery Type';

  @override
  String get batteryLeadAcid => 'Lead-acid';

  @override
  String get batteryLithium => 'Lithium';

  @override
  String get batteryGel => 'Gel';

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
  String get loadMode => 'Load Mode';

  @override
  String get loadAlwaysOn => 'Always On';

  @override
  String get loadLightControl => 'Light Control';

  @override
  String get loadPeriod => 'Period';

  @override
  String get loadManual => 'Manual';

  @override
  String get systemVersion => 'System Version';

  @override
  String get overVoltageProtectionV => 'Over-voltage Protection (V)';

  @override
  String get chargingLimitV => 'Charging Limit (V)';

  @override
  String get overDischargeV => 'Over-discharge Voltage (V)';

  @override
  String get dischargeLimitV => 'Discharge Limit (V)';

  @override
  String get reservedField => 'Reserved Field';

  @override
  String get history30DaysColumnsTitle => 'Last 30 days';

  @override
  String get dayOffset => 'Day Offset';

  @override
  String get powerGeneration => 'Generation';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get voltageMax => 'Max Voltage';

  @override
  String get voltageMin => 'Min Voltage';

  @override
  String get maxChargingCurrent => 'Max Charging Current';

  @override
  String get maxDischargingCurrent => 'Max Discharging Current';

  @override
  String get powerSection => 'Power';

  @override
  String get maxChargingPower => 'Max Charging Power';

  @override
  String get maxDischargingPower => 'Max Discharging Power';

  @override
  String get overview => 'Overview';

  @override
  String get totalPowerGeneration => 'Total Generation';

  @override
  String get cumulativePowerGeneration => 'Cumulative Generation';

  @override
  String get scanningInProgress => 'Scanning...';

  @override
  String get scanEnded => 'Scan ended';

  @override
  String get scanStopped => 'Scan stopped';

  @override
  String get scanReady => 'Ready to scan';

  @override
  String scanFailed(String error) {
    return 'Scan failed: $error';
  }

  @override
  String connectingTo(String name) {
    return 'Connecting to $name...';
  }

  @override
  String get connectedStatus => 'Connected';

  @override
  String connectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get bluetoothUnavailable => 'Bluetooth unsupported';

  @override
  String get pleaseEnableBluetooth => 'Please enable Bluetooth';

  @override
  String get insufficientPermissions => 'Insufficient permissions';

  @override
  String get notFoundDevice => 'No device found';

  @override
  String get disconnectedStatus => 'Disconnected';

  @override
  String get unexpectedDisconnectStatus => 'Disconnected (unexpected)';

  @override
  String get unexpectedDisconnectDialogMessage =>
      'The connection was lost unexpectedly.';

  @override
  String recentResponseTimeLabel(String time) {
    return 'Last response: $time';
  }

  @override
  String get closeAction => 'Close';

  @override
  String get clearAction => 'Clear';

  @override
  String get deviceNameFilterLabel => 'Filter:';

  @override
  String get deviceNameFilterPlaceholder => 'e.g. mock or name fragment';

  @override
  String get editNameTooltip => 'Edit name';

  @override
  String get editDeviceNameTitle => 'Edit Device Name';

  @override
  String get aliasInputHint => 'Enter alias';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get saveAction => 'Save';

  @override
  String get aliasesCleared => 'Cleared all device aliases';

  @override
  String get clearAliases => 'Clear Aliases';

  @override
  String get deviceNameTitle => 'Device Name';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get settingsWriteSuccess => 'Settings written successfully';

  @override
  String get settingsWriteFailedOrTimeout => 'Settings failed or timed out';

  @override
  String get settingsWriteFailed => 'Settings write failed';

  @override
  String get pullingData => 'Pulling data...';

  @override
  String get lastFullPullTimeLabel => 'Last full pull time';

  @override
  String get todaysBatteryCharge => 'Battery Charge';

  @override
  String get todaysOutputEnergy => 'Today\'s Output Energy';

  @override
  String get batteryMaxVLabel => 'Battery Max (V)';

  @override
  String get batteryMinVLabel => 'Battery Min (V)';

  @override
  String get solarPower => 'Solar Power';

  @override
  String get solarVoltage => 'Solar Voltage';

  @override
  String get solarCurrent => 'Solar Current';

  @override
  String get todaysSolarEnergy => 'Today\'s Solar Energy';

  @override
  String get batteryVoltage => 'Battery Voltage';

  @override
  String get batteryCurrent => 'Battery Current';

  @override
  String get batteryTemperature => 'Battery Temperature';

  @override
  String get loadCurrent => 'Load Current';

  @override
  String get loadPower => 'Load Power';

  @override
  String get floatChargeV => 'Float charge voltage (V)';

  @override
  String get chargeReturnV => 'Charge return voltage (V)';

  @override
  String get overDischargeReturnV => 'Over-discharge return voltage (V)';

  @override
  String get consumption => 'Consumption';

  @override
  String get loadConsumption => 'Load Consumption';

  @override
  String get maxPower => 'Max Power';

  @override
  String get errors => 'Errors';

  @override
  String get errorCount => 'Error Count';

  @override
  String get equalizingChargeV => 'Equalizing charge voltage (V)';

  @override
  String get boostChargeV => 'Boost charge voltage (V)';

  @override
  String get incompletePullTip => 'Data pull incomplete; please retry';

  @override
  String daysAgoLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '$days day ago',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String lightControlTimed(Object n) {
    return 'Light control timed $n';
  }
}
