import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'caller_screen.dart';
import 'receiver_screen.dart';
import '../services/call_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String? _selectedRole;
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _pairedDeviceIdController = TextEditingController();
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _deviceNameController.dispose();
    _pairedDeviceIdController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    // Validações
    if (_selectedRole == null) {
      _showError('Por favor, selecione o papel do dispositivo');
      return;
    }

    // Apenas o CHAMADOR precisa obrigatoriamente do ID do receptor
    if (_selectedRole == 'caller' && _pairedDeviceIdController.text.trim().isEmpty) {
      _showError('Por favor, insira o ID do Receptor');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Gerar ID único para este dispositivo
      final deviceId = _uuid.v4();
      
      // Salvar configurações
      await prefs.setString('deviceId', deviceId);
      await prefs.setString('deviceRole', _selectedRole!);
      await prefs.setString('pairedDeviceId', _pairedDeviceIdController.text.trim());
      await prefs.setString('deviceName', _deviceNameController.text.trim().isEmpty 
          ? 'Dispositivo ${_selectedRole == 'caller' ? 'A' : 'B'}' 
          : _deviceNameController.text.trim());

      // Inicializar serviços
      await CallService().initialize(deviceId, _selectedRole!);

      if (!mounted) return;

      // Navegar para tela apropriada
      if (_selectedRole == 'caller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CallerScreen(
              deviceId: deviceId,
              receiverId: _pairedDeviceIdController.text.trim(),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiverScreen(
              deviceId: deviceId,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao salvar configuração: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração Inicial'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícone
              Icon(
                Icons.settings,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                'Bem-vindo ao Sistema de Chamada',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Configure este dispositivo para começar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Seleção de papel
              Text(
                'Este dispositivo será:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Card Chamador
              _RoleCard(
                title: 'Chamador (Dispositivo A)',
                description: 'Envia solicitações de ajuda',
                icon: Icons.touch_app,
                isSelected: _selectedRole == 'caller',
                onTap: () => setState(() => _selectedRole = 'caller'),
              ),
              const SizedBox(height: 12),

              // Card Receptor
              _RoleCard(
                title: 'Receptor (Dispositivo B)',
                description: 'Recebe e responde solicitações',
                icon: Icons.notifications_active,
                isSelected: _selectedRole == 'receiver',
                onTap: () => setState(() => _selectedRole = 'receiver'),
              ),
              const SizedBox(height: 32),

              // Nome do dispositivo (opcional)
              TextField(
                controller: _deviceNameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Dispositivo (opcional)',
                  hintText: 'Ex: Quarto do Paciente',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 16),

              // ID do dispositivo pareado
              TextField(
                controller: _pairedDeviceIdController,
                decoration: InputDecoration(
                  labelText: _selectedRole == 'caller'
                      ? 'ID do Receptor'
                      : 'ID do Chamador (opcional)',
                  hintText: 'Cole o ID aqui',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.link),
                  helperText: _selectedRole == 'caller'
                      ? 'Obrigatório: ID do dispositivo que receberá as chamadas'
                      : 'Opcional: ID do dispositivo chamador para filtros',
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 32),

              // Informação importante
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Após salvar, você receberá um ID único para compartilhar com o outro dispositivo.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveConfiguration,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar e Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
