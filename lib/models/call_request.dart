import 'call_type.dart';

class CallRequest {
  final String id;
  final CallType type;
  final DateTime timestamp;
  final String senderId;
  final String receiverId;
  final CallStatus status;
  final String? message;

  CallRequest({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    this.status = CallStatus.pending,
    this.message,
  });

  // Conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'message': message,
    };
  }

  // Conversão de Firestore
  factory CallRequest.fromFirestore(Map<String, dynamic> data) {
    return CallRequest(
      id: data['id'] as String,
      type: CallType.values.byName(data['type'] as String),
      timestamp: DateTime.parse(data['timestamp'] as String),
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      status: CallStatus.values.byName(data['status'] as String),
      message: data['message'] as String?,
    );
  }

  // Copiar com alterações
  CallRequest copyWith({
    String? id,
    CallType? type,
    DateTime? timestamp,
    String? senderId,
    String? receiverId,
    CallStatus? status,
    String? message,
  }) {
    return CallRequest(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
