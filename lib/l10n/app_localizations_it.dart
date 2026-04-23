// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'SolarPV';

  @override
  String get navRealtime => 'Tempo reale';

  @override
  String get navHistory => 'Storico 30 giorni';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get connectDevice => 'Connetti dispositivo';

  @override
  String get notConnected => 'Non connesso';

  @override
  String get chooseDeviceToConnect => 'Scegli dispositivo da connettere';

  @override
  String get exportLogs => 'Esporta log';

  @override
  String get logsLabel => 'Registri';

  @override
  String get startScan => 'Avvia scansione';

  @override
  String get stopAction => 'Stop';

  @override
  String get disconnect => 'Disconnetti';

  @override
  String discoveredCount(int count) {
    return 'Trovati: $count';
  }

  @override
  String get noDevicesTip => 'Nessun dispositivo, tocca “Avvia scansione”';

  @override
  String get pleaseConnectDevice => 'Connetti prima un dispositivo';

  @override
  String get pullingHistoryStarted => 'Avviato recupero degli ultimi 30 giorni';

  @override
  String get settingsRead => 'Impostazioni caricate';

  @override
  String get enabled => 'Abilitato';

  @override
  String get disabledUnknown => 'Disabilitato/Sconosciuto';

  @override
  String deviceNameLabel(Object name) {
    return 'Nome dispositivo: $name';
  }

  @override
  String remoteIdLabel(Object id) {
    return 'ID remoto: $id';
  }

  @override
  String serviceUuidLabel(Object uuid) {
    return 'UUID servizio: $uuid';
  }

  @override
  String writeCharacteristicLabel(Object char) {
    return 'Caratteristica di scrittura: $char';
  }

  @override
  String notifyCharacteristicLabel(Object char) {
    return 'Caratteristica di notifica: $char';
  }

  @override
  String notifyStatusLabel(Object status) {
    return 'Stato notifica: $status';
  }

  @override
  String get unnamedDevice => '(Dispositivo senza nome)';

  @override
  String advertisedNameLabel(Object name) {
    return 'Nome pubblicizzato: $name';
  }

  @override
  String rssiServicesLabel(Object rssi, Object services) {
    return 'RSSI: $rssi | Servizi: $services';
  }

  @override
  String get matchTargetService => 'Corrisponde al servizio target';

  @override
  String get connectAction => 'Connetti';

  @override
  String get noLogsToExport => 'Nessun log da esportare';

  @override
  String logsCopiedToClipboard(Object count) {
    return 'Log copiati negli appunti ($count elementi)';
  }

  @override
  String get realtimeDataTitle => 'Dati in tempo reale';

  @override
  String get notConnectedNoData => 'Non connesso; impossibile ottenere i dati';

  @override
  String get connectedWaitingData => 'Connesso, in attesa dei dati...';

  @override
  String get sectionSolarPanel => 'Pannello solare';

  @override
  String get sectionBattery => 'Batteria';

  @override
  String get sectionLoad => 'Carico';

  @override
  String get power => 'Potenza';

  @override
  String get voltage => 'Tensione';

  @override
  String get current => 'Corrente';

  @override
  String get temperature => 'Temperatura';

  @override
  String get batterySoc => 'Stato di carica (SOC)';

  @override
  String get switchLabel => 'Interruttore';

  @override
  String get loadOnSent => 'Comando inviato: carico ON';

  @override
  String get loadOffSent => 'Comando inviato: carico OFF';

  @override
  String get sendFailed => 'Invio non riuscito';

  @override
  String get openLoad => 'Attiva carico';

  @override
  String get closeLoad => 'Disattiva carico';

  @override
  String get turnOn => 'Acceso';

  @override
  String get turnOff => 'Spento';

  @override
  String get loadSwitchLabel => 'Interruttore del carico';

  @override
  String get deviceTemperature => 'Temperatura dispositivo';

  @override
  String get historyTitle => 'Storico 30 giorni';

  @override
  String get pullRecent30DaysAction => 'Recupera ultimi 30 giorni';

  @override
  String get noHistoryDataTip => 'Nessuno storico; recupera prima i dati.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get readFailedOrTimeout => 'Lettura fallita o timeout';

  @override
  String get readSettings => 'Leggi impostazioni';

  @override
  String get settingsSentAssumed =>
      'Impostazioni inviate (si presume successo)';

  @override
  String get submitSettings => 'Invia impostazioni';

  @override
  String get modeSelection => 'Selezione modalità';

  @override
  String get modeAuto => 'Automatico';

  @override
  String get modeManual => 'Manuale';

  @override
  String get modeTimed => 'Programmato';

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
  String get batteryType => 'Tipo di batteria';

  @override
  String get batteryLeadAcid => 'Piombo-acido';

  @override
  String get batteryLithium => 'Litio';

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
  String get loadMode => 'Modalità carico';

  @override
  String get loadAlwaysOn => 'Sempre attivo';

  @override
  String get loadLightControl => 'Controllo luce';

  @override
  String get loadPeriod => 'Periodo';

  @override
  String get loadManual => 'Manuale';

  @override
  String get systemVersion => 'Versione sistema';

  @override
  String get overVoltageProtectionV => 'Protezione sovratensione (V)';

  @override
  String get chargingLimitV => 'Limite di carica (V)';

  @override
  String get overDischargeV => 'Tensione di scarica eccessiva (V)';

  @override
  String get dischargeLimitV => 'Limite di scarica (V)';

  @override
  String get reservedField => 'Campo riservato';

  @override
  String get history30DaysColumnsTitle => 'Ultimi 30 giorni';

  @override
  String get dayOffset => 'Offset giornaliero';

  @override
  String get powerGeneration => 'Generazione';

  @override
  String get totalAmount => 'Quantità totale';

  @override
  String get voltageMax => 'Tensione massima';

  @override
  String get voltageMin => 'Tensione minima';

  @override
  String get maxChargingCurrent => 'Corrente di carica max';

  @override
  String get maxDischargingCurrent => 'Corrente di scarica max';

  @override
  String get powerSection => 'Potenza';

  @override
  String get maxChargingPower => 'Potenza di carica max';

  @override
  String get maxDischargingPower => 'Potenza di scarica max';

  @override
  String get overview => 'Panoramica';

  @override
  String get totalPowerGeneration => 'Generazione totale';

  @override
  String get cumulativePowerGeneration => 'Generazione cumulativa';

  @override
  String get scanningInProgress => 'Scansione in corso...';

  @override
  String get scanEnded => 'Scansione terminata';

  @override
  String get scanStopped => 'Scansione interrotta';

  @override
  String get scanReady => 'Ready to scan';

  @override
  String scanFailed(String error) {
    return 'Scansione non riuscita: $error';
  }

  @override
  String connectingTo(String name) {
    return 'Connessione a $name...';
  }

  @override
  String get connectedStatus => 'Connesso';

  @override
  String connectionFailed(String error) {
    return 'Connessione non riuscita: $error';
  }

  @override
  String get bluetoothUnavailable => 'Bluetooth non disponibile';

  @override
  String get pleaseEnableBluetooth => 'Abilita il Bluetooth';

  @override
  String get insufficientPermissions => 'Autorizzazioni insufficienti';

  @override
  String get notFoundDevice => 'Nessun dispositivo trovato';

  @override
  String get disconnectedStatus => 'Disconnesso';

  @override
  String get unexpectedDisconnectStatus => 'Disconnesso (inaspettato)';

  @override
  String get unexpectedDisconnectDialogMessage =>
      'Connessione persa inaspettatamente.';

  @override
  String recentResponseTimeLabel(String time) {
    return 'Ultima risposta: $time';
  }

  @override
  String get closeAction => 'Chiudi';

  @override
  String get clearAction => 'Pulisci';

  @override
  String get deviceNameFilterLabel => 'Filtro:';

  @override
  String get deviceNameFilterPlaceholder => 'es. mock o frammento di nome';

  @override
  String get editNameTooltip => 'Modifica nome';

  @override
  String get editDeviceNameTitle => 'Modifica nome dispositivo';

  @override
  String get aliasInputHint => 'Inserisci alias';

  @override
  String get cancelAction => 'Annulla';

  @override
  String get saveAction => 'Salva';

  @override
  String get aliasesCleared =>
      'Tutti gli alias dei dispositivi sono stati cancellati';

  @override
  String get clearAliases => 'Cancella alias';

  @override
  String get deviceNameTitle => 'Nome dispositivo';

  @override
  String get clearHistory => 'Cancella cronologia';

  @override
  String get settingsWriteSuccess => 'Impostazioni scritte con successo';

  @override
  String get settingsWriteFailedOrTimeout =>
      'Impostazioni non riuscite o timeout';

  @override
  String get settingsWriteFailed => 'Scrittura impostazioni non riuscita';

  @override
  String get pullingData => 'Recupero dei dati...';

  @override
  String get lastFullPullTimeLabel => 'Ultimo recupero completo';

  @override
  String get todaysBatteryCharge => 'Carica batteria';

  @override
  String get todaysOutputEnergy => 'Energia di uscita odierna';

  @override
  String get batteryMaxVLabel => 'Batteria max (V)';

  @override
  String get batteryMinVLabel => 'Batteria min (V)';

  @override
  String get solarPower => 'Potenza solare';

  @override
  String get solarVoltage => 'Tensione solare';

  @override
  String get solarCurrent => 'Corrente solare';

  @override
  String get todaysSolarEnergy => 'Energia solare odierna';

  @override
  String get batteryVoltage => 'Tensione batteria';

  @override
  String get batteryCurrent => 'Corrente batteria';

  @override
  String get batteryTemperature => 'Temperatura batteria';

  @override
  String get loadCurrent => 'Corrente carico';

  @override
  String get loadPower => 'Potenza carico';

  @override
  String get floatChargeV => 'Tensione di carica float (V)';

  @override
  String get chargeReturnV => 'Tensione di ritorno di carica (V)';

  @override
  String get overDischargeReturnV => 'Tensione di ritorno da sovrascarica (V)';

  @override
  String get consumption => 'Consumo';

  @override
  String get loadConsumption => 'Consumo del carico';

  @override
  String get maxPower => 'Potenza massima';

  @override
  String get errors => 'Errori';

  @override
  String get errorCount => 'Numero di errori';

  @override
  String get equalizingChargeV => 'Tensione di carica di equalizzazione (V)';

  @override
  String get boostChargeV => 'Tensione di carica boost (V)';

  @override
  String get incompletePullTip => 'Recupero dati incompleto; riprova';

  @override
  String daysAgoLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni fa',
      one: '$days giorno fa',
      zero: 'Oggi',
    );
    return '$_temp0';
  }

  @override
  String lightControlTimed(Object n) {
    return 'Controllo luce programmato $n';
  }
}
