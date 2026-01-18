enum CallType {
  bathroom('🚽', 'Banheiro', 'high', 0xFF2196F3),
  water('💧', 'Sede', 'medium', 0xFF03A9F4),
  food('🍽️', 'Fome', 'medium', 0xFFFF9800),
  medication('💊', 'Medicação', 'high', 0xFFE91E63),
  help('🤝', 'Ajuda Geral', 'medium', 0xFF9C27B0),
  urgent('📞', 'Urgente', 'critical', 0xFFF44336);

  final String emoji;
  final String label;
  final String priority;
  final int colorValue;

  const CallType(this.emoji, this.label, this.priority, this.colorValue);
}

enum CallStatus {
  pending,
  acknowledged,
  inProgress,
  completed,
  ignored
}
