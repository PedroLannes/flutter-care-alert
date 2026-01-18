# 🛠️ Comandos Úteis - Referência Rápida

## 📦 Gerenciamento de Dependências

```bash
# Instalar dependências
flutter pub get

# Atualizar dependências
flutter pub upgrade

# Verificar versões disponíveis
flutter pub outdated

# Limpar cache
flutter pub cache clean
```

---

## 🔨 Build e Compilação

### APK (Android)

```bash
# Build APK debug
flutter build apk --debug

# Build APK release (recomendado)
flutter build apk --release

# Build APK split por ABI (menor tamanho)
flutter build apk --split-per-abi

# Build APK com obfuscação
flutter build apk --obfuscate --split-debug-info=./debug-info
```

### App Bundle (Play Store)

```bash
# Build App Bundle para Play Store
flutter build appbundle --release
```

---

## 🚀 Executar App

```bash
# Listar dispositivos conectados
flutter devices

# Executar em modo debug
flutter run

# Executar em modo release
flutter run --release

# Executar em dispositivo específico
flutter run -d <device-id>

# Executar com hot reload
flutter run --hot

# Executar sem sons
flutter run --no-sound-null-safety
```

---

## 🧹 Limpeza

```bash
# Limpar build anterior
flutter clean

# Limpar + reinstalar dependências
flutter clean && flutter pub get

# Limpar cache do Gradle (Android)
cd android && ./gradlew clean && cd ..

# Limpar tudo (completo)
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm pubspec.lock
flutter pub get
```

---

## 🐛 Debug e Logs

```bash
# Ver logs em tempo real
flutter logs

# Logs apenas de erros
flutter logs --level error

# Logs do Android (ADB)
adb logcat

# Logs filtrados do Flutter
adb logcat | grep -i flutter

# Logs apenas de erros do Android
adb logcat *:E

# Limpar logs do Android
adb logcat -c
```

---

## 📱 Gerenciamento de Dispositivos (ADB)

```bash
# Listar dispositivos conectados
adb devices

# Instalar APK manualmente
adb install build/app/outputs/flutter-apk/app-release.apk

# Desinstalar app
adb uninstall com.example.call_system

# Limpar dados do app
adb shell pm clear com.example.call_system

# Reiniciar dispositivo
adb reboot

# Capturar screenshot
adb shell screencap /sdcard/screen.png
adb pull /sdcard/screen.png

# Gravar tela
adb shell screenrecord /sdcard/video.mp4

# Ver informações do dispositivo
adb shell getprop ro.build.version.release  # Versão Android
adb shell dumpsys battery                   # Status da bateria
```

---

## 🔍 Análise e Verificação

```bash
# Verificar configuração do Flutter
flutter doctor

# Verificar configuração detalhada
flutter doctor -v

# Analisar código (lints)
flutter analyze

# Formatar código
flutter format .

# Verificar dependências
flutter pub deps

# Verificar tamanho do APK
flutter build apk --analyze-size
```

---

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Executar teste específico
flutter test test/widget_test.dart

# Executar testes com coverage
flutter test --coverage

# Ver relatório de coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔥 Firebase

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login no Firebase
firebase login

# Inicializar projeto
firebase init

# Deploy de functions
firebase deploy --only functions

# Deploy completo
firebase deploy

# Ver logs do Firebase
firebase functions:log

# Emuladores locais
firebase emulators:start

# Ver projetos Firebase
firebase projects:list
```

---

## 📊 Firestore (via Firebase CLI)

```bash
# Exportar dados do Firestore
firebase firestore:export gs://[BUCKET_NAME]/[EXPORT_PREFIX]

# Importar dados
firebase firestore:import gs://[BUCKET_NAME]/[EXPORT_PREFIX]

# Deletar collection (cuidado!)
firebase firestore:delete [COLLECTION_PATH] --recursive
```

---

## 🎨 Assets e Ícones

```bash
# Gerar ícone do app (com package flutter_launcher_icons)
flutter pub run flutter_launcher_icons:main

