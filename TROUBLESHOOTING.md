# 🔧 Troubleshooting Detalhado

## 🚨 Problemas Comuns e Soluções

---

## 1. Erros de Compilação

### ❌ Erro: "Execution failed for task ':app:processDebugGoogleServices'"

**Causa:** Arquivo `google-services.json` inválido ou ausente

**Solução:**
```bash
# 1. Verificar se arquivo existe
ls android/app/google-services.json

# 2. Baixar novo do Firebase Console
# Firebase Console → Configurações do Projeto → Apps → Download

# 3. Substituir arquivo

# 4. Limpar e recompilar
flutter clean
flutter pub get
flutter build apk
```

---

### ❌ Erro: "Plugin google-services not found"

**Causa:** Plugin não adicionado ao `build.gradle`

**Solução:**

Arquivo `android/build.gradle`:
```gradle
dependencies {
    // Adicionar esta linha
    classpath 'com.google.gms:google-services:4.4.0'
}
```

Arquivo `android/app/build.gradle`:
```gradle
plugins {
    // Adicionar esta linha
    id "com.google.gms.google-services"
}
```

---

### ❌ Erro: "Minimum supported Gradle version is X.X"

**Solução:**

Edite `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

---

### ❌ Erro: "Namespace not specified"

**Solução:**

Em `android/app/build.gradle`, adicione no topo:
```gradle
android {
    namespace "com.example.call_system"
    // resto do código...
}
```

---

## 2. Problemas de Notificações

### ❌ Notificações não chegam com app fechado

**Diagnóstico:**
```dart
// Adicione logs em main.dart
FirebaseMessaging.onBackgroundMessage((message) async {
  print('📥 Mensagem background: ${message.messageId}');
});
```

**Soluções:**

1. **Verificar permissões:**
```bash
# Via ADB
adb shell dumpsys notification_listener
```

2. **Testar notificação manual:**
```bash
# Firebase Console → Cloud Messaging → Enviar teste
# Cole o FCM token do dispositivo
```

3. **Verificar otimização de bateria:**
- Configurações → Apps → Sistema de Chamada
- Bateria → Sem restrições

4. **Desativar otimização do fabricante:**
```
Xiaomi: Autostart + Sem restrições
Samsung: Não otimizar bateria
Huawei: App protegido
```

---

### ❌ FCM Token é null

**Diagnóstico:**
```dart
// Em firebase_service.dart
final token = await _messaging.getToken();
print('🔑 FCM Token: $token');
if (token == null) {
  print('❌ Token é null - verificar Google Play Services');
}
```

**Soluções:**

1. Verificar Google Play Services no dispositivo
2. Aguardar alguns segundos (token é assíncrono)
3. Verificar permissões de notificação
4. Reinstalar app

---

### ❌ Notificações não fazem som

**Solução:**

Verificar canais de notificação:
```dart
// Em notification_service.dart
const channel = AndroidNotificationChannel(
  'critical_calls',
  'Chamadas Urgentes',
  importance: Importance.max,  // IMPORTANTE
  playSound: true,              // IMPORTANTE
  enableVibration: true,        // IMPORTANTE
);
```

Testar configurações do Android:
- Configurações → Notificações → Sistema de Chamada
- Verificar se som está ativo para cada canal

---

## 3. Problemas de Firestore

### ❌ Erro: "PERMISSION_DENIED: Missing or insufficient permissions"

**Causa:** Regras de segurança muito restritivas

**Solução:**

Firebase Console → Firestore → Regras:
```javascript
// TEMPORÁRIO (apenas desenvolvimento)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**⚠️ IMPORTANTE:** Isso permite acesso total! Use apenas para testes.

---

### ❌ Dados não aparecem no Firestore

