import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Tarjeta superior al tocar un marcador: qué pasó, cuándo y dónde
class IncidentQuickPreviewSheet extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onViewFullDetail;
  final VoidCallback onClose;

  const IncidentQuickPreviewSheet({
    super.key,
    required this.incident,
    required this.onViewFullDetail,
    required this.onClose,
  });

  static const String _viewDetail = 'Ver detalle';
  static const String _close = 'Cerrar';

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(incident.timestamp);

    return Material(
      color: AppColors.surface,
      elevation: 4,
      shadowColor: AppColors.ink.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(SecuriaRadius.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SecuriaSpace.md,
          SecuriaSpace.sm,
          SecuriaSpace.xxs,
          SecuriaSpace.sm,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(incident.type.icon, color: AppColors.incident),
            ),
            const SizedBox(width: SecuriaSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(incident.type.title, style: AppTypography.titleMedium),
                  Text(
                    '$time · ${incident.location.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall,
                  ),
                  Text(incident.status.label, style: AppTypography.caption),
                ],
              ),
            ),
            TextButton(
              onPressed: onViewFullDetail,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                minimumSize: const Size(SecuriaTouch.min, SecuriaTouch.min),
              ),
              child: Text(_viewDetail, style: AppTypography.buttonLabel),
            ),
            IconButton(
              tooltip: _close,
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
