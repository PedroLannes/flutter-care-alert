# Sistema de Chamada Assistiva

## 📱 Sobre o Projeto

Sistema de comunicação entre dois dispositivos Android onde um dispositivo (Chamador) pode solicitar assistência através de botões intuitivos, e outro dispositivo (Receptor) recebe notificações em tempo real dessas solicitações.

**Funcionalidades:**
- ✅ 6 tipos de chamadas (Banheiro, Sede, Fome, Medicação, Ajuda, Urgente)
- ✅ Notificações push em tempo real via Firebase
- ✅ Interface intuitiva e acessível
- ✅ Indicador de status online/offline
- ✅ Histórico de chamadas
- ✅ Priorização de chamadas urgentes

---

## ⚠️ IMPORTANTE: Configuração Firebase Necessária

**Este aplicativo REQUER Firebase para funcionar.** O Firebase fornece:
- **Cloud Firestore:** Sincronização de chamadas em tempo real
- **Cloud Messaging (FCM):** Notificações push entre dispositivos

**Os arquivos de configuração neste repositório contêm apenas placeholders.** Você DEVE criar seu próprio projeto Firebase e substituir as credenciais antes de compilar o app.

---

## 🚀 Instalação e Configuração

### Pré-requisitos

- Flutter SDK 3.0+
- Android Studio ou VS Code
- **Conta Google (obrigatório para Firebase)**
- 2 dispositivos Android (mínimo Android 5.0 / API 21)

### Passo 1: Clonar/Preparar o Projeto

```bash
git clone https://github.com/PedroLannes/care_alert
cd botao
flutter pub get
```

### Passo 2: Configurar SEU Próprio Firebase

#### 2.1. Criar Projeto Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Nome do projeto: `call-system` (ou outro de sua escolha)
4. Siga o assistente de criação

#### 2.2. Adicionar App Android ao Firebase

1. No painel do projeto, clique em "Adicionar app" → Android
2. Preencha:
   - **Nome do pacote:** `com.example.call_system`
   - **Apelido do app:** Call System
   - **Certificado SHA-1:** (opcional para desenvolvimento)
3. **Baixe o arquivo `google-services.json`**
4. **SUBSTITUA** o arquivo placeholder em: `android/app/google-services.json`

#### 2.3. Ativar Serviços Firebase

No Firebase Console:

**Cloud Firestore:**
1. Vá em "Firestore Database"
2. Clique em "Criar banco de dados"
3. Escolha "Iniciar no modo de teste" (por enquanto)
4. Selecione localização (ex: `southamerica-east1`)

**Cloud Messaging:**
1. Vá em "Cloud Messaging"
2. O serviço já está ativo automaticamente

#### 2.4. Configurar Regras de Segurança do Firestore

No Firestore, vá em "Regras" e cole:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Permitir leitura/escrita de chamadas (simplificado para desenvolvimento)
    match /calls/{callId} {
      allow read, write: if true;
    }
    
    // Permitir leitura/escrita de dispositivos
    match /devices/{deviceId} {
      allow read, write: if true;
    }
    
    // Permitir leitura/escrita de notificações
    match /notifications/{notificationId} {
      allow read, write: if true;
    }
  }
}
```

**⚠️ IMPORTANTE:** Para produção, implemente regras de segurança adequadas! Ver [firestore_rules_CONFIGURE_NO_FIREBASE.txt](firestore_rules_CONFIGURE_NO_FIREBASE.txt)

#### 2.5. Atualizar Configuração no Código

Abra `lib/config/firebase_config.dart` e **SUBSTITUA os placeholders** pelos valores do seu projeto:

```dart
static FirebaseOptions get currentPlatform {
  return const FirebaseOptions(
    apiKey: 'SUA_API_KEY_AQUI',            // current_key
    appId: 'SEU_APP_ID_AQUI',              // mobilesdk_app_id
    messagingSenderId: 'SEU_SENDER_ID',    // project_number
    projectId: 'SEU_PROJECT_ID',           // project_id
    storageBucket: 'SEU_PROJECT_ID.firebasestorage.app',
  );
}
```

**Como encontrar esses valores no `google-services.json`:**
- `apiKey`: `client[0].api_key[0].current_key`
- `appId`: `client[0].client_info.mobilesdk_app_id`
- `messagingSenderId`: `project_info.project_number`
- `projectId`: `project_info.project_id`
- `storageBucket`: `project_info.storage_bucket`

### Passo 3: Compilar e Instalar

```bash
# Compilar o APK
flutter build apk --release

