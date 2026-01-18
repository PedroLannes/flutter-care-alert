# Segurança e Configuração

## ⚠️ AVISO IMPORTANTE

Este repositório **NÃO contém credenciais reais do Firebase**. Os arquivos de configuração fornecidos contêm apenas placeholders.

## Arquivos que Você DEVE Configurar

Antes de compilar este projeto, você DEVE criar seu próprio projeto Firebase e substituir os seguintes arquivos:

### 1. `android/app/google-services.json`
- **Status atual:** Contém placeholders
- **Ação necessária:** Baixe o arquivo do seu projeto Firebase e substitua
- **Como obter:** Firebase Console → Configurações do Projeto → Seus apps → Android → google-services.json

### 2. `lib/config/firebase_config.dart`
- **Status atual:** Contém placeholders `YOUR_API_KEY_HERE`, etc.
- **Ação necessária:** Substitua os valores com os do seu projeto Firebase
- **Valores necessários:**
  - `apiKey`
  - `appId`
  - `messagingSenderId`
  - `projectId`
  - `storageBucket`

## 🚫 Controle de Versão (Git)

Para garantir que você não vaze suas credenciais acidentalmente:

1. Certifique-se de que o arquivo `android/app/google-services.json` está no seu `.gitignore`.
2. Se você hardcodar as chaves em `lib/config/firebase_config.dart`, adicione este arquivo ao `.gitignore` também.
3. **Nunca** faça commit desses arquivos com dados reais em um repositório público.

Use variáveis de ambiente ou arquivos de configuração não rastreados para produção.

## Por Que o Firebase é Necessário?

Este aplicativo **NÃO pode funcionar sem Firebase** porque depende de:

1. **Cloud Firestore:** Sincronização de chamadas em tempo real entre dispositivos
2. **Firebase Cloud Messaging (FCM):** Envio de notificações push
3. **Gerenciamento de dispositivos:** Registro e status online/offline

## Configuração Completa

Para instruções completas de configuração, consulte o [README.md](README.md).

## Segurança para Produção

⚠️ As regras iniciais são para desenvolvimento. Para produção, recomendamos configurar a **Autenticação Anônima** no Firebase e usar as regras abaixo:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Função auxiliar para verificar autenticação
    function isAuthenticated() {
      return request.auth != null;
    }

    // Regras para Chamadas
    match /calls/{callId} {
      // Apenas usuários autenticados podem criar chamadas
      allow create: if isAuthenticated();
      // Usuários só podem ler/atualizar chamadas onde são remetente ou destinatário
      allow read, update: if isAuthenticated() && 
        (resource.data.senderId == request.auth.uid || resource.data.receiverId == request.auth.uid);
    }

    // Regras para Dispositivos
    match /devices/{deviceId} {
      allow read, write: if isAuthenticated() && request.auth.uid == deviceId;
    }
  }
}
```

## Suporte

Se você encontrar problemas ao configurar o Firebase, consulte:
- [Documentação oficial do Firebase](https://firebase.google.com/docs)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
