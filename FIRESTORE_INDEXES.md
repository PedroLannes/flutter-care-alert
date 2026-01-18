# 📋 Configuração de Índices do Firestore

## Problema: Histórico vazio no Chamador

O histórico não mostra as chamadas enviadas porque o Firestore requer **índices compostos** para queries que combinam `where()` + `orderBy()`.

---

## ✅ Solução: Criar Índices Compostos

### **Índice 1: Para listar chamadas ENVIADAS (isCaller = true)**

| Campo | Tipo | Ordem |
|-------|------|-------|
| `senderId` | Ascending | 1º |
| `timestamp` | Descending | 2º |

**Coleção:** `calls`

### **Índice 2: Para listar chamadas RECEBIDAS (isCaller = false)**

| Campo | Tipo | Ordem |
|-------|------|-------|
| `receiverId` | Ascending | 1º |
| `timestamp` | Descending | 2º |

**Coleção:** `calls`

---

## 📱 Como Criar no Firebase Console

### Opção A: Via Interface Web

1. Vá para [Firebase Console](https://console.firebase.google.com)
2. Selecione o projeto
3. Acesse **Firestore Database**
4. Clique na aba **Índices**
5. Clique em **Criar índice composto**
6. Preencha:
   - **Collection ID:** `calls`
   - **First Field:** `senderId` → Ascending
   - **Second Field:** `timestamp` → Descending
   - Clique em **Criar índice**
7. Repita para `receiverId`

### Opção B: Via Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy apenas os índices
firebase deploy --only firestore:indexes
```

> Crie um arquivo `firebase.json` na raiz do projeto com a configuração de índices.

---

## 🔍 Diagnóstico: Como saber se os índices estão criados?

1. **Abra o console do app** (Flutter DevTools)
2. **Envie uma chamada** e veja os logs
3. **Procure por:**
   - ✅ `📊 Histórico - Chamadas: X` → Índices OK!
   - ❌ `📊 Histórico - Chamadas: 0` → Índices faltando

---

## 🚀 Workaround Temporário (SEM Índices)

Se não conseguir criar os índices imediatamente, há uma versão alternativa no código:

### No `CallService`:
```dart
// Use este método temporariamente
Stream<List<CallRequest>> getCallHistory(String deviceId, {bool isCaller = false}) {
  return _firebaseService.getAllCallsUnordered(deviceId, isCaller: isCaller);
}
```

**Vantagens:**
- ✅ Funciona sem índices
- ✅ Ordena os dados localmente

**Desvantagens:**
- ❌ Mais lento para grandes volumes
- ❌ Carrega até 100 itens e ordena localmente

---

## 📊 Estrutura esperada de um documento `calls`

```json
{
  "id": "uuid-string",
  "type": "bathroom",
  "timestamp": "2025-12-28T14:30:00.000Z",
  "senderId": "device-a-id",
  "receiverId": "device-b-id",
  "status": "pending",
  "message": null
}
```

---

## ✔️ Checklist de Implementação

- [ ] Criar índice para `senderId + timestamp`
- [ ] Criar índice para `receiverId + timestamp`
- [ ] Testar histórico no app
- [ ] Verificar logs para confirmar dados sendo retornados
- [ ] Remover logs de debug após confirmar funcionamento

---

## 🆘 Problemas Comuns

### Problema: "Índice não está sendo criado"
- **Solução:** Aguarde 5-10 minutos após criar o índice. O Firestore precisa de tempo.

### Problema: "Histórico mostra apenas mensagens recentes"
- **Solução:** Aumente o `limit(100)` em `firebase_service.dart`

### Problema: "Histórico mostra muitas mensagens antigas"
- **Solução:** Reduza `historyDaysToKeep` em `app_config.dart` (padrão: 7 dias)

---

## 📝 Notas

- Os índices podem levar até **15 minutos** para ser criados pelo Firebase
- Após criação, o histórico começará a funcionar automaticamente
- Não há custo adicional por índices - está incluído no plano Firestore
