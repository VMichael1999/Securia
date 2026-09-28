import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import 'incident_report_fields.dart';

/// Reporte armado por el ciudadano: tipo obligatorio, foto y observación opcionales
class IncidentReport {
  final IncidentType type;
  final String? description;
  final String? photoPath;

  const IncidentReport({required this.type, this.description, this.photoPath});
}

/// Hoja de reporte con detalle.
///
/// A diferencia del SOS (que sale al instante), aquí el ciudadano elige qué
/// pasa, puede adjuntar una foto y escribir lo que vio antes de enviar. El
/// botón nombra lo que envía y abajo se ve con qué ubicación sale.
class IncidentReportSheet extends StatefulWidget {
  /// "Sale con tu ubicación actual · ±8 m"
  final String locationCaption;

  const IncidentReportSheet({super.key, required this.locationCaption});

  static Future<IncidentReport?> show(
    BuildContext context, {
    required String locationCaption,
  }) {
    return showModalBottomSheet<IncidentReport>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SecuriaRadius.sheet),
        ),
      ),
      builder: (_) => IncidentReportSheet(locationCaption: locationCaption),
    );
  }

  @override
  State<IncidentReportSheet> createState() => _IncidentReportSheetState();
}

class _IncidentReportSheetState extends State<IncidentReportSheet> {
  final _observationController = TextEditingController();
  IncidentType? _type;
  String? _photoPath;

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  void _send(IncidentType type) {
    final observation = _observationController.text.trim();
    Navigator.of(context).pop(
      IncidentReport(
        type: type,
        description: observation.isEmpty ? null : observation,
        photoPath: _photoPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SecuriaSpace.lg,
            SecuriaSpace.sm,
            SecuriaSpace.lg,
            SecuriaSpace.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHeader(
                title: SosStrings.reportTitle,
                subtitle: SosStrings.reportSubtitle,
              ),
              const SizedBox(height: SecuriaSpace.md),
              const _StepLabel(SosStrings.reportStepType),
              const SizedBox(height: SecuriaSpace.xs),
              IncidentTypeGrid(
                types: IncidentType.reportTypes,
                selected: type,
                onSelected: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: SecuriaSpace.lg),
              const _StepLabel(SosStrings.reportStepPhoto),
              const SizedBox(height: SecuriaSpace.xs),
              EvidencePhotoField(
                photoPath: _photoPath,
                onChanged: (path) => setState(() => _photoPath = path),
              ),
              const SizedBox(height: SecuriaSpace.lg),
              const _StepLabel(SosStrings.reportStepObservation),
              const SizedBox(height: SecuriaSpace.xs),
              ObservationField(controller: _observationController),
              const SizedBox(height: SecuriaSpace.lg),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: type == null ? null : () => _send(type),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    type == null
                        ? SosStrings.reportChooseType
                        : SosStrings.reportSendType(type.shortLabel),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.buttonLabel,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.onColor,
                    disabledBackgroundColor: AppColors.surfaceMuted,
                    disabledForegroundColor: AppColors.inkMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SecuriaRadius.lg),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SecuriaSpace.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 14,
                    color: AppColors.inkMuted,
                  ),
                  const SizedBox(width: SecuriaSpace.xxs),
                  Flexible(
                    child: Text(
                      widget.locationCaption,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String text;
  const _StepLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.titleMedium);
  }
}
