import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SolarPV'**
  String get appTitle;

  /// No description provided for @navRealtime.
  ///
  /// In en, this message translates to:
  /// **'Realtime'**
  String get navRealtime;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'30-day History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @connectDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect Device'**
  String get connectDevice;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @chooseDeviceToConnect.
  ///
  /// In en, this message translates to:
  /// **'Choose Device to Connect'**
  String get chooseDeviceToConnect;

  /// No description provided for @exportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export Logs'**
  String get exportLogs;

  /// No description provided for @logsLabel.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsLabel;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get startScan;

  /// No description provided for @stopAction.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAction;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Shows number of discovered devices
  ///
  /// In en, this message translates to:
  /// **'Discovered: {count}'**
  String discoveredCount(int count);

  /// No description provided for @noDevicesTip.
  ///
  /// In en, this message translates to:
  /// **'No devices, tap “Start Scan”'**
  String get noDevicesTip;

  /// No description provided for @pleaseConnectDevice.
  ///
  /// In en, this message translates to:
  /// **'Please connect device first'**
  String get pleaseConnectDevice;

  /// No description provided for @pullingHistoryStarted.
  ///
  /// In en, this message translates to:
  /// **'Started pulling last 30 days of history'**
  String get pullingHistoryStarted;

  /// No description provided for @settingsRead.
  ///
  /// In en, this message translates to:
  /// **'Settings loaded'**
  String get settingsRead;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabledUnknown.
  ///
  /// In en, this message translates to:
  /// **'Disabled/Unknown'**
  String get disabledUnknown;

  /// No description provided for @deviceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Device Name: {name}'**
  String deviceNameLabel(Object name);

  /// No description provided for @remoteIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Remote ID: {id}'**
  String remoteIdLabel(Object id);

  /// No description provided for @serviceUuidLabel.
  ///
  /// In en, this message translates to:
  /// **'Service UUID: {uuid}'**
  String serviceUuidLabel(Object uuid);

  /// No description provided for @writeCharacteristicLabel.
  ///
  /// In en, this message translates to:
  /// **'Write Characteristic: {char}'**
  String writeCharacteristicLabel(Object char);

  /// No description provided for @notifyCharacteristicLabel.
  ///
  /// In en, this message translates to:
  /// **'Notify Characteristic: {char}'**
  String notifyCharacteristicLabel(Object char);

  /// No description provided for @notifyStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Notify Status: {status}'**
  String notifyStatusLabel(Object status);

  /// No description provided for @unnamedDevice.
  ///
  /// In en, this message translates to:
  /// **'(Unnamed device)'**
  String get unnamedDevice;

  /// No description provided for @advertisedNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Advertised Name: {name}'**
  String advertisedNameLabel(Object name);

  /// No description provided for @rssiServicesLabel.
  ///
  /// In en, this message translates to:
  /// **'RSSI: {rssi} | Services: {services}'**
  String rssiServicesLabel(Object rssi, Object services);

  /// No description provided for @matchTargetService.
  ///
  /// In en, this message translates to:
  /// **'Matches target service'**
  String get matchTargetService;

  /// No description provided for @connectAction.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectAction;

  /// No description provided for @noLogsToExport.
  ///
  /// In en, this message translates to:
  /// **'No logs to export'**
  String get noLogsToExport;

  /// No description provided for @logsCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard ({count} items)'**
  String logsCopiedToClipboard(Object count);

  /// No description provided for @realtimeDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Realtime Data'**
  String get realtimeDataTitle;

  /// No description provided for @notConnectedNoData.
  ///
  /// In en, this message translates to:
  /// **'Not connected; cannot fetch data'**
  String get notConnectedNoData;

  /// No description provided for @connectedWaitingData.
  ///
  /// In en, this message translates to:
  /// **'Connected, waiting for data...'**
  String get connectedWaitingData;

  /// No description provided for @sectionSolarPanel.
  ///
  /// In en, this message translates to:
  /// **'Solar Panel'**
  String get sectionSolarPanel;

  /// No description provided for @sectionBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get sectionBattery;

  /// No description provided for @sectionLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get sectionLoad;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get voltage;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @batterySoc.
  ///
  /// In en, this message translates to:
  /// **'Battery (SOC)'**
  String get batterySoc;

  /// No description provided for @switchLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchLabel;

  /// No description provided for @loadOnSent.
  ///
  /// In en, this message translates to:
  /// **'Sent: turn load on'**
  String get loadOnSent;

  /// No description provided for @loadOffSent.
  ///
  /// In en, this message translates to:
  /// **'Sent: turn load off'**
  String get loadOffSent;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed'**
  String get sendFailed;

  /// No description provided for @openLoad.
  ///
  /// In en, this message translates to:
  /// **'Turn load on'**
  String get openLoad;

  /// No description provided for @closeLoad.
  ///
  /// In en, this message translates to:
  /// **'Turn load off'**
  String get closeLoad;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get turnOn;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get turnOff;

  /// No description provided for @loadSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Load Switch'**
  String get loadSwitchLabel;

  /// No description provided for @deviceTemperature.
  ///
  /// In en, this message translates to:
  /// **'Device Temperature'**
  String get deviceTemperature;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'30-Day History'**
  String get historyTitle;

  /// No description provided for @pullRecent30DaysAction.
  ///
  /// In en, this message translates to:
  /// **'Pull last 30 days'**
  String get pullRecent30DaysAction;

  /// No description provided for @noHistoryDataTip.
  ///
  /// In en, this message translates to:
  /// **'No history yet; pull data first.'**
  String get noHistoryDataTip;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @readFailedOrTimeout.
  ///
  /// In en, this message translates to:
  /// **'Read failed or timed out'**
  String get readFailedOrTimeout;

  /// No description provided for @readSettings.
  ///
  /// In en, this message translates to:
  /// **'Read Settings'**
  String get readSettings;

  /// No description provided for @settingsSentAssumed.
  ///
  /// In en, this message translates to:
  /// **'Settings sent (assumed success)'**
  String get settingsSentAssumed;

  /// No description provided for @submitSettings.
  ///
  /// In en, this message translates to:
  /// **'Submit Settings'**
  String get submitSettings;

  /// No description provided for @modeSelection.
  ///
  /// In en, this message translates to:
  /// **'Mode Selection'**
  String get modeSelection;

  /// No description provided for @modeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get modeAuto;

  /// No description provided for @modeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get modeManual;

  /// No description provided for @modeTimed.
  ///
  /// In en, this message translates to:
  /// **'Timed'**
  String get modeTimed;

  /// No description provided for @modeEconomy.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get modeEconomy;

  /// No description provided for @mode12V.
  ///
  /// In en, this message translates to:
  /// **'12V'**
  String get mode12V;

  /// No description provided for @mode24V.
  ///
  /// In en, this message translates to:
  /// **'24V'**
  String get mode24V;

  /// No description provided for @mode48V.
  ///
  /// In en, this message translates to:
  /// **'48V'**
  String get mode48V;

  /// No description provided for @mode96V.
  ///
  /// In en, this message translates to:
  /// **'96V'**
  String get mode96V;

  /// No description provided for @batteryType.
  ///
  /// In en, this message translates to:
  /// **'Battery Type'**
  String get batteryType;

  /// No description provided for @batteryLeadAcid.
  ///
  /// In en, this message translates to:
  /// **'Lead-acid'**
  String get batteryLeadAcid;

  /// No description provided for @batteryLithium.
  ///
  /// In en, this message translates to:
  /// **'Lithium'**
  String get batteryLithium;

  /// No description provided for @batteryGel.
  ///
  /// In en, this message translates to:
  /// **'Gel'**
  String get batteryGel;

  /// No description provided for @batterySLD.
  ///
  /// In en, this message translates to:
  /// **'SLD'**
  String get batterySLD;

  /// No description provided for @batteryGLE.
  ///
  /// In en, this message translates to:
  /// **'GEL'**
  String get batteryGLE;

  /// No description provided for @batteryFLD.
  ///
  /// In en, this message translates to:
  /// **'FLD'**
  String get batteryFLD;

  /// No description provided for @batteryLiFePO4.
  ///
  /// In en, this message translates to:
  /// **'LiFePO4'**
  String get batteryLiFePO4;

  /// No description provided for @batteryUSE.
  ///
  /// In en, this message translates to:
  /// **'USE'**
  String get batteryUSE;

  /// No description provided for @batteryUSELI.
  ///
  /// In en, this message translates to:
  /// **'USE LI'**
  String get batteryUSELI;

  /// No description provided for @loadMode.
  ///
  /// In en, this message translates to:
  /// **'Load Mode'**
  String get loadMode;

  /// No description provided for @loadAlwaysOn.
  ///
  /// In en, this message translates to:
  /// **'Always On'**
  String get loadAlwaysOn;

  /// No description provided for @loadLightControl.
  ///
  /// In en, this message translates to:
  /// **'Light Control'**
  String get loadLightControl;

  /// No description provided for @loadPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get loadPeriod;

  /// No description provided for @loadManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get loadManual;

  /// No description provided for @systemVersion.
  ///
  /// In en, this message translates to:
  /// **'System Version'**
  String get systemVersion;

  /// No description provided for @overVoltageProtectionV.
  ///
  /// In en, this message translates to:
  /// **'Over-voltage Protection (V)'**
  String get overVoltageProtectionV;

  /// No description provided for @chargingLimitV.
  ///
  /// In en, this message translates to:
  /// **'Charging Limit (V)'**
  String get chargingLimitV;

  /// No description provided for @overDischargeV.
  ///
  /// In en, this message translates to:
  /// **'Over-discharge Voltage (V)'**
  String get overDischargeV;

  /// No description provided for @dischargeLimitV.
  ///
  /// In en, this message translates to:
  /// **'Discharge Limit (V)'**
  String get dischargeLimitV;

  /// No description provided for @reservedField.
  ///
  /// In en, this message translates to:
  /// **'Reserved Field'**
  String get reservedField;

  /// No description provided for @history30DaysColumnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get history30DaysColumnsTitle;

  /// No description provided for @dayOffset.
  ///
  /// In en, this message translates to:
  /// **'Day Offset'**
  String get dayOffset;

  /// No description provided for @powerGeneration.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get powerGeneration;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @voltageMax.
  ///
  /// In en, this message translates to:
  /// **'Max Voltage'**
  String get voltageMax;

  /// No description provided for @voltageMin.
  ///
  /// In en, this message translates to:
  /// **'Min Voltage'**
  String get voltageMin;

  /// No description provided for @maxChargingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Max Charging Current'**
  String get maxChargingCurrent;

  /// No description provided for @maxDischargingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Max Discharging Current'**
  String get maxDischargingCurrent;

  /// No description provided for @powerSection.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get powerSection;

  /// No description provided for @maxChargingPower.
  ///
  /// In en, this message translates to:
  /// **'Max Charging Power'**
  String get maxChargingPower;

  /// No description provided for @maxDischargingPower.
  ///
  /// In en, this message translates to:
  /// **'Max Discharging Power'**
  String get maxDischargingPower;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @totalPowerGeneration.
  ///
  /// In en, this message translates to:
  /// **'Total Generation'**
  String get totalPowerGeneration;

  /// No description provided for @cumulativePowerGeneration.
  ///
  /// In en, this message translates to:
  /// **'Cumulative Generation'**
  String get cumulativePowerGeneration;

  /// No description provided for @scanningInProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanningInProgress;

  /// No description provided for @scanEnded.
  ///
  /// In en, this message translates to:
  /// **'Scan ended'**
  String get scanEnded;

  /// No description provided for @scanStopped.
  ///
  /// In en, this message translates to:
  /// **'Scan stopped'**
  String get scanStopped;

  /// No description provided for @scanReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get scanReady;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed: {error}'**
  String scanFailed(String error);

  /// No description provided for @connectingTo.
  ///
  /// In en, this message translates to:
  /// **'Connecting to {name}...'**
  String connectingTo(String name);

  /// No description provided for @connectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectedStatus;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {error}'**
  String connectionFailed(String error);

  /// No description provided for @bluetoothUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth unsupported'**
  String get bluetoothUnavailable;

  /// No description provided for @pleaseEnableBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth'**
  String get pleaseEnableBluetooth;

  /// No description provided for @insufficientPermissions.
  ///
  /// In en, this message translates to:
  /// **'Insufficient permissions'**
  String get insufficientPermissions;

  /// No description provided for @notFoundDevice.
  ///
  /// In en, this message translates to:
  /// **'No device found'**
  String get notFoundDevice;

  /// No description provided for @disconnectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnectedStatus;

  /// No description provided for @unexpectedDisconnectStatus.
  ///
  /// In en, this message translates to:
  /// **'Disconnected (unexpected)'**
  String get unexpectedDisconnectStatus;

  /// No description provided for @unexpectedDisconnectDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The connection was lost unexpectedly.'**
  String get unexpectedDisconnectDialogMessage;

  /// No description provided for @recentResponseTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Last response: {time}'**
  String recentResponseTimeLabel(String time);

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @deviceNameFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter:'**
  String get deviceNameFilterLabel;

  /// No description provided for @deviceNameFilterPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. mock or name fragment'**
  String get deviceNameFilterPlaceholder;

  /// No description provided for @editNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editNameTooltip;

  /// No description provided for @editDeviceNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Device Name'**
  String get editDeviceNameTitle;

  /// No description provided for @aliasInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter alias'**
  String get aliasInputHint;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @aliasesCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared all device aliases'**
  String get aliasesCleared;

  /// No description provided for @clearAliases.
  ///
  /// In en, this message translates to:
  /// **'Clear Aliases'**
  String get clearAliases;

  /// No description provided for @deviceNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceNameTitle;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @settingsWriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings written successfully'**
  String get settingsWriteSuccess;

  /// No description provided for @settingsWriteFailedOrTimeout.
  ///
  /// In en, this message translates to:
  /// **'Settings failed or timed out'**
  String get settingsWriteFailedOrTimeout;

  /// No description provided for @settingsWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Settings write failed'**
  String get settingsWriteFailed;

  /// No description provided for @pullingData.
  ///
  /// In en, this message translates to:
  /// **'Pulling data...'**
  String get pullingData;

  /// No description provided for @lastFullPullTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Last full pull time'**
  String get lastFullPullTimeLabel;

  /// No description provided for @todaysBatteryCharge.
  ///
  /// In en, this message translates to:
  /// **'Battery Charge'**
  String get todaysBatteryCharge;

  /// No description provided for @todaysOutputEnergy.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Output Energy'**
  String get todaysOutputEnergy;

  /// No description provided for @batteryMaxVLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery Max (V)'**
  String get batteryMaxVLabel;

  /// No description provided for @batteryMinVLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery Min (V)'**
  String get batteryMinVLabel;

  /// No description provided for @solarPower.
  ///
  /// In en, this message translates to:
  /// **'Solar Power'**
  String get solarPower;

  /// No description provided for @solarVoltage.
  ///
  /// In en, this message translates to:
  /// **'Solar Voltage'**
  String get solarVoltage;

  /// No description provided for @solarCurrent.
  ///
  /// In en, this message translates to:
  /// **'Solar Current'**
  String get solarCurrent;

  /// No description provided for @todaysSolarEnergy.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Solar Energy'**
  String get todaysSolarEnergy;

  /// No description provided for @batteryVoltage.
  ///
  /// In en, this message translates to:
  /// **'Battery Voltage'**
  String get batteryVoltage;

  /// No description provided for @batteryCurrent.
  ///
  /// In en, this message translates to:
  /// **'Battery Current'**
  String get batteryCurrent;

  /// No description provided for @batteryTemperature.
  ///
  /// In en, this message translates to:
  /// **'Battery Temperature'**
  String get batteryTemperature;

  /// No description provided for @loadCurrent.
  ///
  /// In en, this message translates to:
  /// **'Load Current'**
  String get loadCurrent;

  /// No description provided for @loadPower.
  ///
  /// In en, this message translates to:
  /// **'Load Power'**
  String get loadPower;

  /// No description provided for @floatChargeV.
  ///
  /// In en, this message translates to:
  /// **'Float charge voltage (V)'**
  String get floatChargeV;

  /// No description provided for @chargeReturnV.
  ///
  /// In en, this message translates to:
  /// **'Charge return voltage (V)'**
  String get chargeReturnV;

  /// No description provided for @overDischargeReturnV.
  ///
  /// In en, this message translates to:
  /// **'Over-discharge return voltage (V)'**
  String get overDischargeReturnV;

  /// No description provided for @consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get consumption;

  /// No description provided for @loadConsumption.
  ///
  /// In en, this message translates to:
  /// **'Load Consumption'**
  String get loadConsumption;

  /// No description provided for @maxPower.
  ///
  /// In en, this message translates to:
  /// **'Max Power'**
  String get maxPower;

  /// No description provided for @errors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errors;

  /// No description provided for @errorCount.
  ///
  /// In en, this message translates to:
  /// **'Error Count'**
  String get errorCount;

  /// No description provided for @equalizingChargeV.
  ///
  /// In en, this message translates to:
  /// **'Equalizing charge voltage (V)'**
  String get equalizingChargeV;

  /// No description provided for @boostChargeV.
  ///
  /// In en, this message translates to:
  /// **'Boost charge voltage (V)'**
  String get boostChargeV;

  /// No description provided for @incompletePullTip.
  ///
  /// In en, this message translates to:
  /// **'Data pull incomplete; please retry'**
  String get incompletePullTip;

  /// Relative day label with plural rules
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0 {Today} =1 {{days} day ago} other {{days} days ago}}'**
  String daysAgoLabel(int days);

  /// No description provided for @lightControlTimed.
  ///
  /// In en, this message translates to:
  /// **'Light control timed {n}'**
  String lightControlTimed(Object n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
