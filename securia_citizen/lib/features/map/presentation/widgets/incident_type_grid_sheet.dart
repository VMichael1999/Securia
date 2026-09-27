import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import 'incident_report_fields.dart';

/// Hoja inferior con una cuadrícula de tipos de incidente.
///
/// Un solo toque sobre un tipo lo devuelve y cierra la hoja. Se usa para
/// precisar un SOS inmediato ya enviado.
class IncidentTypeGridSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<IncidentType> types;
  final Widget? leading;
  final String? skipLabel;

  const IncidentTypeGridSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.types,
    this.leading,
    this.skipLabel,
  });

  /// Abre la hoja y devuelve el tipo elegido, o `null` si se cierra u omite.
  static Future<IncidentType?> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<IncidentType> types,
    Widget? leading,
    String? skipLabel,
  }) {
    return showModalBottomSheet<IncidentType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (_) => IncidentTypeGridSheet(
            title: title,
            subtitle: subtitle,
            types: types,
            leading: leading,
            skipLabel: skipLabel,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(title: title, subtitle: subtitle, leading: leading),
            const SizedBox(height: 18),
            IncidentTypeGrid(
              types: types,
              onSelected: (type) => Navigator.of(context).pop(type),
            ),
            if (skipLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  skipLabel!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
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
