import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/call_request.dart';
import '../services/call_service.dart';
import '../services/notification_service.dart';
import '../widgets/call_card.dart';
import 'setup_screen.dart';

class ReceiverScreen extends StatefulWidget {
  final String deviceId;

  const ReceiverScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen>
    with WidgetsBindingObserver {
  final CallService _callService = CallService();
  final NotificationService _notificationService = NotificationService();
  String? _deviceName;
  StreamSubscription<List<CallRequest>>? _callsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDeviceInfo();
    _updateDeviceStatus(true);
    _listenForNewCalls();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateDeviceStatus(false);
    _callsSubscription?.cancel();
    super.dispose();
  }

  // Escutar novas chamadas em tempo real e mostrar notificação
  void _listenForNewCalls() {
    _callsSubscription = _callService.getPendingCalls(widget.deviceId).listen((calls) {
      if (calls.isNotEmpty) {
        // Pegar a chamada mais recente
        final latestCall = calls.first;
        
        // Mostrar notificação local com som
        _notificationService.showCallNotification(latestCall);
        
        print('🔔 Nova chamada recebida: ${latestCall.type.label}');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateDeviceStatus(true);
    } else if (state == AppLifecycleState.paused) {
      _updateDeviceStatus(false);
    }
  }

  Future<void> _loadDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _deviceName = prefs.getString('deviceName');
    });
  }

  Future<void> _updateDeviceStatus(bool isOnline) async {
    try {
      await _callService.updateDeviceStatus(widget.deviceId, isOnline);
    } catch (e) {
      print('Erro ao atualizar status: $e');
    }
  }

  Future<void> _dismissCall(CallRequest call) async {
    try {
      await _callService.completeCall(call.id);
      
      if (!mounted) return;
      
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notificação dispensada: ${call.type.label}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDeviceIdDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ID deste Dispositivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Compartilhe este ID com o dispositivo chamador:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                widget.deviceId,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.deviceId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ID copiado!')),
              );
            },
            child: const Text('Copiar ID'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetConfiguration() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Configuração?'),
        content: const Text(
          'Isto irá limpar todas as configurações e você precisará configurar o dispositivo novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recepção de Chamadas'),
            if (_deviceName != null)
              Text(
                _deviceName!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'id':
                  _showDeviceIdDialog();
                  break;
                case 'reset':
                  _resetConfiguration();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'id',
                child: Row(
                  children: [
                    Icon(Icons.qr_code),
                    SizedBox(width: 8),
                    Text('Ver ID'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.settings_backup_restore, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Resetar Config', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<CallRequest>>(
        stream: _callService.getPendingCalls(widget.deviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma chamada pendente',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aguardando solicitações...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final call = snapshot.data![index];
              return CallCard(
                call: call,
                onDismiss: () => _dismissCall(call),
              );
            },
          );
        },
      ),
    );
  }
}
