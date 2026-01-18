import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/firebase_config.dart';
import 'services/notification_service.dart';
import 'screens/setup_screen.dart';
import 'screens/caller_screen.dart';
import 'screens/receiver_screen.dart';

// Handler para mensagens em background (fora do app)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
  print('🔔 Mensagem recebida em background: ${message.notification?.title}');
  
  // Notificação local será mostrada automaticamente pelo Firebase
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (verificar se já foi inicializado)
  try {
    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase já foi inicializado');
    } else {
      rethrow;
    }
  }
  
  // Configurar handler para mensagens em background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Inicializar serviço de notificações
  await NotificationService().initialize();
  
  runApp(const CallSystemApp());
}

class CallSystemApp extends StatelessWidget {
  const CallSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Chamada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  Future<void> _checkConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceRole = prefs.getString('deviceRole');
    final deviceId = prefs.getString('deviceId');

    if (!mounted) return;

    // Verifica se tem role e ID (pairedDeviceId é opcional para receptor)
    if (deviceRole == null || deviceId == null) {
      // Primeira execução - mostrar tela de configuração
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupScreen()),
      );
    } else {
      // Configuração existe - ir para tela apropriada
      if (deviceRole == 'caller') {
        final pairedDeviceId = prefs.getString('pairedDeviceId') ?? '';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CallerScreen(
            deviceId: deviceId,
            receiverId: pairedDeviceId,
          )),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ReceiverScreen(
            deviceId: deviceId,
          )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
