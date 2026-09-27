import 'package:flutter/material.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import 'hold_sos_button.dart';

/// Controles flotantes sobre el mapa, sin panel de fondo:
/// SOS inmediato (mantener presionado) y reporte con detalle.
class SosActionPanel extends StatelessWidget {
  final bool isSending;
  final VoidCallback onSosTriggered;
  final VoidCallback onReport;

  const SosActionPanel({
    super.key,
    required this.isSending,
    required this.onSosTriggered,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HoldSosButton(
          size: 128,
          isSending: isSending,
          onTriggered: onSosTriggered,
        ),
        const SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryNavy.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: isSending ? null : onReport,
            icon: const Icon(Icons.edit_note_rounded, size: 22),
            label: const Text(
              SosStrings.reportButton,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.pureWhite,
              disabledBackgroundColor: AppColors.border,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: AppColors.pureWhite, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
