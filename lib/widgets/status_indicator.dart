import 'package:flutter/material.dart';
import '../services/call_service.dart';

class StatusIndicator extends StatefulWidget {
  final String deviceId;
  final String receiverId;

  const StatusIndicator({
    super.key,
    required this.deviceId,
    required this.receiverId,
  });

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> {
  final CallService _callService = CallService();
  bool _isOnline = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Verificar status periodicamente
    Future.delayed(const Duration(seconds: 30), _periodicCheck);
  }

  Future<void> _periodicCheck() async {
    if (!mounted) return;
    await _checkStatus();
    Future.delayed(const Duration(seconds: 30), _periodicCheck);
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    
    setState(() => _isChecking = true);
    
    try {
      final isOnline = await _callService.isReceiverOnline(widget.receiverId);
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnline = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: _isOnline
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: _isOnline ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