**Diagnóstico:**
```dart
// Adicione logs em firebase_service.dart
await _firestore.collection('calls').doc(call.id).set(call.toFirestore());
print('✅ Chamada salva no Firestore: ${call.id}');

// Verificar documento
final doc = await _firestore.collection('calls').doc(call.id).get();
print('📄 Documento existe: ${doc.exists}');
print('📄 Dados: ${doc.data()}');
```

**Soluções:**
1. Verificar conexão com internet
2. Verificar regras de segurança
3. Verificar se projeto Firebase está correto
4. Ver logs de erro no Firebase Console

---

### ❌ Stream não atualiza em tempo real

**Diagnóstico:**
```dart
_firestore
    .collection('calls')
    .where('receiverId', isEqualTo: receiverId)
    .snapshots()
    .listen((snapshot) {
      print('🔄 Stream atualizado: ${snapshot.docs.length} documentos');
      for (var doc in snapshot.docs) {
        print('  - ${doc.id}: ${doc.data()}');
      }
    });
```

**Soluções:**
1. Verificar se índice composto é necessário
2. Verificar internet
3. Aguardar alguns segundos (pode ter delay)
4. Reiniciar app

---

## 4. Problemas de Conexão

### ❌ Status sempre "Offline"

**Diagnóstico:**
```dart
// Em call_service.dart
final isOnline = await _firebaseService.isReceiverOnline(receiverId);
print('🟢 Receptor online? $isOnline');

final deviceInfo = await _firebaseService.getDeviceInfo(receiverId);
print('📱 Info do dispositivo: $deviceInfo');
```

**Soluções:**

1. **Verificar se dispositivo B registrou token:**
```dart
// No Dispositivo B, verificar:
final myDoc = await FirebaseFirestore.instance
    .collection('devices')
    .doc(myDeviceId)
    .get();
print('Meu FCM Token: ${myDoc.data()?['fcmToken']}');
```

2. **Verificar ID do dispositivo:**
- IDs devem ser únicos (UUID)
- Copiar/colar com cuidado (sem espaços)

3. **Atualizar status manualmente:**
```dart
await CallService().updateDeviceStatus(deviceId, true);
```

---

### ❌ Erro de timeout

**Causa:** Conexão lenta ou firewall bloqueando

**Solução:**

Aumentar timeout:
```dart
// Em app_config.dart
static const Duration connectionTimeout = Duration(seconds: 30);

// Em firebase_service.dart
await _firestore
    .collection('devices')
    .doc(deviceId)
    .get()
    .timeout(AppConfig.connectionTimeout);
```

---

## 5. Problemas de Interface

### ❌ Botões não respondem

**Diagnóstico:**
```dart
// Em call_button.dart
onTap: () {
  print('🖱️ Botão pressionado: ${type.label}');
  if (onPressed != null) {
    onPressed!();
  } else {
    print('❌ onPressed é null');
  }
}
```

**Soluções:**
1. Verificar se `_isSendingCall` está travado como `true`
2. Aguardar resposta de chamada anterior
3. Reiniciar app

---

### ❌ StreamBuilder não mostra dados

**Diagnóstico:**
```dart
StreamBuilder<List<CallRequest>>(
  stream: _callService.getPendingCalls(widget.deviceId),
  builder: (context, snapshot) {
    print('📊 ConnectionState: ${snapshot.connectionState}');
    print('📊 HasData: ${snapshot.hasData}');
    print('📊 HasError: ${snapshot.hasError}');
    if (snapshot.hasError) print('❌ Erro: ${snapshot.error}');
    if (snapshot.hasData) print('📊 Dados: ${snapshot.data!.length}');
    
    // resto do código...
  },
)
```

**Soluções:**
1. Verificar se stream não tem erros
2. Verificar connectionState (waiting vs active)
3. Forçar rebuild com setState
4. Verificar se receiverId está correto

---

## 6. Problemas de Performance

### ❌ App lento / travando

**Soluções:**

1. **Limitar queries:**
```dart
.limit(50)  // Máximo 50 documentos
```

