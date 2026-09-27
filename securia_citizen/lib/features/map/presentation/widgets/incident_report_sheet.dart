import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
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
/// pasa, puede adjuntar una foto y escribir una observación antes de enviar.
class IncidentReportSheet extends StatefulWidget {
  const IncidentReportSheet({super.key});

  static Future<IncidentReport?> show(BuildContext context) {
    return showModalBottomSheet<IncidentReport>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const IncidentReportSheet(),
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHeader(
                title: SosStrings.reportTitle,
                subtitle: SosStrings.reportSubtitle,
              ),
              const SizedBox(height: 16),
              const _StepLabel(SosStrings.reportStepType),
              const SizedBox(height: 10),
              IncidentTypeGrid(
                types: IncidentType.reportTypes,
                selected: type,
                onSelected: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 18),
              const _StepLabel(SosStrings.reportStepPhoto),
              const SizedBox(height: 10),
              EvidencePhotoField(
                photoPath: _photoPath,
                onChanged: (path) => setState(() => _photoPath = path),
              ),
              const SizedBox(height: 18),
              const _StepLabel(SosStrings.reportStepObservation),
              const SizedBox(height: 10),
              ObservationField(controller: _observationController),
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: type == null ? null : () => _send(type),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    type == null
                        ? SosStrings.reportChooseType
                        : SosStrings.reportSend,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.pureWhite,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
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
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}