# Ou instalar diretamente em dispositivos conectados
flutter run --release
```

---

## 🎯 Como Usar

### Primeira Execução

Quando você abre o app pela primeira vez, verá a **Tela de Configuração**.

#### Dispositivo A (Chamador)

1. Selecione **"Chamador (Dispositivo A)"**
2. (Opcional) Dê um nome: "Quarto do Paciente"
3. Você receberá um **ID único** - anote ou copie
4. Você precisará do **ID do Dispositivo B** (Receptor)
5. Toque em "Salvar e Continuar"

#### Dispositivo B (Receptor)

1. Selecione **"Receptor (Dispositivo B)"**
2. (Opcional) Dê um nome: "Posto de Enfermagem"
3. Você receberá um **ID único** - compartilhe com o Dispositivo A
4. Toque em "Salvar e Continuar"

### Emparelhamento

1. No **Dispositivo B**, vá em Menu (⋮) → "Ver ID"
2. Copie o ID mostrado
3. No **Dispositivo A**, cole este ID no campo "ID do Receptor"
4. Pronto! Os dispositivos estão conectados

### Enviar Chamada (Dispositivo A)

1. Toque em um dos 6 botões:
   - 🚽 **Banheiro** (Alta prioridade)
   - 💧 **Sede** (Média prioridade)
   - 🍽️ **Fome** (Média prioridade)
   - 💊 **Medicação** (Alta prioridade)
   - 🤝 **Ajuda Geral** (Média prioridade)
   - 📞 **Urgente** (Crítica - som/vibração intensos)

2. Uma notificação confirmará o envio
3. O Dispositivo B receberá a chamada instantaneamente

### Receber Chamada (Dispositivo B)

1. Você receberá uma **notificação push**
2. Abra o app para ver detalhes
3. Opções disponíveis:
   - ✅ **Atender**: Reconhece a chamada
   - ✔️ **Completar**: Marca como resolvida

### Recursos Adicionais

**Ver Histórico (Dispositivo A):**
- Menu → "Ver Histórico"
- Mostra todas as chamadas enviadas e seus status

**Indicador de Status:**
- **Verde (Online)**: Receptor está conectado
- **Cinza (Offline)**: Receptor não está disponível

**Resetar Configuração:**
- Menu → "Resetar Config"
- Limpa todas as configurações (útil para trocar o papel do dispositivo)

---

## 🏗️ Estrutura do Projeto

```
lib/
├── config/
│   ├── app_config.dart          # Configurações gerais
│   └── firebase_config.dart     # Configuração Firebase
├── models/
│   ├── call_request.dart        # Modelo de chamada
│   └── call_type.dart           # Tipos de chamada
├── screens/
│   ├── caller_screen.dart       # Tela do Chamador (A)
│   ├── receiver_screen.dart     # Tela do Receptor (B)
│   └── setup_screen.dart        # Configuração inicial
├── services/
│   ├── call_service.dart        # Orquestrador de chamadas
│   ├── firebase_service.dart    # Lógica Firebase
│   └── notification_service.dart # Notificações locais
├── widgets/
│   ├── call_button.dart         # Botão de chamada
│   ├── call_card.dart           # Card de solicitação
│   └── status_indicator.dart    # Indicador online/offline
└── main.dart                    # Entry point
```

---

## 🔧 Troubleshooting

### Notificações não chegam

**Problema:** Dispositivo B não recebe notificações

**Soluções:**
1. Verifique se o Firebase foi configurado corretamente
2. Confirme que o arquivo `google-services.json` está em `android/app/`
3. Nas configurações do Android, permita notificações para o app
4. Verifique se há internet nos dois dispositivos
5. Reinicie ambos os apps

### Dispositivos não se conectam

**Problema:** Status sempre "Offline"

**Soluções:**
1. Confirme que ambos têm internet
2. Verifique se os IDs foram compartilhados corretamente
3. No Firestore Console, verifique se há documentos em `devices/`
4. Tente resetar a configuração e refazer o emparelhamento

### Erros de compilação

**Problema:** Erros ao rodar `flutter build apk`

**Soluções:**
```bash
# Limpar build anterior
flutter clean

# Obter dependências novamente
flutter pub get

# Verificar configuração
flutter doctor

# Compilar novamente
flutter build apk
```

### App fecha ao tocar botão

**Problema:** Crash ao enviar chamada

**Soluções:**
1. Verifique logs: `flutter logs` ou `adb logcat`
2. Confirme que o Firebase está configurado
3. Verifique se o `receiverId` foi preenchido corretamente

---

## 📊 Firestore - Estrutura de Dados

### Collection: `calls`

```json
{
  "id": "uuid-v4",
  "type": "bathroom|water|food|medication|help|urgent",
  "timestamp": "2025-11-01T14:35:00.000Z",
  "senderId": "device-a-uuid",
  "receiverId": "device-b-uuid",
  "status": "pending|acknowledged|inProgress|completed",
  "message": null
}
```

### Collection: `devices`

```json
{
  "id": "device-uuid",
  "name": "Nome do Dispositivo (ex: Quarto)",
  "role": "caller|receiver",
  "fcmToken": "firebase-token",
  "lastSeen": "Timestamp",
  "isOnline": true,
  "createdAt": "Timestamp"
}
```

---

## 🔐 Segurança (Produção)

Para uso em produção, implemente:

1. **Firebase Authentication:**
   ```dart
   // Adicionar autenticação antes de enviar chamadas
   final user = await FirebaseAuth.instance.signInAnonymously();
   ```

2. **Regras de Firestore mais restritivas:**
   ```javascript
   match /calls/{callId} {
     allow read: if request.auth != null;
     allow create: if request.auth != null 
                   && request.resource.data.senderId == request.auth.uid;
     allow update: if request.auth != null 
                   && request.resource.data.receiverId == request.auth.uid;
   }
   ```

3. **Criptografia de dados sensíveis**

4. **Rate limiting para evitar spam de chamadas**

---

## 🚀 Melhorias Futuras

- Sons customizados por tipo de chamada
- Modo escuro
- Suporte a múltiplos receptores
- Dashboard web para monitoramento

---

## 📝 Notas Importantes

- **Bateria:** Apps com notificações em background podem consumir mais bateria
- **Permissões:** Certifique-se de conceder todas as permissões solicitadas
- **Internet:** Ambos dispositivos precisam de conexão (WiFi ou dados móveis)
- **Firebase Gratuito:** Plano Spark permite até 50k leituras/dia (suficiente para uso pessoal)

---

## 📄 Licença

Este projeto é de código aberto para uso pessoal e educacional.
A comercialização ou redistribuição para fins lucrativos não é permitida.

---

## 🆘 Suporte

Problemas ou dúvidas? Verifique:
1. Este README completo
2. Logs do app: `flutter logs`
3. Firebase Console para erros
4. Seção de Troubleshooting acima

---


**Versão:** 1.0.0
**Última atualização:** Novembro 2025
