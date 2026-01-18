import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/call_type.dart';
import '../models/call_request.dart';
import '../services/call_service.dart';
import '../widgets/call_button.dart';
import '../widgets/status_indicator.dart';
import 'setup_screen.dart';

class CallerScreen extends StatefulWidget {
  final String deviceId;
  final String receiverId;

  const CallerScreen({
    super.key,
    required this.deviceId,
    required this.receiverId,
  });

  @override
  State<CallerScreen> createState() => _CallerScreenState();
}

class _CallerScreenState extends State<CallerScreen> with WidgetsBindingObserver {
  final CallService _callService = CallService();
  bool _isSendingCall = false;
  String? _deviceName;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDeviceInfo();
    _updateDeviceStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateDeviceStatus(false);
    super.dispose();
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

  Future<void> _sendCall(CallType type) async {
    if (_isSendingCall) return;

    // Validar se tem receiverId
    if (widget.receiverId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID do Receptor não configurado. Volte para configurações.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSendingCall = true);

    try {
      print('Enviando chamada de ${widget.deviceId} para ${widget.receiverId}');
      
      final success = await _callService.sendCall(
        senderId: widget.deviceId,
        receiverId: widget.receiverId,
        type: type,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Chamada de ${type.label} enviada!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Feedback háptico
        HapticFeedback.mediumImpact();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar chamada. Verifique sua conexão.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('ERRO ao enviar chamada: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingCall = false);
      }
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
            const Text('Compartilhe este ID com o outro dispositivo:'),
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
            const Text('Sistema de Chamada'),
            if (_deviceName != null)
              Text(
                _deviceName!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          StatusIndicator(
            deviceId: widget.deviceId,
            receiverId: widget.receiverId,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'id':
                  _showDeviceIdDialog();
                  break;
                case 'history':
                  setState(() => _showHistory = !_showHistory);
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
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    Text(_showHistory ? 'Ocultar Histórico' : 'Ver Histórico'),
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
      body: Column(
        children: [
          // Grid de botões
          Expanded(
            flex: _showHistory ? 1 : 2,
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                CallButton(
                  type: CallType.bathroom,
                  onPressed: _isSendingCall ? null : () => _sendCall(CallType.bathroom),
                ),
                CallButton(
                  type: CallType.water,
                  onPressed: _isSendingCall ? null : () => _sendCall(CallType.water),
                ),
                CallButton(
                  type: CallType.food,
                  onPressed: _isSendingCall ? null : () => _sendCall(CallType.food),
                ),
                CallButton(
                  type: CallType.medication,
                  onPressed: _isSendingCall ? null : () => _sendCall(CallType.medication),
                ),
                CallButton(
                  type: CallType.help,
                  onPressed: _isSendingCall ? null : () => _sendCall(CallType.help),
                ),
                CallButton(
                  type: CallType.urgent,
                  onPressed: _isSendingCall ? null : () => _sendCall(CallType.urgent),
                ),
              ],
            ),
          ),

          // Histórico (se ativado)
          if (_showHistory)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.history),
                          const SizedBox(width: 8),
                          const Text(
                            'Histórico de Chamadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<CallRequest>>(
                        stream: _callService.getCallHistory(widget.deviceId, isCaller: true),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Nenhuma chamada enviada ainda'),
                            );
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final call = snapshot.data![index];
                              return _HistoryItem(call: call);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final CallRequest call;

  const _HistoryItem({required this.call});

  Color _getStatusColor() {
    switch (call.status) {
      case CallStatus.completed:
        return Colors.green;
      case CallStatus.acknowledged:
      case CallStatus.inProgress:
        return Colors.orange;
      case CallStatus.ignored:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (call.status) {
      case CallStatus.completed:
        return 'Completada';
      case CallStatus.acknowledged:
        return 'Reconhecida';
      case CallStatus.inProgress:
        return 'Em andamento';
      case CallStatus.ignored:
        return 'Ignorada';
      default:
        return 'Pendente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        call.type.emoji,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(call.type.label),
      subtitle: Text(
        '${call.timestamp.day}/${call.timestamp.month} às ${call.timestamp.hour}:${call.timestamp.minute.toString().padLeft(2, '0')}',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getStatusText(),
          style: TextStyle(
            color: _getStatusColor(),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
