# ❓ FAQ - Perguntas Frequentes

## 📱 Sobre o Sistema

### O que é este sistema?
Sistema de comunicação entre dois dispositivos Android onde um pode solicitar assistência (6 tipos de chamadas) e outro recebe notificações em tempo real.

### Para que serve?
- Cuidado de idosos ou pessoas com mobilidade reduzida
- Hospitais/clínicas (chamada de paciente → enfermagem)
- Assistência domiciliar
- Comunicação entre ambientes

### Preciso saber programar para usar?
**Não!** Basta seguir o guia QUICKSTART.md para configurar. Programação só é necessária para personalizar.

---

## 💰 Custos

### É grátis?
**Sim!** Para uso pessoal/doméstico é completamente grátis.

### Tem custos escondidos?
Não. O Firebase tem plano gratuito que suporta:
- 50.000 leituras/dia
- 20.000 escritas/dia
- Notificações ilimitadas

Para uso doméstico (100 chamadas/dia), você usa menos de 10% dos limites gratuitos.

### Quando teria que pagar?
Apenas se ultrapassar os limites gratuitos (uso comercial intenso). Para uso pessoal, nunca.

### E a internet? Consome muito?
Muito pouco! Cada chamada usa ~1KB de dados. 1000 chamadas = ~1MB.

---

## 🔧 Configuração

### Preciso de quais dispositivos?
- 2 dispositivos Android (mínimo Android 5.0)
- Não precisa ser o mesmo modelo
- Não precisa ser da mesma marca

### Precisa de internet?
Sim, ambos os dispositivos precisam de conexão com a internet (WiFi ou dados móveis) para enviar e receber chamadas.

### Posso usar tablets?
Sim! Qualquer dispositivo Android funciona.

### Preciso do Google Play instalado?
Sim, pois o Firebase Cloud Messaging depende dos Google Play Services.

### Quanto tempo leva para configurar?
- **Primeira vez:** ~30 minutos (criar Firebase + compilar)
- **Próximas vezes:** ~5 minutos (já compilado)
- **Usar:** ~2 minutos (configurar dispositivos)

---

## 🚀 Funcionamento

### Como funciona a comunicação?
1. Dispositivo A envia chamada → Firebase Cloud Firestore
2. Firebase detecta nova chamada → Cloud Messaging
3. Notificação chega no Dispositivo B instantaneamente

### Funciona com app fechado?
**Sim!** As notificações chegam mesmo com o app completamente fechado.

### Funciona se desligar a tela?
Sim, mas configure para **não otimizar bateria** do app.

### Quanto demora para a notificação chegar?
- Tipicamente 1-3 segundos
- Pode variar com qualidade da internet

### Tem limite de chamadas por dia?
Tecnicamente 20.000/dia (limite do Firebase gratuito), mas para uso pessoal é ilimitado na prática.

---

## 🔐 Segurança e Privacidade

### Os dados são seguros?
Dados ficam no Firebase (Google), que tem criptografia padrão. Para maior segurança, implemente autenticação (ver firestore_rules.txt).

### Alguém pode interceptar as chamadas?
Não facilmente. Os dados trafegam por HTTPS e são armazenados de forma segura nos servidores do Google.

### Preciso criar conta?
Não precisa criar conta para usar. Apenas para configurar Firebase (grátis).

### Posso usar sem dar meus dados?
Sim. Firebase não exige dados pessoais além de email (para login no console).

---

## 🔔 Notificações

### Por que as notificações não chegam?
**Causas mais comuns:**
1. Permissões de notificação não concedidas
2. Otimização de bateria ativa
3. IDs dos dispositivos incorretos
4. Sem internet

**Solução:** Veja TROUBLESHOOTING.md seção 2.

### Posso mudar o som da notificação?
Sim! Configurações do Android → Notificações → Sistema de Chamada → Som.

### A vibração é muito forte/fraca?
Configure nas notificações do Android. Cada canal (Normal/Urgente) pode ter configuração diferente.

### Posso silenciar temporariamente?
Sim, use o modo Não Perturbe do Android, ou desabilite notificações do app.

---

## 🎨 Personalização

### Posso mudar as cores?
Sim! Edite `lib/models/call_type.dart` e altere os valores `colorValue`.

### Posso adicionar mais tipos de chamada?
Sim! Adicione novos valores no enum `CallType` e ajuste a interface.

### Posso mudar os emojis?
Sim! Edite os emojis em `CallType` no arquivo `call_type.dart`.

### Posso mudar o idioma?
Atualmente em português. Para outros idiomas, edite os textos nas telas (widgets).

### Posso usar foto em vez de emoji?
Sim, mas requer modificar o widget `CallButton` para aceitar imagens.

---

## 🔄 Dispositivos

### Posso usar mais de 2 dispositivos?
Atualmente o sistema foi desenhado para ser 1-para-1 (um chamador e um receptor).

### Posso ter 2 chamadores?
Sim. O sistema identifica a origem de cada chamada pelo ID do dispositivo. Se você nomeou os dispositivos (ex: "Quarto", "Sala") na configuração, o receptor saberá exatamente de onde veio.

### Posso inverter os papéis depois?
Sim! Menu → Resetar Config → Escolher novo papel.

### E se eu perder o ID do outro dispositivo?
No dispositivo receptor: Menu → Ver ID → Copiar novamente.

---

## ⚙️ Técnico

