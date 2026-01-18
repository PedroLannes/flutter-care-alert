# Guia de Início Rápido - Sistema de Chamada

## ⚡ Setup Rápido (5 minutos)

### 1. Instalar Dependências
```bash
flutter pub get
```

### 2. Configurar Firebase

#### Opção A: Criar Projeto Novo (Recomendado)
```
1. https://console.firebase.google.com/
2. "Adicionar projeto" → Nome: call-system
3. Adicionar app Android
   - Package: com.example.call_system
   - Baixar google-services.json
4. Colocar em: android/app/google-services.json
5. Ativar Firestore e Cloud Messaging
```

#### Opção B: Usar Projeto Existente
```
1. Selecione projeto no Firebase Console
2. Adicione novo app Android
3. Siga os mesmos passos acima
```

### 3. Atualizar Configuração

Edite `lib/config/firebase_config.dart`:

```dart
// Copie os valores do seu google-services.json:
apiKey: 'SUA_API_KEY',           // current_key
appId: 'SEU_APP_ID',             // mobilesdk_app_id
messagingSenderId: 'SENDER_ID',  // project_number
projectId: 'SEU_PROJECT_ID',     // project_id
```

### 4. Compilar e Testar

```bash
# Conecte 2 dispositivos Android via USB
# Verifique com:
flutter devices

# Instale em ambos:
flutter run --release
```

---

## 📱 Configurar Dispositivos

### Dispositivo 1 (Chamador)
```
1. Abra app → Selecione "Chamador"
2. Anote o ID gerado
3. Menu → "Ver ID" para copiar depois
```

### Dispositivo 2 (Receptor)
```
1. Abra app → Selecione "Receptor"
2. Menu → "Ver ID" → Copiar
3. Compartilhe com Dispositivo 1
```

### Emparelhamento
```
No Dispositivo 1:
- Cole o ID do Dispositivo 2
- Salvar

Pronto! Pode enviar chamadas.
```

---

## 🧪 Testar Comunicação

1. **Dispositivo 1:** Toque em "💧 Sede"
2. **Dispositivo 2:** Deve receber notificação imediatamente
3. Toque em "Atender" ou "Completar"

---

## ❗ Problemas Comuns

### Não recebe notificações?
```bash
# 1. Verificar permissões Android
Configurações → Apps → Sistema de Chamada → Notificações → Ativar

# 2. Verificar internet
Ambos dispositivos precisam de WiFi/Dados

# 3. Ver logs
flutter logs
```

### Erro de compilação?
```bash
flutter clean
flutter pub get
flutter build apk
```

### IDs não funcionam?
```
- Copie/Cole com cuidado (sem espaços)
- Verifique se ambos têm internet
- Reinicie os apps
```

---

## 📊 Firestore - Regras Iniciais

No Firebase Console → Firestore → Regras:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // Apenas para desenvolvimento!
    }
  }
}
```

**⚠️ Para produção, use regras mais restritivas!** (veja firestore_rules.txt)

---

## 🎯 Próximos Passos

- [ ] Teste todos os 6 tipos de chamada
- [ ] Verifique notificações com app fechado
- [ ] Teste indicador online/offline
- [ ] Experimente o histórico de chamadas
- [ ] Configure sons/vibração nas configurações do Android

---

## 📚 Documentação Completa

Veja `README.md` para:
- Troubleshooting detalhado
- Estrutura do projeto
- Segurança e produção

---

**Tempo estimado de setup:** 5-10 minutos
**Pronto para produção?** Configure autenticação e regras de segurança primeiro!
