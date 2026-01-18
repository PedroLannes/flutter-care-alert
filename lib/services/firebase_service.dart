import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/call_request.dart';
import '../models/call_type.dart';
import '../config/app_config.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _currentDeviceId;
  String? _fcmToken;

  // Inicializar Firebase Messaging para um dispositivo
  Future<void> initializeMessaging(String deviceId, String deviceRole) async {
    _currentDeviceId = deviceId;

    // Obter token FCM
    _fcmToken = await _messaging.getToken();
    print('FCM Token: $_fcmToken');

    // Salvar informações do dispositivo no Firestore
    await _firestore
        .collection(AppConfig.devicesCollection)
        .doc(deviceId)
        .set({
      'id': deviceId,
      'role': deviceRole,
      'fcmToken': _fcmToken,
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Listener para refresh do token
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _updateDeviceToken(deviceId, newToken);
    });
  }

  // Atualizar token do dispositivo
  Future<void> _updateDeviceToken(String deviceId, String token) async {
    await _firestore
        .collection(AppConfig.devicesCollection)
        .doc(deviceId)
        .update({
      'fcmToken': token,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Enviar chamada
  Future<void> sendCall(CallRequest call) async {
    try {
      print('📤 Enviando chamada para Firestore...');
      print('   ID: ${call.id}');
      print('   De: ${call.senderId}');
      print('   Para: ${call.receiverId}');
      print('   Tipo: ${call.type.label}');
      
      // Salvar chamada no Firestore
      await _firestore
          .collection(AppConfig.callsCollection)
          .doc(call.id)
          .set(call.toFirestore());
      
      print('✅ Chamada salva no Firestore com sucesso!');

      // Obter informações do receptor
      print('🔍 Buscando informações do receptor...');
      final receiverDoc = await _firestore
          .collection(AppConfig.devicesCollection)
          .doc(call.receiverId)
          .get();

      if (receiverDoc.exists) {
        print('✅ Receptor encontrado!');
        final receiverData = receiverDoc.data();
        final receiverToken = receiverData?['fcmToken'] as String?;

        if (receiverToken != null) {
          print('📲 Enviando notificação push...');
          // Criar notificação para enviar via FCM
          await _sendPushNotification(
            token: receiverToken,
            call: call,
          );
          print('✅ Notificação enviada!');
        } else {
          print('⚠️  Receptor sem FCM token');
        }
      } else {
        print('❌ Receptor não encontrado no Firestore!');
      }
    } catch (e) {
      print('❌ Erro ao enviar chamada: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Enviar notificação push via FCM
  Future<void> _sendPushNotification({
    required String token,
    required CallRequest call,
  }) async {
    // Criar documento de notificação que será processado por Cloud Functions
    // NOTA: Você precisará criar uma Cloud Function para enviar as notificações
    // Por enquanto, salvamos no Firestore para trigger
    await _firestore.collection(AppConfig.notificationsCollection).add({
      'token': token,
      'title': '${call.type.emoji} ${call.type.label}',
      'body': 'Nova solicitação de ${call.type.label.toLowerCase()}',
      'data': call.toFirestore(),
      'priority': call.type.priority,
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }

  // Stream de chamadas pendentes para um receptor
  Stream<List<CallRequest>> getPendingCalls(String receiverId) {
    return _firestore
        .collection(AppConfig.callsCollection)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: CallStatus.pending.name)
        .orderBy('timestamp', descending: true)
        .limit(AppConfig.maxPendingCalls)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CallRequest.fromFirestore(doc.data());
      }).toList();
    });
  }

  // Stream de todas as chamadas (para histórico)
  Stream<List<CallRequest>> getAllCalls(String deviceId, {bool isCaller = false}) {
    final field = isCaller ? 'senderId' : 'receiverId';
    
    return _firestore
        .collection(AppConfig.callsCollection)
        .where(field, isEqualTo: deviceId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final calls = snapshot.docs.map((doc) {
        return CallRequest.fromFirestore(doc.data());
      }).toList();
      
      // DEBUG: Log para verificar se está retornando dados
      print('📊 Histórico - Dispositivo: $deviceId, Tipo: ${isCaller ? 'Chamador' : 'Receptor'}, Chamadas: ${calls.length}');
      if (calls.isEmpty) {
        print('⚠️  Atenção: Nenhuma chamada encontrada! Verifique se os índices do Firestore estão criados.');
      }
      
      return calls;
    });
  }

  // Stream alternativo sem ordenação (não requer índices) - use se problemas com índices
  Stream<List<CallRequest>> getAllCallsUnordered(String deviceId, {bool isCaller = false}) {
    final field = isCaller ? 'senderId' : 'receiverId';
    
    return _firestore
        .collection(AppConfig.callsCollection)
        .where(field, isEqualTo: deviceId)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final calls = snapshot.docs.map((doc) {
        return CallRequest.fromFirestore(doc.data());
      }).toList();
      
      // Ordenar no app (se índices não estiverem configurados)
      calls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      print('📊 Histórico (sem índices) - Dispositivo: $deviceId, Chamadas: ${calls.length}');
      
      return calls;
    });
  }

  // Atualizar status de uma chamada
  Future<void> updateCallStatus(String callId, CallStatus newStatus) async {
    try {
      await _firestore
          .collection(AppConfig.callsCollection)
          .doc(callId)
          .update({
        'status': newStatus.name,
      });
    } catch (e) {
      print('Erro ao atualizar status da chamada: $e');
      rethrow;
    }
  }

  // Marcar dispositivo como online/offline
  Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    await _firestore
        .collection(AppConfig.devicesCollection)
        .doc(deviceId)
        .update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Obter informações de um dispositivo
  Future<Map<String, dynamic>?> getDeviceInfo(String deviceId) async {
    final doc = await _firestore
        .collection(AppConfig.devicesCollection)
        .doc(deviceId)
        .get();
    
    return doc.data();
  }

  // Verificar se receptor está online
  Future<bool> isReceiverOnline(String receiverId) async {
    final deviceInfo = await getDeviceInfo(receiverId);
    if (deviceInfo == null) return false;
    
    final isOnline = deviceInfo['isOnline'] as bool? ?? false;
    final lastSeen = deviceInfo['lastSeen'] as Timestamp?;
    
    if (lastSeen != null) {
      final lastSeenDate = lastSeen.toDate();
      final diff = DateTime.now().difference(lastSeenDate);
      
      // Considerar offline se última vez visto foi há mais de 5 minutos
      if (diff.inMinutes > 5) return false;
    }
    
    return isOnline;
  }

  // Limpar chamadas antigas (manutenção)
  Future<void> cleanOldCalls() async {
    final cutoffDate = DateTime.now().subtract(
      Duration(days: AppConfig.historyDaysToKeep),
    );
    
    final oldCalls = await _firestore
        .collection(AppConfig.callsCollection)
        .where('timestamp', isLessThan: cutoffDate.toIso8601String())
        .get();
    
    final batch = _firestore.batch();
    for (var doc in oldCalls.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('Limpeza: ${oldCalls.docs.length} chamadas antigas removidas');
  }

  // Obter FCM token atual
  String? get fcmToken => _fcmToken;

  // Obter device ID atual
  String? get currentDeviceId => _currentDeviceId;
}