### Que versão do Android preciso?
Mínimo Android 5.0 (API 21). Recomendado Android 8.0+.

### Funciona em iOS/iPhone?
**Não.** Apenas Android. Para iOS, precisaria reescrever código nativo.

### Posso publicar na Play Store?
Sim! Siga o processo de publicação do Google Play. Configure autenticação primeiro.

### Preciso de Firebase?
Sim, o Firebase é obrigatório para o funcionamento do banco de dados em tempo real e das notificações.

### Posso usar meu próprio servidor?
Sim, mas precisaria reescrever FirebaseService para usar sua API.

---

## 🐛 Erros Comuns

### "Plugin google-services not found"
Adicione plugin no build.gradle. Veja TROUBLESHOOTING.md seção 1.

### "PERMISSION_DENIED"
Configure regras do Firestore. Veja firestore_rules.txt.

### "MissingPluginException"
Execute `flutter clean && flutter pub get`.

### App fecha ao abrir
Verifique logs com `adb logcat`. Geralmente Firebase não configurado.

---

## 📊 Performance

### Consome muita bateria?
Não excessivamente, mas notificações em background consomem um pouco. Configure para "Sem restrições" de bateria para melhor performance.

### Consome muito espaço?
APK tem ~30-40MB. Dados do app são mínimos (<1MB).

### É rápido?
Sim! Notificações chegam em 1-3 segundos tipicamente.

### Funciona com internet lenta?
Sim, mas pode demorar mais para sincronizar.

---

## 🔄 Atualizações

### Como atualizo o app?
Recompile com `flutter build apk` e instale novo APK.

### Vou perder meus dados ao atualizar?
Configurações ficam salvas (SharedPreferences). Histórico está no Firebase.

### Com que frequência atualizar?
Quando adicionar novas features ou corrigir bugs. Não há obrigação.

---

## 🆘 Suporte

### Onde busco ajuda?
1. TROUBLESHOOTING.md (este projeto)
2. Stack Overflow (tag: flutter + firebase)
3. Documentação Firebase
4. Comunidade Flutter

### Posso contratar suporte?
Este é um projeto open-source educacional. Para suporte comercial, contrate um desenvolvedor Flutter.

### Encontrei um bug!
Verifique TROUBLESHOOTING.md primeiro. Se persistir, documente:
- Logs (`flutter logs`)
- Passos para reproduzir
- Versão do Android
- Screenshot/vídeo

---

## 📚 Aprendizado

### Quero aprender Flutter, por onde começar?
1. [flutter.dev/docs](https://flutter.dev/docs)
2. [Curso gratuito do Google](https://developers.google.com/learn/pathways/intro-to-flutter)
3. YouTube: Code with Andrea, Reso Coder

### Quero aprender Firebase?
1. [firebase.google.com/docs](https://firebase.google.com/docs)
2. [FlutterFire](https://firebase.flutter.dev/)
3. Cursos na Udemy/Coursera

### Esse projeto é bom para aprender?
Sim! É um projeto real, completo, com boas práticas:
- Arquitetura limpa (Models, Services, Screens)
- Separação de responsabilidades
- Tratamento de erros
- Documentação extensa

---

## 🎯 Casos de Uso Reais

### Funciona para cuidado de idosos?
**Sim!** É um dos casos de uso primários. Dispositivo A no quarto, B com cuidador.

### Serve para hospital?
Sim, mas para uso comercial:
- Implemente autenticação robusta
- Configure regras de segurança
- Considere conformidade LGPD/HIPAA
- Teste extensivamente

### Posso usar em casa?
Perfeitamente! É ideal para uso doméstico.

### Funciona em ambientes sem WiFi?
Sim, se ambos tiverem dados móveis.

---

## 🔮 Futuro

### Vão adicionar mais features?
Este projeto é open-source. Você pode:
- Adicionar features você mesmo
- Sugerir melhorias
- Contribuir com código

### Vai ter versão iOS?
Não planejada no momento. Contribuições são bem-vindas!

### Posso vender ou lucrar com este app?
**Não.** Este projeto é disponibilizado como código aberto para fins educacionais e de uso pessoal. A sua venda, comercialização ou utilização em produtos com fins lucrativos não é permitida. O objetivo é ser uma ferramenta de auxílio e aprendizado, não um produto comercial.

---

## 💡 Dicas Extras

### Melhor configuração para idosos?
- Tablet grande (melhor visibilidade)
- Botões grandes (já implementado)
- Desabilitar otimização de bateria
- Deixar sempre plugado
- Volume de notificação no máximo

### Melhor configuração para hospitais?
- 1 dispositivo chamador por leito
- 1 ou mais receptores na enfermagem
- Cloud Functions para notificações garantidas
- Autenticação + regras de segurança
- Logs de auditoria

### Como evitar toques acidentais?
- Use case/capa no dispositivo
- Configure confirmação (adicione dialog antes de enviar)
- Educação do usuário

---

## 📖 Mais Informações

Para mais detalhes, consulte:
- **Setup:** QUICKSTART.md
- **Documentação:** README.md
- **Problemas:** TROUBLESHOOTING.md
- **Técnico:** Código em lib/
- **Comandos:** COMANDOS.md

**Sua pergunta não está aqui?**
1. Verifique INDEX.md para navegar toda documentação
2. Busque no TROUBLESHOOTING.md
3. Consulte a documentação oficial do Flutter/Firebase

---

**💬 Contribuições para este FAQ são bem-vindas!**
