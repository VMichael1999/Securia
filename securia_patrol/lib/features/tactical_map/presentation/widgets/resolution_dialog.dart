import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';

/// Modal para concluir y registrar la resolución policial del incidente
class ResolutionDialog extends StatefulWidget {
  final IncidentModel incident;
  final Function(String note) onConfirmResolution;

  const ResolutionDialog({
    super.key,
    required this.incident,
    required this.onConfirmResolution,
  });

  @override
  State<ResolutionDialog> createState() => _ResolutionDialogState();
}

class _ResolutionDialogState extends State<ResolutionDialog> {
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _noteController.text =
        'Intervención policial concluida. Situación controlada por la unidad en la zona.';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PatrolColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: PatrolColors.surfaceBorder),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PatrolColors.successGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: PatrolColors.successGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Concluir Intervención',
              style: PatrolTypography.titleLarge.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incidente: ${widget.incident.type.title}',
              style: const TextStyle(
                color: PatrolColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.incident.location.address,
              style: const TextStyle(color: PatrolColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Acta / Reporte de Intervención Policial:',
              style: TextStyle(
                color: PatrolColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              style: const TextStyle(color: PatrolColors.textPrimary, fontSize: 13),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa los detalles de la resolución';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Detalla las acciones tomadas, detenidos, traslado o solución...',
                hintStyle: const TextStyle(color: PatrolColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: PatrolColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PatrolColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PatrolColors.surfaceBorder),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: PatrolColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onConfirmResolution(_noteController.text.trim());
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: PatrolColors.successGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Guardar y Finalizar', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
