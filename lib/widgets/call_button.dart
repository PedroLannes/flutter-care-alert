import 'package:flutter/material.dart';
import '../models/call_type.dart';

class CallButton extends StatelessWidget {
  final CallType type;
  final VoidCallback? onPressed;

  const CallButton({
    super.key,
    required this.type,
    this.onPressed,
  });

  Color get _backgroundColor => Color(type.colorValue);

  LinearGradient get _gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _backgroundColor,
          _backgroundColor.withValues(alpha: 0.7),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    
    // Usar MediaQuery para responsividade
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      elevation: isEnabled ? 4 : 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji - responsivo ao tamanho da tela
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      type.emoji,
                      style: TextStyle(
                        fontSize: screenWidth > 400 ? 56 : 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Label - se adapta ao tamanho do texto do sistema
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        type.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                
                // Indicador de prioridade
                if (type.priority == 'critical' || type.priority == 'high')
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type.priority == 'critical' ? 'URGENTE' : 'ALTA',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
