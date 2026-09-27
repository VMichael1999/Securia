import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';

/// Botón SOS que se dispara al mantenerlo presionado [holdDuration].
///
/// Un anillo se llena mientras se presiona y el teléfono vibra al iniciar y al
/// enviar. Soltar antes de tiempo cancela el gesto: evita alertas accidentales
/// en el bolsillo sin pedirle al ciudadano ningún paso extra.
class HoldSosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final bool isSending;
  final Duration holdDuration;
  final double size;

  const HoldSosButton({
    super.key,
    required this.onTriggered,
    this.isSending = false,
    this.holdDuration = const Duration(milliseconds: 1500),
    this.size = 148,
  });

  @override
  State<HoldSosButton> createState() => _HoldSosButtonState();
}

class _HoldSosButtonState extends State<HoldSosButton>
    with TickerProviderStateMixin {
  late final AnimationController _hold;
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hold = AnimationController(vsync: this, duration: widget.holdDuration)
      ..addStatusListener(_onHoldStatus);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  void _onHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      setState(() => _pressed = false);
      _hold.reset();
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
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Semantics(
      button: true,
      label: SosStrings.sosSemantics,
      // Listener responde al instante (sin el retardo de toque de GestureDetector)
      child: Listener(
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: SizedBox(
          width: size + 36,
          height: size + 36,
          child: AnimatedBuilder(
            animation: Listenable.merge([_hold, _pulse]),
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Onda de pulso para atraer la mirada
                  if (!_pressed && !widget.isSending)
                    Container(
                      width: size + 36 * _pulse.value,
                      height: size + 36 * _pulse.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emergencyRed.withValues(
                          alpha: 0.28 * (1 - _pulse.value),
                        ),
                      ),
                    ),

                  // Anillo de progreso del gesto
                  SizedBox(
                    width: size + 16,
                    height: size + 16,
                    child: CircularProgressIndicator(
                      value: widget.isSending ? null : _hold.value,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      color: AppColors.emergencyRed,
                      backgroundColor: AppColors.pureWhite.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),

                  // Núcleo del botón
                  AnimatedScale(
                    scale: _pressed ? 0.93 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.sosGradient,
                        border: Border.all(
                          color: AppColors.pureWhite,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emergencyRed.withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      // Escala hacia abajo si el usuario usa textos grandes
                      padding: const EdgeInsets.all(14),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              widget.isSending
                                  ? const [
                                    Icon(
                                      Icons.cell_tower_rounded,
                                      color: AppColors.pureWhite,
                                      size: 38,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      SosStrings.sosSending,
                                      style: TextStyle(
                                        color: AppColors.pureWhite,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ]
                                  : [
                                    const Text(
                                      SosStrings.sosLabel,
                                      style: TextStyle(
                                        color: AppColors.pureWhite,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 42,
                                        height: 1.0,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _pressed
                                          ? SosStrings.sosKeepHolding
                                          : SosStrings.sosHoldHint,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.pureWhite.withValues(
                                          alpha: 0.95,
                                        ),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
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
