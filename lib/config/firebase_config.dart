import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  // IMPORTANTE: Substitua estes valores pelos do seu projeto Firebase
  // Acesse: https://console.firebase.google.com/
  // 1. Crie um novo projeto
  // 2. Adicione um app Android
  // 3. Baixe o arquivo google-services.json
  // 4. Copie os valores abaixo do arquivo google-services.json
  
  static FirebaseOptions get currentPlatform {
    // Valores do google-services.json do projeto Firebase
    return const FirebaseOptions(
      apiKey: 'SUA_API_KEY_AQUI',
      appId: 'SEU_APP_ID_AQUI',
      messagingSenderId: 'SEU_SENDER_ID',
      projectId: 'seu-project-id',
      storageBucket: 'seu-project-id.firebasestorage.app',
    );
  }
}

// INSTRUÇÕES PARA CONFIGURAR:
// 
// 1. Acesse: https://console.firebase.google.com/
// 2. Clique em "Adicionar projeto"
// 3. Siga o assistente de criação
// 4. No painel do projeto, clique em "Adicionar app" > Android
// 5. Preencha:
//    - Nome do pacote Android: com.example.call_system
//    - Apelido do app: Call System
// 6. Baixe o arquivo google-services.json
// 7. Coloque em: android/app/google-services.json
// 8. Copie os valores e substitua acima
// 
// 9. No Firebase Console, ative:
//    - Cloud Firestore
//    - Cloud Messaging
// 
// 10. Configure as regras de segurança do Firestore (veja firestore_rules.txt)