# Gerar splash screen
flutter pub run flutter_native_splash:create
```

---

## 📦 Instalação de Packages Úteis

```bash
# Adicionar package
flutter pub add nome_do_package

# Adicionar package de desenvolvimento
flutter pub add --dev nome_do_package

# Remover package
flutter pub remove nome_do_package
```

---

## 🔧 Android Específico

```bash
# Ir para pasta Android
cd android

# Limpar build do Gradle
./gradlew clean

# Build do Gradle
./gradlew build

# Listar tasks disponíveis
./gradlew tasks

# Verificar dependências
./gradlew app:dependencies

# Voltar para raiz
cd ..
```

---

## 📲 Instalação Direta

```bash
# Instalar em todos os dispositivos conectados
flutter install

# Instalar em dispositivo específico
flutter install -d <device-id>

# Instalar APK via ADB
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Instalar e abrir app
adb install -r app-release.apk && adb shell am start -n com.example.call_system/.MainActivity
```

---

## 🎯 Comandos do Projeto Atual

### Setup Inicial
```bash
cd d:\Codigos\Flutter\botao
flutter pub get
```

### Compilar Release
```bash
flutter build apk --release
```

### Instalar em Dispositivos
```bash
# Ver dispositivos
flutter devices

# Instalar no primeiro dispositivo
flutter run --release

# Ou via ADB após build
adb devices
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Ver Logs
```bash
flutter logs
# ou
adb logcat | grep -i flutter
```

### Limpar e Recompilar
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🐞 Debug Específico do Projeto

### Verificar Firebase
```bash
# Ver se google-services.json existe
ls android/app/google-services.json

# Ver conteúdo (verificar project_id)
cat android/app/google-services.json | grep project_id
```

### Verificar Firestore
```dart
// Executar no console do Firebase
firebase firestore:list
```

### Resetar App no Dispositivo
```bash
# Limpar dados sem desinstalar
adb shell pm clear com.example.call_system

# Ou desinstalar e reinstalar
adb uninstall com.example.call_system
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 💡 Dicas e Atalhos

### Atalhos do VS Code
```
Ctrl + Shift + P  → Paleta de comandos
F5                → Iniciar debug
Shift + F5        → Parar debug
Ctrl + `          → Abrir terminal
```

### Hot Reload
```
r (no terminal)   → Hot reload
R (no terminal)   → Hot restart
q (no terminal)   → Quit
```

### Verificação Rápida
```bash
# Tudo de uma vez
flutter doctor && flutter analyze && flutter test
```

---

## 📝 Script Completo de Setup

Crie um arquivo `setup.sh`:

```bash
#!/bin/bash
echo "🚀 Configurando projeto..."

# Limpar
echo "🧹 Limpando..."
flutter clean

# Dependências
echo "📦 Instalando dependências..."
flutter pub get

# Verificar
echo "🔍 Verificando configuração..."
flutter doctor

# Analisar
echo "📊 Analisando código..."
flutter analyze

echo "✅ Setup completo!"
echo "👉 Próximo passo: flutter run"
```

Executar:
```bash
chmod +x setup.sh
./setup.sh
```

---

## 🎯 Fluxo de Trabalho Recomendado

```bash
# 1. Após clonar/baixar projeto
flutter pub get

# 2. Verificar tudo
flutter doctor -v

# 3. Conectar dispositivo e testar
flutter devices
flutter run

# 4. Fazer mudanças no código
# (use hot reload com 'r' no terminal)

# 5. Build para produção
flutter clean
flutter build apk --release

# 6. Instalar no dispositivo
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🆘 Comandos de Emergência

### App Crashando
```bash
# Ver stack trace completo
adb logcat | grep -A 50 "FATAL EXCEPTION"

# Limpar tudo e recomeçar
flutter clean
rm -rf build/
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run
```

### Problemas de Dependências
```bash
flutter pub cache repair
flutter pub get
```

### Gradle Travado
```bash
cd android
./gradlew clean --refresh-dependencies
cd ..
flutter clean
flutter pub get
```

---

**💾 Salve este arquivo para referência rápida!**

**Dica:** Adicione aos favoritos do seu navegador de arquivos.
