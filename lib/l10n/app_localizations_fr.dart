// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SolarPV';

  @override
  String get navRealtime => 'Temps réel';

  @override
  String get navHistory => 'Historique 30 jours';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get connectDevice => 'Connecter un appareil';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get chooseDeviceToConnect => 'Choisir un appareil à connecter';

  @override
  String get exportLogs => 'Exporter les journaux';

  @override
  String get logsLabel => 'Journaux';

  @override
  String get startScan => 'Démarrer le scan';

  @override
  String get stopAction => 'Arrêter';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String discoveredCount(int count) {
    return 'Découverts : $count';
  }

  @override
  String get noDevicesTip => 'Aucun appareil, touchez « Démarrer le scan »';

  @override
  String get pleaseConnectDevice => 'Veuillez d\'abord connecter un appareil';

  @override
  String get pullingHistoryStarted =>
      'Récupération des 30 derniers jours démarrée';

  @override
  String get settingsRead => 'Paramètres chargés';

  @override
  String get enabled => 'Activé';

  @override
  String get disabledUnknown => 'Désactivé/Inconnu';

  @override
  String deviceNameLabel(Object name) {
    return 'Nom de l’appareil : $name';
  }

  @override
  String remoteIdLabel(Object id) {
    return 'ID distante : $id';
  }

  @override
  String serviceUuidLabel(Object uuid) {
    return 'UUID du service : $uuid';
  }

  @override
  String writeCharacteristicLabel(Object char) {
    return 'Caractéristique d’écriture : $char';
  }

  @override
  String notifyCharacteristicLabel(Object char) {
    return 'Caractéristique de notification : $char';
  }

  @override
  String notifyStatusLabel(Object status) {
    return 'Statut de notification : $status';
  }

  @override
  String get unnamedDevice => '(Appareil sans nom)';

  @override
  String advertisedNameLabel(Object name) {
    return 'Nom diffusé : $name';
  }

  @override
  String rssiServicesLabel(Object rssi, Object services) {
    return 'RSSI : $rssi | Services : $services';
  }

  @override
  String get matchTargetService => 'Correspond au service cible';

  @override
  String get connectAction => 'Connecter';

  @override
  String get noLogsToExport => 'Aucun journal à exporter';

  @override
  String logsCopiedToClipboard(Object count) {
    return 'Journaux copiés dans le presse-papiers ($count éléments)';
  }

  @override
  String get realtimeDataTitle => 'Données en temps réel';

  @override
  String get notConnectedNoData =>
      'Non connecté ; impossible de récupérer les données';

  @override
  String get connectedWaitingData => 'Connecté, en attente de données…';

  @override
  String get sectionSolarPanel => 'Panneau solaire';

  @override
  String get sectionBattery => 'Batterie';

  @override
  String get sectionLoad => 'Charge';

  @override
  String get power => 'Puissance';

  @override
  String get voltage => 'Tension';

  @override
  String get current => 'Courant';

  @override
  String get temperature => 'Température';

  @override
  String get batterySoc => 'État de charge (SOC)';

  @override
  String get switchLabel => 'Interrupteur';

  @override
  String get loadOnSent => 'Commande envoyée : activer la charge';

  @override
  String get loadOffSent => 'Commande envoyée : désactiver la charge';

  @override
  String get sendFailed => 'Échec de l’envoi';

  @override
  String get openLoad => 'Activer la charge';

  @override
  String get closeLoad => 'Désactiver la charge';

  @override
  String get turnOn => 'Activer';

  @override
  String get turnOff => 'Désactiver';

  @override
  String get loadSwitchLabel => 'Interrupteur de charge';

  @override
  String get deviceTemperature => 'Température de l’appareil';

  @override
  String get historyTitle => 'Historique sur 30 jours';

  @override
  String get pullRecent30DaysAction => 'Récupérer les 30 derniers jours';

  @override
  String get noHistoryDataTip =>
      'Aucun historique ; récupérez d’abord les données.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get readFailedOrTimeout => 'Échec de lecture ou délai dépassé';

  @override
  String get readSettings => 'Lire les paramètres';

  @override
  String get settingsSentAssumed => 'Paramètres envoyés (succès supposé)';

  @override
  String get submitSettings => 'Envoyer les paramètres';

  @override
  String get modeSelection => 'Sélection du mode';

  @override
  String get modeAuto => 'Auto';

  @override
  String get modeManual => 'Manuel';

  @override
  String get modeTimed => 'Programmée';

  @override
  String get modeEconomy => 'Éco';

  @override
  String get mode12V => '12V';

  @override
  String get mode24V => '24V';

  @override
  String get mode48V => '48V';

  @override
  String get mode96V => '96V';

  @override
  String get batteryType => 'Type de batterie';

  @override
  String get batteryLeadAcid => 'Plomb-acide';

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
  String get loadMode => 'Mode de charge';

  @override
  String get loadAlwaysOn => 'Toujours activé';

  @override
  String get loadLightControl => 'Contrôle par lumière';

  @override
  String get loadPeriod => 'Période';

  @override
  String get loadManual => 'Manuel';

  @override
  String get systemVersion => 'Version du système';

  @override
  String get overVoltageProtectionV => 'Protection surtension (V)';

  @override
  String get chargingLimitV => 'Limite de charge (V)';

  @override
  String get overDischargeV => 'Tension de décharge excessive (V)';

  @override
  String get dischargeLimitV => 'Limite de décharge (V)';

  @override
  String get reservedField => 'Champ réservé';

  @override
  String get history30DaysColumnsTitle => '30 derniers jours';

  @override
  String get dayOffset => 'Décalage de jour';

  @override
  String get powerGeneration => 'Production';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get voltageMax => 'Tension maximale';

  @override
  String get voltageMin => 'Tension minimale';

  @override
  String get maxChargingCurrent => 'Courant de charge max';

  @override
  String get maxDischargingCurrent => 'Courant de décharge max';

  @override
  String get powerSection => 'Puissance';

  @override
  String get maxChargingPower => 'Puissance de charge max';

  @override
  String get maxDischargingPower => 'Puissance de décharge max';

  @override
  String get overview => 'Aperçu';

  @override
  String get totalPowerGeneration => 'Production totale';

  @override
  String get cumulativePowerGeneration => 'Production cumulée';

  @override
  String get scanningInProgress => 'Analyse en cours...';

  @override
  String get scanEnded => 'Analyse terminée';

  @override
  String get scanStopped => 'Analyse arrêtée';

  @override
  String get scanReady => 'Ready to scan';

  @override
  String scanFailed(String error) {
    return 'Analyse échouée : $error';
  }

  @override
  String connectingTo(String name) {
    return 'Connexion à $name...';
  }

  @override
  String get connectedStatus => 'Connecté';

  @override
  String connectionFailed(String error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String get bluetoothUnavailable => 'Bluetooth non disponible';

  @override
  String get pleaseEnableBluetooth => 'Veuillez activer le Bluetooth';

  @override
  String get insufficientPermissions => 'Autorisations insuffisantes';

  @override
  String get notFoundDevice => 'Aucun appareil trouvé';

  @override
  String get disconnectedStatus => 'Déconnecté';

  @override
  String get unexpectedDisconnectStatus => 'Déconnexion inattendue';

  @override
  String get unexpectedDisconnectDialogMessage =>
      'La connexion a été interrompue de manière inattendue.';

  @override
  String recentResponseTimeLabel(String time) {
    return 'Dernière réponse : $time';
  }

  @override
  String get closeAction => 'Fermer';

  @override
  String get clearAction => 'Effacer';

  @override
  String get deviceNameFilterLabel => 'Filtre:';

  @override
  String get deviceNameFilterPlaceholder => 'ex. mock ou fragment de nom';

  @override
  String get editNameTooltip => 'Modifier le nom';

  @override
  String get editDeviceNameTitle => 'Modifier le nom de l’appareil';

  @override
  String get aliasInputHint => 'Saisir un alias';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get saveAction => 'Enregistrer';

  @override
  String get aliasesCleared => 'Tous les alias d’appareil ont été supprimés';

  @override
  String get clearAliases => 'Effacer les alias';

  @override
  String get deviceNameTitle => 'Nom de l’appareil';

  @override
  String get clearHistory => 'Effacer l’historique';

  @override
  String get settingsWriteSuccess => 'Paramètres écrits avec succès';

  @override
  String get settingsWriteFailedOrTimeout =>
      'Échec ou délai d’écriture des paramètres';

  @override
  String get settingsWriteFailed => 'Échec d’écriture des paramètres';

  @override
  String get pullingData => 'Récupération des données...';

  @override
  String get lastFullPullTimeLabel => 'Dernière récupération complète';

  @override
  String get todaysBatteryCharge => 'Charge de batterie';

  @override
  String get todaysOutputEnergy => 'Énergie de sortie du jour';

  @override
  String get batteryMaxVLabel => 'Batterie maxi (V)';

  @override
  String get batteryMinVLabel => 'Batterie mini (V)';

  @override
  String get solarPower => 'Puissance solaire';

  @override
  String get solarVoltage => 'Tension solaire';

  @override
  String get solarCurrent => 'Courant solaire';

  @override
  String get todaysSolarEnergy => 'Énergie solaire du jour';

  @override
  String get batteryVoltage => 'Tension batterie';

  @override
  String get batteryCurrent => 'Courant batterie';

  @override
  String get batteryTemperature => 'Température de la batterie';

  @override
  String get loadCurrent => 'Courant de charge';

  @override
  String get loadPower => 'Puissance de charge';

  @override
  String get floatChargeV => 'Tension de charge flottante (V)';

  @override
  String get chargeReturnV => 'Tension de retour de charge (V)';

  @override
  String get overDischargeReturnV => 'Tension de retour de surdécharge (V)';

  @override
  String get consumption => 'Consommation';

  @override
  String get loadConsumption => 'Consommation de la charge';

  @override
  String get maxPower => 'Puissance maximale';

  @override
  String get errors => 'Erreurs';

  @override
  String get errorCount => 'Nombre d\'erreurs';

  @override
  String get equalizingChargeV => 'Tension de charge d\'égalisation (V)';

  @override
  String get boostChargeV => 'Tension de charge d\'appoint (V)';

  @override
  String get incompletePullTip =>
      'Récupération des données incomplète ; veuillez réessayer';

  @override
  String daysAgoLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'il y a $days jours',
      one: 'il y a $days jour',
      zero: 'Aujourd’hui',
    );
    return '$_temp0';
  }

  @override
  String lightControlTimed(Object n) {
    return 'Contrôle par lumière programmé $n';
  }
}
