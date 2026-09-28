import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';

/// Dato de telemetría grande y legible de un vistazo (distancia, llegada…).
///
/// La cifra va en JetBrains Mono con dígitos tabulares: no "baila" al
/// actualizarse mientras la unidad se mueve.
class TelemetryTile extends StatelessWidget {
  final String label;
  final String value;
  final double valueSize;

  const TelemetryTile({
    super.key,
    required this.label,
    required this.value,
    this.valueSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SecuriaSpace.sm,
          vertical: SecuriaSpace.sm - 2,
        ),
        decoration: BoxDecoration(
          color: PatrolColors.card,
          borderRadius: BorderRadius.circular(SecuriaRadius.md + 2),
          border: Border.all(color: PatrolColors.border),
        ),
        child: _TelemetryValue(label: label, value: value, size: valueSize),
      ),
    );
  }
}

/// Varias cifras en una sola tarjeta dividida (distancia · llegada · hora)
class TelemetryStrip extends StatelessWidget {
  final List<(String, String)> items;

  const TelemetryStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PatrolColors.card,
        borderRadius: BorderRadius.circular(SecuriaRadius.md + 2),
        border: Border.all(color: PatrolColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: PatrolColors.border,
                ),
              Expanded(
                child: Semantics(
                  label: '${items[i].$1}: ${items[i].$2}',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SecuriaSpace.sm - 2,
                      vertical: SecuriaSpace.xs + 1,
                    ),
                    child: _TelemetryValue(
                      label: items[i].$1,
                      value: items[i].$2,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TelemetryValue extends StatelessWidget {
  final String label;
  final String value;
  final double size;

  const _TelemetryValue({
    required this.label,
    required this.value,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PatrolTypography.caption,
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: PatrolTypography.mono(size: size),
          ),
        ),
      ],
    );
  }
}