2. **Usar índices no Firestore:**
- Firebase Console → Firestore → Índices
- Criar índices compostos para queries complexas

3. **Paginação:**
```dart
// Carregar em partes
Query query = _firestore
    .collection('calls')
    .limit(20);

// Próxima página
query = query.startAfterDocument(lastDocument);
```

4. **Cache:**
```dart
// Habilitar cache offline
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 7. Problemas Específicos do Android

### ❌ App fecha ao abrir (crash imediato)

**Ver logs:**
```bash
# Conectar dispositivo via USB
adb logcat | grep -i flutter

# Ou filtrar apenas erros
adb logcat *:E | grep flutter
```

**Causas comuns:**
1. Firebase não inicializado
2. Configuração inválida
3. Permissões ausentes
4. Dependências conflitantes

---

### ❌ Notificações param de funcionar após update

**Solução:**
```bash
# Limpar cache do app
adb shell pm clear com.example.call_system

# Reinstalar
flutter clean
flutter run --release
```

---

### ❌ "Unhandled Exception: MissingPluginException"

**Causa:** Plugin não registrado corretamente

**Solução:**
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ..
flutter run
```

---

## 8. Debugging Avançado

### Habilitar logs verbose

```dart
// Em main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Debug mode
  if (kDebugMode) {
    print('🐛 Modo DEBUG ativado');
    
    // Logs do Firebase
    FirebaseFirestore.setLoggingEnabled(true);
  }
  
  // resto do código...
}
```

### Testar comunicação manualmente

```dart
// Criar chamada de teste
Future<void> testCall() async {
  final testCall = CallRequest(
    id: 'test-123',
    type: CallType.urgent,
    timestamp: DateTime.now(),
    senderId: 'sender-test',
    receiverId: 'receiver-test',
  );
  
  await FirebaseFirestore.instance
      .collection('calls')
      .doc(testCall.id)
      .set(testCall.toFirestore());
  
  print('✅ Chamada de teste criada');
}
```

### Verificar todas as dependências

```bash
flutter doctor -v
flutter pub deps
```

---

## 9. Reset Completo

Se nada funcionar:

```bash
# 1. Limpar completamente
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm pubspec.lock

# 2. Reinstalar dependências
flutter pub get

# 3. Limpar Android
cd android && ./gradlew clean && cd ..

# 4. Recompilar
flutter build apk --release

# 5. Desinstalar app do dispositivo
adb uninstall com.example.call_system

# 6. Instalar novamente
flutter install --release
```

---

## 10. Suporte e Recursos

### Logs do Firebase
```
Firebase Console → [Seu Projeto] → Firestore → Uso
```

### Community
- [Stack Overflow - Firebase](https://stackoverflow.com/questions/tagged/firebase)
- [Flutter Community](https://flutter.dev/community)
- [Firebase Discord](https://discord.gg/firebase)

### Documentação Oficial
- [FlutterFire](https://firebase.flutter.dev/)
- [Firebase Docs](https://firebase.google.com/docs)

---

## ✅ Checklist de Diagnóstico

Quando algo não funcionar:

1. [ ] Verificar logs: `flutter logs`
2. [ ] Verificar internet nos dois dispositivos
3. [ ] Verificar Firebase Console (Firestore, Cloud Messaging)
4. [ ] Verificar permissões do Android
5. [ ] Reiniciar ambos os apps
6. [ ] Limpar cache: `flutter clean`
7. [ ] Verificar IDs estão corretos
8. [ ] Verificar google-services.json está presente
9. [ ] Verificar regras de segurança do Firestore
10. [ ] Testar com dispositivos diferentes

---

**Dica:** A maioria dos problemas vem de:
- ❌ Configuração incorreta do Firebase
- ❌ Permissões não concedidas
- ❌ IDs incorretos/com espaços
- ❌ Internet instável
- ❌ Otimização de bateria bloqueando notificações

**Solução geral:** Verificar logs primeiro! 90% dos problemas aparecem lá.
