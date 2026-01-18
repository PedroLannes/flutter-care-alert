class AppConfig {
  // Versão do app
  static const String appVersion = '1.0.0';
  static const String appName = 'Sistema de Chamada';
  
  // Configurações de notificação
  static const String normalChannelId = 'normal_calls';
  static const String criticalChannelId = 'critical_calls';
  static const String normalChannelName = 'Chamadas Normais';
  static const String criticalChannelName = 'Chamadas Urgentes';
  
  // Configurações de timeout
  static const Duration callTimeout = Duration(minutes: 5);
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // Configurações de rede local (Fase 2)
  static const int websocketPort = 8080;
  static const String mdnsServiceType = '_callsystem._tcp';
  
  // Firestore collections
  static const String callsCollection = 'calls';
  static const String devicesCollection = 'devices';
  static const String notificationsCollection = 'notifications';
  
  // Limites
  static const int maxPendingCalls = 50;
  static const int historyDaysToKeep = 7;
}
