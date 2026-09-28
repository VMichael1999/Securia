import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Botón SOS que se envía al mantenerlo presionado [SecuriaMotion.sosHold].
///
/// - El anillo se llena en línea recta durante 1,5 s; al soltar antes se
///   vacía rápido y no se envía nada (protección contra toques accidentales).
/// - Vibra al empezar y al enviar.
/// - Informa su progreso con [onHoldProgress] para que la pantalla se apague
///   alrededor mientras se mantiene presionado.
class HoldSosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final ValueChanged<double>? onHoldProgress;
  final bool isSending;
  final double size;

  const HoldSosButton({
    super.key,
    required this.onTriggered,
    this.onHoldProgress,
    this.isSending = false,
    this.size = 132,
  });

  @override
  State<HoldSosButton> createState() => _HoldSosButtonState();
}

class _HoldSosButtonState extends State<HoldSosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hold = AnimationController(
      vsync: this,
      duration: SecuriaMotion.sosHold,
      reverseDuration: SecuriaMotion.sosRelease,
    )
      ..addListener(() => widget.onHoldProgress?.call(_hold.value))
      ..addStatusListener(_onHoldStatus);
  }

  void _onHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      setState(() => _pressed = false);
      _hold.value = 0;
      widget.onTriggered();
    }
  }

  void _start() {
    if (widget.isSending) return;
    HapticFeedback.mediumImpact();
    setState(() => _pressed = true);
    _hold.forward(from: 0);
  }

  void _cancel() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    _hold.reverse();
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final ringSize = size + 20;

    return Semantics(
      button: true,
      label: SosStrings.sosSemantics,
      // Listener responde al instante (sin el retardo de toque de GestureDetector)
      child: Listener(
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: SizedBox(
          width: ringSize,
          height: ringSize,
          child: AnimatedBuilder(
            animation: _hold,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo de progreso: pista blanca y relleno rojo
                  SizedBox(
                    width: ringSize - 6,
                    height: ringSize - 6,
                    child: CircularProgressIndicator(
                      value: widget.isSending ? null : _hold.value,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      color: AppColors.sos,
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                  AnimatedScale(
                    scale: _pressed ? 0.94 : 1.0,
                    duration: SecuriaMotion.fast,
                    child: Container(
                      width: size,
                      height: size,
                      padding: const EdgeInsets.all(SecuriaSpace.md),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pressed ? AppColors.sosPressed : AppColors.sos,
                        border: Border.all(color: AppColors.surface, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      // Escala hacia abajo si el usuario usa textos grandes
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              SosStrings.sosLabel,
                              style: AppTypography.sosLabel,
                            ),
                            const SizedBox(height: SecuriaSpace.xxs),
                            Text(
                              widget.isSending
                                  ? SosStrings.sosSending
                                  : _pressed
                                      ? SosStrings.sosKeepHolding
                                      : SosStrings.sosHoldHint,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
