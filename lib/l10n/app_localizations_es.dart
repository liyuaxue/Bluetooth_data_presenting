// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SolarPV';

  @override
  String get navRealtime => 'Tiempo real';

  @override
  String get navHistory => 'Historial de 30 días';

  @override
  String get navSettings => 'Configuración';

  @override
  String get connectDevice => 'Conectar dispositivo';

  @override
  String get notConnected => 'No conectado';

  @override
  String get chooseDeviceToConnect => 'Elegir dispositivo para conectar';

  @override
  String get exportLogs => 'Exportar registros';

  @override
  String get logsLabel => 'Registros';

  @override
  String get startScan => 'Iniciar escaneo';

  @override
  String get stopAction => 'Detener';

  @override
  String get disconnect => 'Desconectar';

  @override
  String discoveredCount(int count) {
    return 'Descubiertos: $count';
  }

  @override
  String get noDevicesTip => 'Sin dispositivos, toca “Iniciar escaneo”';

  @override
  String get pleaseConnectDevice => 'Conecta un dispositivo primero';

  @override
  String get pullingHistoryStarted =>
      'Comenzó la obtención de los últimos 30 días';

  @override
  String get settingsRead => 'Configuración cargada';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabledUnknown => 'Deshabilitado/Desconocido';

  @override
  String deviceNameLabel(Object name) {
    return 'Nombre del dispositivo: $name';
  }

  @override
  String remoteIdLabel(Object id) {
    return 'ID remoto: $id';
  }

  @override
  String serviceUuidLabel(Object uuid) {
    return 'UUID del servicio: $uuid';
  }

  @override
  String writeCharacteristicLabel(Object char) {
    return 'Característica de escritura: $char';
  }

  @override
  String notifyCharacteristicLabel(Object char) {
    return 'Característica de notificación: $char';
  }

  @override
  String notifyStatusLabel(Object status) {
    return 'Estado de notificación: $status';
  }

  @override
  String get unnamedDevice => '(Dispositivo sin nombre)';

  @override
  String advertisedNameLabel(Object name) {
    return 'Nombre anunciado: $name';
  }

  @override
  String rssiServicesLabel(Object rssi, Object services) {
    return 'RSSI: $rssi | Servicios: $services';
  }

  @override
  String get matchTargetService => 'Coincide con el servicio objetivo';

  @override
  String get connectAction => 'Conectar';

  @override
  String get noLogsToExport => 'No hay registros para exportar';

  @override
  String logsCopiedToClipboard(Object count) {
    return 'Registros copiados al portapapeles ($count elementos)';
  }

  @override
  String get realtimeDataTitle => 'Datos en tiempo real';

  @override
  String get notConnectedNoData => 'No conectado; no se pueden obtener datos';

  @override
  String get connectedWaitingData => 'Conectado, esperando datos...';

  @override
  String get sectionSolarPanel => 'Panel solar';

  @override
  String get sectionBattery => 'Batería';

  @override
  String get sectionLoad => 'Carga';

  @override
  String get power => 'Potencia';

  @override
  String get voltage => 'Voltaje';

  @override
  String get current => 'Corriente';

  @override
  String get temperature => 'Temperatura';

  @override
  String get batterySoc => 'Estado de carga (SOC)';

  @override
  String get switchLabel => 'Interruptor';

  @override
  String get loadOnSent => 'Comando enviado: activar carga';

  @override
  String get loadOffSent => 'Comando enviado: desactivar carga';

  @override
  String get sendFailed => 'Error al enviar';

  @override
  String get openLoad => 'Activar carga';

  @override
  String get closeLoad => 'Desactivar carga';

  @override
  String get turnOn => 'Encender';

  @override
  String get turnOff => 'Apagar';

  @override
  String get loadSwitchLabel => 'Interruptor de carga';

  @override
  String get deviceTemperature => 'Temperatura del dispositivo';

  @override
  String get historyTitle => 'Historial de 30 días';

  @override
  String get pullRecent30DaysAction => 'Obtener últimos 30 días';

  @override
  String get noHistoryDataTip => 'Sin historial; obtén los datos primero.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get readFailedOrTimeout => 'Lectura fallida o tiempo excedido';

  @override
  String get readSettings => 'Leer ajustes';

  @override
  String get settingsSentAssumed => 'Ajustes enviados (se asume éxito)';

  @override
  String get submitSettings => 'Enviar ajustes';

  @override
  String get modeSelection => 'Selección de modo';

  @override
  String get modeAuto => 'Auto';

  @override
  String get modeManual => 'Manual';

  @override
  String get modeTimed => 'Programado';

  @override
  String get modeEconomy => 'Económico';

  @override
  String get mode12V => '12V';

  @override
  String get mode24V => '24V';

  @override
  String get mode48V => '48V';

  @override
  String get mode96V => '96V';

  @override
  String get batteryType => 'Tipo de batería';

  @override
  String get batteryLeadAcid => 'Plomo-ácido';

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
  String get loadMode => 'Modo de carga';

  @override
  String get loadAlwaysOn => 'Siempre activo';

  @override
  String get loadLightControl => 'Control de luz';

  @override
  String get loadPeriod => 'Período';

  @override
  String get loadManual => 'Manual';

  @override
  String get systemVersion => 'Versión del sistema';

  @override
  String get overVoltageProtectionV => 'Protección de sobretensión (V)';

  @override
  String get chargingLimitV => 'Límite de carga (V)';

  @override
  String get overDischargeV => 'Tensión de descarga excesiva (V)';

  @override
  String get dischargeLimitV => 'Límite de descarga (V)';

  @override
  String get reservedField => 'Campo reservado';

  @override
  String get history30DaysColumnsTitle => 'Últimos 30 días';

  @override
  String get dayOffset => 'Desfase de día';

  @override
  String get powerGeneration => 'Generación';

  @override
  String get totalAmount => 'Cantidad total';

  @override
  String get voltageMax => 'Voltaje máximo';

  @override
  String get voltageMin => 'Voltaje mínimo';

  @override
  String get maxChargingCurrent => 'Corriente de carga máx.';

  @override
  String get maxDischargingCurrent => 'Corriente de descarga máx.';

  @override
  String get powerSection => 'Potencia';

  @override
  String get maxChargingPower => 'Potencia de carga máx.';

  @override
  String get maxDischargingPower => 'Potencia de descarga máx.';

  @override
  String get overview => 'Resumen';

  @override
  String get totalPowerGeneration => 'Generación total';

  @override
  String get cumulativePowerGeneration => 'Generación acumulada';

  @override
  String get scanningInProgress => 'Escaneando...';

  @override
  String get scanEnded => 'Escaneo finalizado';

  @override
  String get scanStopped => 'Escaneo detenido';

  @override
  String get scanReady => 'Ready to scan';

  @override
  String scanFailed(String error) {
    return 'Escaneo fallido: $error';
  }

  @override
  String connectingTo(String name) {
    return 'Conectando a $name...';
  }

  @override
  String get connectedStatus => 'Conectado';

  @override
  String connectionFailed(String error) {
    return 'Conexión fallida: $error';
  }

  @override
  String get bluetoothUnavailable => 'Bluetooth no disponible';

  @override
  String get pleaseEnableBluetooth => 'Por favor, habilita Bluetooth';

  @override
  String get insufficientPermissions => 'Permisos insuficientes';

  @override
  String get notFoundDevice => 'No se encontró dispositivo';

  @override
  String get disconnectedStatus => 'Desconectado';

  @override
  String get unexpectedDisconnectStatus => 'Desconectado (inesperado)';

  @override
  String get unexpectedDisconnectDialogMessage =>
      'La conexión se perdió inesperadamente.';

  @override
  String recentResponseTimeLabel(String time) {
    return 'Última respuesta: $time';
  }

  @override
  String get closeAction => 'Cerrar';

  @override
  String get clearAction => 'Limpiar';

  @override
  String get deviceNameFilterLabel => 'Filtro:';

  @override
  String get deviceNameFilterPlaceholder =>
      'p. ej., mock o fragmento de nombre';

  @override
  String get editNameTooltip => 'Editar nombre';

  @override
  String get editDeviceNameTitle => 'Editar nombre del dispositivo';

  @override
  String get aliasInputHint => 'Introduce alias';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get saveAction => 'Guardar';

  @override
  String get aliasesCleared => 'Se borraron todos los alias de dispositivos';

  @override
  String get clearAliases => 'Borrar alias';

  @override
  String get deviceNameTitle => 'Nombre del dispositivo';

  @override
  String get clearHistory => 'Borrar historial';

  @override
  String get settingsWriteSuccess => 'Configuración escrita correctamente';

  @override
  String get settingsWriteFailedOrTimeout =>
      'Error o tiempo de espera de la configuración';

  @override
  String get settingsWriteFailed => 'Fallo al escribir la configuración';

  @override
  String get pullingData => 'Recuperando datos...';

  @override
  String get lastFullPullTimeLabel => 'Última recuperación completa';

  @override
  String get todaysBatteryCharge => 'Carga de batería';

  @override
  String get todaysOutputEnergy => 'Energía de salida de hoy';

  @override
  String get batteryMaxVLabel => 'Batería máx (V)';

  @override
  String get batteryMinVLabel => 'Batería mín (V)';

  @override
  String get solarPower => 'Potencia solar';

  @override
  String get solarVoltage => 'Voltaje solar';

  @override
  String get solarCurrent => 'Corriente solar';

  @override
  String get todaysSolarEnergy => 'Energía solar de hoy';

  @override
  String get batteryVoltage => 'Voltaje de batería';

  @override
  String get batteryCurrent => 'Corriente de batería';

  @override
  String get batteryTemperature => 'Temperatura de batería';

  @override
  String get loadCurrent => 'Corriente de carga';

  @override
  String get loadPower => 'Potencia de carga';

  @override
  String get floatChargeV => 'Voltaje de carga flotante (V)';

  @override
  String get chargeReturnV => 'Voltaje de retorno de carga (V)';

  @override
  String get overDischargeReturnV => 'Voltaje de retorno de sobredescarga (V)';

  @override
  String get consumption => 'Consumo';

  @override
  String get loadConsumption => 'Consumo de carga';

  @override
  String get maxPower => 'Potencia máxima';

  @override
  String get errors => 'Errores';

  @override
  String get errorCount => 'Número de errores';

  @override
  String get equalizingChargeV => 'Voltaje de carga de ecualización (V)';

  @override
  String get boostChargeV => 'Voltaje de carga de refuerzo (V)';

  @override
  String get incompletePullTip =>
      'Recuperación de datos incompleta; vuelve a intentarlo';

  @override
  String daysAgoLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'hace $days días',
      one: 'hace $days día',
      zero: 'Hoy',
    );
    return '$_temp0';
  }

  @override
  String lightControlTimed(Object n) {
    return 'Control de luz programado $n';
  }
}
