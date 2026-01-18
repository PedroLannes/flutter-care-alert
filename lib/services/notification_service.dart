import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/call_request.dart';
import '../models/call_type.dart';
import '../config/app_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inicializar serviço de notificações
  Future<void> initialize() async {
    // Configurações Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Criar canais de notificação
    await _createNotificationChannels();

    // Configurar Firebase Messaging
    await _configureFirebaseMessaging();
  }

  // Criar canais de notificação por prioridade
  Future<void> _createNotificationChannels() async {
    // Canal para chamadas críticas/urgentes
    const criticalChannel = AndroidNotificationChannel(
      AppConfig.criticalChannelId,
      AppConfig.criticalChannelName,
      description: 'Notificações para chamadas urgentes e críticas',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Canal para chamadas normais
    const normalChannel = AndroidNotificationChannel(
      AppConfig.normalChannelId,
      AppConfig.normalChannelName,
      description: 'Notificações para chamadas normais',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(criticalChannel);
    await androidImplementation?.createNotificationChannel(normalChannel);
  }

  // Configurar Firebase Messaging
  Future<void> _configureFirebaseMessaging() async {
    // Solicitar permissões do Firebase Messaging
    final messaging = FirebaseMessaging.instance;
    
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    
    print('🔔 Permissão de notificação: ${settings.authorizationStatus}');
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notificações autorizadas!');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Notificações provisórias');
    } else {
      print('❌ Notificações negadas');
    }

    // Listener para mensagens em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listener para quando usuário toca na notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // Tratar mensagens recebidas quando app está em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      // Extrair dados da chamada
      final callData = message.data;
      
      // Mostrar notificação local
      await _showLocalNotification(
        title: message.notification?.title ?? 'Nova Chamada',
        body: message.notification?.body ?? 'Você tem uma nova solicitação',
        payload: callData['id']?.toString(),
        priority: callData['priority']?.toString() ?? 'medium',
      );
    }
  }

  // Tratar quando usuário abre app através da notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notificação tocada: ${message.data}');
    
    // Extrair ID da chamada
    final callId = message.data['id'] as String?;
    
    if (callId != null) {
      // Marcar chamada como reconhecida automaticamente ao abrir
      _updateCallStatus(callId, CallStatus.acknowledged);
      print('Chamada $callId marcada como reconhecida');
    }
    
    // NOTA: Navegação para tela específica pode ser implementada
    // usando um GlobalKey<NavigatorState> ou package como GetX/GoRouter
    // Por ora, a ReceiverScreen já mostra as chamadas pendentes
  }

  // Mostrar notificação de chamada
  Future<void> showCallNotification(CallRequest call) async {
    final channelId = call.type.priority == 'critical'
        ? AppConfig.criticalChannelId
        : AppConfig.normalChannelId;

    final timeString = DateFormat('HH:mm').format(call.timestamp);

    await _notifications.show(
      call.id.hashCode,
      '${call.type.emoji} ${call.type.label}',
      'Solicitação recebida às $timeString',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == AppConfig.criticalChannelId
              ? AppConfig.criticalChannelName
              : AppConfig.normalChannelName,
          channelDescription: 'Notificação de chamada',
          importance: channelId == AppConfig.criticalChannelId
              ? Importance.max
              : Importance.high,
          priority: channelId == AppConfig.criticalChannelId
              ? Priority.max
              : Priority.high,
          icon: '@mipmap/ic_launcher',
          color: _convertColor(call.type.colorValue),
          actions: [
            const AndroidNotificationAction(
              'acknowledge',
              'Atender',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: call.id,
    );
  }

  // Mostrar notificação genérica
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String priority = 'medium',
  }) async {
    final channelId = priority == 'critical'
        ? AppConfig.criticalChannelId
        : AppConfig.normalChannelId;

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == AppConfig.criticalChannelId
              ? AppConfig.criticalChannelName
              : AppConfig.normalChannelName,
          importance: priority == 'critical' ? Importance.max : Importance.high,
          priority: priority == 'critical' ? Priority.max : Priority.high,
        ),
      ),
      payload: payload,
    );
  }

  // Callback quando notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    
    if (payload != null) {
      print('Notificação tocada com payload: $payload');
      
      // Tratar ações de notificação
      if (response.actionId == 'acknowledge') {
        print('Usuário escolheu ATENDER');
        _updateCallStatus(payload, CallStatus.acknowledged);
        // Cancelar a notificação após reconhecer
        cancelNotification(payload.hashCode);
      } else {
        // Usuário tocou na notificação principal (sem ação específica)
        // Marcar como reconhecida
        _updateCallStatus(payload, CallStatus.acknowledged);
        print('Chamada reconhecida ao tocar na notificação');
      }
    }
  }

  // Atualizar status da chamada no Firestore
  Future<void> _updateCallStatus(String callId, CallStatus newStatus) async {
    try {
      await _firestore
          .collection(AppConfig.callsCollection)
          .doc(callId)
          .update({
        'status': newStatus.name,
      });
      print('✅ Status da chamada $callId atualizado para: ${newStatus.name}');
    } catch (e) {
      print('❌ Erro ao atualizar status da chamada: $e');
    }
  }

  // Cancelar notificação específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Converter valor de cor para uso no Android
  Color? _convertColor(int colorValue) {
    // Retorna null para usar cor padrão do sistema
    // O Android NotificationDetails aceita Color do Flutter
    return Color(colorValue);
  }
}

// Handler para mensagens em background (função top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem recebida em background: ${message.messageId}');
  
  // Processar notificação em background
  if (message.data.isNotEmpty) {
    print('Dados: ${message.data}');
    
    // As notificações em background são tratadas automaticamente pelo FCM
    // O payload é preservado para quando o usuário tocar na notificação
    
    // NOTA: Não é recomendado fazer operações pesadas aqui
    // pois o background handler tem limite de tempo de execução
  }
}
