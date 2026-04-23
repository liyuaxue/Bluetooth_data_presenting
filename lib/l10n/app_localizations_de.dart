// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SolarPV';

  @override
  String get navRealtime => 'Echtzeit';

  @override
  String get navHistory => '30-Tage Verlauf';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get connectDevice => 'Gerät verbinden';

  @override
  String get notConnected => 'Nicht verbunden';

  @override
  String get chooseDeviceToConnect => 'Gerät zum Verbinden auswählen';

  @override
  String get exportLogs => 'Protokolle exportieren';

  @override
  String get logsLabel => 'Protokolle';

  @override
  String get startScan => 'Scan starten';

  @override
  String get stopAction => 'Stoppen';

  @override
  String get disconnect => 'Trennen';

  @override
  String discoveredCount(int count) {
    return 'Gefunden: $count';
  }

  @override
  String get noDevicesTip => 'Keine Geräte, »Scan starten« tippen';

  @override
  String get pleaseConnectDevice => 'Bitte zuerst Gerät verbinden';

  @override
  String get pullingHistoryStarted => '30-Tage-Verlauf wird abgerufen';

  @override
  String get settingsRead => 'Einstellungen geladen';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabledUnknown => 'Deaktiviert/Unbekannt';

  @override
  String deviceNameLabel(Object name) {
    return 'Gerätename: $name';
  }

  @override
  String remoteIdLabel(Object id) {
    return 'Remote-ID: $id';
  }

  @override
  String serviceUuidLabel(Object uuid) {
    return 'Service-UUID: $uuid';
  }

  @override
  String writeCharacteristicLabel(Object char) {
    return 'Schreib-Merkmal: $char';
  }

  @override
  String notifyCharacteristicLabel(Object char) {
    return 'Benachrichtigungs-Merkmal: $char';
  }

  @override
  String notifyStatusLabel(Object status) {
    return 'Benachrichtigungsstatus: $status';
  }

  @override
  String get unnamedDevice => '(Unbenanntes Gerät)';

  @override
  String advertisedNameLabel(Object name) {
    return 'Werbename: $name';
  }

  @override
  String rssiServicesLabel(Object rssi, Object services) {
    return 'RSSI: $rssi | Dienste: $services';
  }

  @override
  String get matchTargetService => 'Ziel-Dienst passt';

  @override
  String get connectAction => 'Verbinden';

  @override
  String get noLogsToExport => 'Keine Logs zum Exportieren';

  @override
  String logsCopiedToClipboard(Object count) {
    return 'Logs in Zwischenablage kopiert ($count Einträge)';
  }

  @override
  String get realtimeDataTitle => 'Echtzeitdaten';

  @override
  String get notConnectedNoData => 'Nicht verbunden; Datenabruf nicht möglich';

  @override
  String get connectedWaitingData => 'Verbunden, warte auf Daten...';

  @override
  String get sectionSolarPanel => 'Solarmodul';

  @override
  String get sectionBattery => 'Batterie';

  @override
  String get sectionLoad => 'Last';

  @override
  String get power => 'Leistung';

  @override
  String get voltage => 'Spannung';

  @override
  String get current => 'Strom';

  @override
  String get temperature => 'Temperatur';

  @override
  String get batterySoc => 'Ladestand (SOC)';

  @override
  String get switchLabel => 'Schalter';

  @override
  String get loadOnSent => 'Befehl gesendet: Last ein';

  @override
  String get loadOffSent => 'Befehl gesendet: Last aus';

  @override
  String get sendFailed => 'Senden fehlgeschlagen';

  @override
  String get openLoad => 'Last einschalten';

  @override
  String get closeLoad => 'Last ausschalten';

  @override
  String get turnOn => 'Ein';

  @override
  String get turnOff => 'Aus';

  @override
  String get loadSwitchLabel => 'Lastschalter';

  @override
  String get deviceTemperature => 'Gerätetemperatur';

  @override
  String get historyTitle => '30-Tage-Historie';

  @override
  String get pullRecent30DaysAction => 'Letzte 30 Tage abrufen';

  @override
  String get noHistoryDataTip => 'Keine Historie; bitte zuerst abrufen.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get readFailedOrTimeout =>
      'Lesen fehlgeschlagen oder Zeitüberschreitung';

  @override
  String get readSettings => 'Einstellungen lesen';

  @override
  String get settingsSentAssumed =>
      'Einstellungen gesendet (angenommen erfolgreich)';

  @override
  String get submitSettings => 'Einstellungen senden';

  @override
  String get modeSelection => 'Moduswahl';

  @override
  String get modeAuto => 'Automatisch';

  @override
  String get modeManual => 'Manuell';

  @override
  String get modeTimed => 'Zeitgesteuert';

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
  String get batteryType => 'Batterietyp';

  @override
  String get batteryLeadAcid => 'Blei-Säure';

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
  String get loadMode => 'Lastmodus';

  @override
  String get loadAlwaysOn => 'Immer an';

  @override
  String get loadLightControl => 'Lichtsteuerung';

  @override
  String get loadPeriod => 'Zeitraum';

  @override
  String get loadManual => 'Manuell';

  @override
  String get systemVersion => 'Systemversion';

  @override
  String get overVoltageProtectionV => 'Überspannungsschutz (V)';

  @override
  String get chargingLimitV => 'Ladespannungsgrenze (V)';

  @override
  String get overDischargeV => 'Überentladespannung (V)';

  @override
  String get dischargeLimitV => 'Entladespannungsgrenze (V)';

  @override
  String get reservedField => 'Reserviertes Feld';

  @override
  String get history30DaysColumnsTitle => 'Letzte 30 Tage';

  @override
  String get dayOffset => 'Tagesoffset';

  @override
  String get powerGeneration => 'Erzeugung';

  @override
  String get totalAmount => 'Gesamtmenge';

  @override
  String get voltageMax => 'Max. Spannung';

  @override
  String get voltageMin => 'Min. Spannung';

  @override
  String get maxChargingCurrent => 'Max. Ladestrom';

  @override
  String get maxDischargingCurrent => 'Max. Entladestrom';

  @override
  String get powerSection => 'Leistung';

  @override
  String get maxChargingPower => 'Max. Ladeleistung';

  @override
  String get maxDischargingPower => 'Max. Entladeleistung';

  @override
  String get overview => 'Übersicht';

  @override
  String get totalPowerGeneration => 'Gesamterzeugung';

  @override
  String get cumulativePowerGeneration => 'Kumulative Erzeugung';

  @override
  String get scanningInProgress => 'Wird gescannt...';

  @override
  String get scanEnded => 'Scan beendet';

  @override
  String get scanStopped => 'Scan gestoppt';

  @override
  String get scanReady => 'Ready to scan';

  @override
  String scanFailed(String error) {
    return 'Scan fehlgeschlagen: $error';
  }

  @override
  String connectingTo(String name) {
    return 'Verbinde mit $name...';
  }

  @override
  String get connectedStatus => 'Verbunden';

  @override
  String connectionFailed(String error) {
    return 'Verbindung fehlgeschlagen: $error';
  }

  @override
  String get bluetoothUnavailable => 'Bluetooth nicht verfügbar';

  @override
  String get pleaseEnableBluetooth => 'Bitte Bluetooth aktivieren';

  @override
  String get insufficientPermissions => 'Unzureichende Berechtigungen';

  @override
  String get notFoundDevice => 'Kein Gerät gefunden';

  @override
  String get disconnectedStatus => 'Getrennt';

  @override
  String get unexpectedDisconnectStatus => 'Unerwartet getrennt';

  @override
  String get unexpectedDisconnectDialogMessage =>
      'Die Verbindung wurde unerwartet getrennt.';

  @override
  String recentResponseTimeLabel(String time) {
    return 'Letzte Antwort: $time';
  }

  @override
  String get closeAction => 'Schließen';

  @override
  String get clearAction => 'Leeren';

  @override
  String get deviceNameFilterLabel => 'Filter:';

  @override
  String get deviceNameFilterPlaceholder => 'z. B. mock oder Namensfragment';

  @override
  String get editNameTooltip => 'Name bearbeiten';

  @override
  String get editDeviceNameTitle => 'Gerätenamen bearbeiten';

  @override
  String get aliasInputHint => 'Alias eingeben';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get saveAction => 'Speichern';

  @override
  String get aliasesCleared => 'Alle Gerätenamen-Aliase gelöscht';

  @override
  String get clearAliases => 'Aliase löschen';

  @override
  String get deviceNameTitle => 'Gerätename';

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get settingsWriteSuccess => 'Einstellungen erfolgreich geschrieben';

  @override
  String get settingsWriteFailedOrTimeout =>
      'Einstellungen fehlgeschlagen oder Zeitüberschreitung';

  @override
  String get settingsWriteFailed =>
      'Schreiben der Einstellungen fehlgeschlagen';

  @override
  String get pullingData => 'Daten werden abgerufen...';

  @override
  String get lastFullPullTimeLabel => 'Letzter vollständiger Abrufzeitpunkt';

  @override
  String get todaysBatteryCharge => 'Batterieladung';

  @override
  String get todaysOutputEnergy => 'Heutige Ausgangsenergie';

  @override
  String get batteryMaxVLabel => 'Max. Batteriespannung (V)';

  @override
  String get batteryMinVLabel => 'Min. Batteriespannung (V)';

  @override
  String get solarPower => 'Solarleistung';

  @override
  String get solarVoltage => 'Solarspannung';

  @override
  String get solarCurrent => 'Solarstrom';

  @override
  String get todaysSolarEnergy => 'Heutige Solarenergie';

  @override
  String get batteryVoltage => 'Batteriespannung';

  @override
  String get batteryCurrent => 'Batteriestrom';

  @override
  String get batteryTemperature => 'Batterietemperatur';

  @override
  String get loadCurrent => 'Laststrom';

  @override
  String get loadPower => 'Lastleistung';

  @override
  String get floatChargeV => 'Erhaltungsladespannung (V)';

  @override
  String get chargeReturnV => 'Laderückkehrspannung (V)';

  @override
  String get overDischargeReturnV => 'Rückkehrspannung bei Tiefentladung (V)';

  @override
  String get consumption => 'Verbrauch';

  @override
  String get loadConsumption => 'Lastverbrauch';

  @override
  String get maxPower => 'Max. Leistung';

  @override
  String get errors => 'Fehler';

  @override
  String get errorCount => 'Fehleranzahl';

  @override
  String get equalizingChargeV => 'Ausgleichsladespannung (V)';

  @override
  String get boostChargeV => 'Boost-Ladespannung (V)';

  @override
  String get incompletePullTip =>
      'Datenabruf unvollständig; bitte erneut versuchen';

  @override
  String daysAgoLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'vor $days Tagen',
      one: 'vor $days Tag',
      zero: 'Heute',
    );
    return '$_temp0';
  }

  @override
  String lightControlTimed(Object n) {
    return 'Lichtsteuerung zeitgesteuert $n';
  }
}
