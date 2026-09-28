import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/widgets/dispatch_flow.dart';
import '../../../../app/widgets/patrol_buttons.dart';
import '../models/resolution_outcome.dart';

/// Cierre rápido de la intervención: se elige el resultado y listo.
///
/// Los tiempos del caso van arriba (es lo que el acta necesita y el agente no
/// tiene que escribir). La nota es opcional.
class ResolutionSheet extends StatefulWidget {
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? now;

  const ResolutionSheet({super.key, this.acceptedAt, this.arrivedAt, this.now});

  /// Devuelve la nota de cierre, o `null` si el agente no concluyó
  static Future<String?> show(
    BuildContext context, {
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? now,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: PatrolColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SecuriaRadius.xl),
        ),
      ),
      builder:
          (_) => ResolutionSheet(
            acceptedAt: acceptedAt,
            arrivedAt: arrivedAt,
            now: now,
          ),
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
    final accepted = widget.acceptedAt;
    final arrived = widget.arrivedAt;
    final now = widget.now ?? DateTime.now();
    final hhmm = DateFormat('HH:mm');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SecuriaSpace.md,
          SecuriaSpace.sm,
          SecuriaSpace.md,
          SecuriaSpace.md,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: PatrolColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: SecuriaSpace.md),
              const DispatchFlow(current: 3),
              const SizedBox(height: SecuriaSpace.xs),
              Text(
                DispatchStrings.resolveTitle,
                style: PatrolTypography.headline,
              ),
              if (accepted != null) ...[
                const SizedBox(height: SecuriaSpace.xs),
                Wrap(
                  spacing: SecuriaSpace.md,
                  runSpacing: SecuriaSpace.xxs,
                  children: [
                    _TimelineItem(
                      DispatchStrings.resolveAccepted,
                      hhmm.format(accepted),
                    ),
                    if (arrived != null)
                      _TimelineItem(
                        DispatchStrings.resolveArrived,
                        hhmm.format(arrived),
                      ),
                    _TimelineItem(
                      DispatchStrings.resolveDuration,
                      DispatchStrings.minutes(
                        now.difference(accepted).inMinutes,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: SecuriaSpace.md),
              for (final option in ResolutionOutcome.values) ...[
                _OutcomeOption(
                  outcome: option,
                  selected: option == outcome,
                  onTap: () => setState(() => _outcome = option),
                ),
                const SizedBox(height: SecuriaSpace.xs - 1),
              ],
              const SizedBox(height: SecuriaSpace.xs),
              TextField(
                controller: _noteController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: PatrolTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: DispatchStrings.resolveNoteHint,
                  hintStyle: PatrolTypography.bodyMedium.copyWith(
                    color: PatrolColors.inkMuted,
                  ),
                  filled: true,
                  fillColor: PatrolColors.card,
                  contentPadding: const EdgeInsets.all(SecuriaSpace.md - 2),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SecuriaRadius.md),
                    borderSide: const BorderSide(
                      color: PatrolColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SecuriaRadius.md),
                    borderSide: const BorderSide(
                      color: PatrolColors.inkMuted,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SecuriaSpace.md),
              PrimaryActionButton(
                label: DispatchStrings.resolveConfirm,
                semanticHint:
                    outcome == null ? DispatchStrings.resolveChooseFirst : null,
                onPressed:
                    outcome == null
                        ? null
                        : () => Navigator.of(
                          context,
                        ).pop(outcome.buildNote(_noteController.text)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String value;

  const _TimelineItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final muted = PatrolTypography.mono(
      size: 12,
      color: PatrolColors.inkMuted,
      weight: FontWeight.w500,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label ', style: muted),
          TextSpan(text: value, style: PatrolTypography.mono(size: 12)),
        ],
      ),
    );
  }
}

/// Opción de resultado de 64 px, grande para tocar con guantes
class _OutcomeOption extends StatelessWidget {
  final ResolutionOutcome outcome;
  final bool selected;
  final VoidCallback onTap;

  const _OutcomeOption({
    required this.outcome,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SecuriaRadius.md + 2);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: outcome.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? PatrolColors.actionSoft : PatrolColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? PatrolColors.action : PatrolColors.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SecuriaTouch.patrol),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SecuriaSpace.md - 2,
                vertical: SecuriaSpace.xs,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: SecuriaMotion.of(context, SecuriaMotion.fast),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            selected
                                ? PatrolColors.action
                                : PatrolColors.inkMuted,
                        width: selected ? 7 : 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: SecuriaSpace.sm),
                  Expanded(
                    child: Text(outcome.label, style: PatrolTypography.label),
                  ),
                  Icon(outcome.icon, size: 20, color: PatrolColors.inkMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
