import 'package:uuid/uuid.dart';
import '../models/call_request.dart';
import '../models/call_type.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  // Inicializar serviço
  Future<void> initialize(String deviceId, String deviceRole) async {
    await _firebaseService.initializeMessaging(deviceId, deviceRole);
  }

  // Enviar chamada (do Dispositivo A para B)
  Future<bool> sendCall({
    required String senderId,
    required String receiverId,
    required CallType type,
    String? message,
  }) async {
    try {
      // Verificar se receptor está online
      final isOnline = await _firebaseService.isReceiverOnline(receiverId);
      
      if (!isOnline) {
        print('Aviso: Receptor pode estar offline');
        // Continuar mesmo assim - Firebase entrega quando dispositivo voltar online
      }

      // Criar objeto de chamada
      final call = CallRequest(
        id: _uuid.v4(),
        type: type,
        timestamp: DateTime.now(),
        senderId: senderId,
        receiverId: receiverId,
        status: CallStatus.pending,
        message: message,
      );

      // Enviar via Firebase
      await _firebaseService.sendCall(call);
      
      print('Chamada enviada com sucesso: ${call.id}');
      return true;
    } catch (e) {
      print('Erro ao enviar chamada: $e');
      return false;
    }
  }

  // Stream de chamadas pendentes (para Dispositivo B)
  Stream<List<CallRequest>> getPendingCalls(String receiverId) {
    return _firebaseService.getPendingCalls(receiverId);
  }

  // Stream de histórico de chamadas
  Stream<List<CallRequest>> getCallHistory(String deviceId, {bool isCaller = false}) {
    return _firebaseService.getAllCalls(deviceId, isCaller: isCaller);
  }

  // Reconhecer/Atender chamada
  Future<void> acknowledgeCall(String callId) async {
    try {
      await _firebaseService.updateCallStatus(callId, CallStatus.acknowledged);
      print('Chamada reconhecida: $callId');
    } catch (e) {
      print('Erro ao reconhecer chamada: $e');
      rethrow;
    }
  }

  // Marcar chamada como em progresso
  Future<void> markInProgress(String callId) async {
    try {
      await _firebaseService.updateCallStatus(callId, CallStatus.inProgress);
      print('Chamada em progresso: $callId');
    } catch (e) {
      print('Erro ao marcar chamada em progresso: $e');
      rethrow;
    }
  }

  // Completar chamada
  Future<void> completeCall(String callId) async {
    try {
      await _firebaseService.updateCallStatus(callId, CallStatus.completed);
      print('Chamada completada: $callId');
    } catch (e) {
      print('Erro ao completar chamada: $e');
      rethrow;
    }
  }

  // Ignorar chamada
  Future<void> ignoreCall(String callId) async {
    try {
      await _firebaseService.updateCallStatus(callId, CallStatus.ignored);
      print('Chamada ignorada: $callId');
    } catch (e) {
      print('Erro ao ignorar chamada: $e');
      rethrow;
    }
  }

  // Atualizar status do dispositivo
  Future<void> updateDeviceStatus(String deviceId, bool isOnline) async {
    await _firebaseService.updateDeviceStatus(deviceId, isOnline);
  }

  // Verificar status do receptor
  Future<bool> isReceiverOnline(String receiverId) async {
    return await _firebaseService.isReceiverOnline(receiverId);
  }

  // Limpar chamadas antigas
  Future<void> cleanOldCalls() async {
    await _firebaseService.cleanOldCalls();
  }

  // Processar chamada recebida (chamar de listener)
  Future<void> processReceivedCall(CallRequest call) async {
    // Mostrar notificação
    await _notificationService.showCallNotification(call);
  }
}
