import 'package:flutter/material.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../models/resolution_outcome.dart';

/// Cierre rápido de la intervención: se elige el resultado y listo.
///
/// La nota es opcional; el resultado genera por sí solo el texto del acta.
class ResolutionSheet extends StatefulWidget {
  const ResolutionSheet({super.key});

  /// Devuelve la nota de cierre, o `null` si el agente no concluyó
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PatrolColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ResolutionSheet(),
    );
  }

  @override
  State<ResolutionSheet> createState() => _ResolutionSheetState();
}

class _ResolutionSheetState extends State<ResolutionSheet> {
  final _noteController = TextEditingController();
  ResolutionOutcome? _outcome;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outcome = _outcome;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: PatrolColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              DispatchStrings.resolveTitle,
              style: PatrolTypography.titleLarge.copyWith(
                color: PatrolColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in ResolutionOutcome.values)
                  _OutcomeChip(
                    outcome: option,
                    selected: option == outcome,
                    onTap: () => setState(() => _outcome = option),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(
                color: PatrolColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: DispatchStrings.resolveNoteHint,
                hintStyle: const TextStyle(color: PatrolColors.textMuted),
                filled: true,
                fillColor: PatrolColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed:
                    outcome == null
                        ? null
                        : () => Navigator.of(
                          context,
                        ).pop(outcome.buildNote(_noteController.text)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PatrolColors.policeAccent,
                  foregroundColor: PatrolColors.background,
                  disabledBackgroundColor: PatrolColors.surfaceBorder,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  DispatchStrings.resolveConfirm,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeChip extends StatelessWidget {
  final ResolutionOutcome outcome;
  final bool selected;
  final VoidCallback onTap;

  const _OutcomeChip({
    required this.outcome,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? PatrolColors.policeAccent : PatrolColors.textSecondary;

    return Material(
      color:
          selected
              ? PatrolColors.policeGreenDark
              : PatrolColors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  selected
                      ? PatrolColors.policeAccent
                      : PatrolColors.surfaceBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(outcome.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                outcome.label,
                style: TextStyle(
                  color:
                      selected
                          ? PatrolColors.textPrimary
                          : PatrolColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
