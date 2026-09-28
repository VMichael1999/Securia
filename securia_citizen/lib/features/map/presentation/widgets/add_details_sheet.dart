import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import 'incident_report_fields.dart';

/// Datos opcionales que el ciudadano agrega a una alerta ya enviada
class AlertDetails {
  final String? description;
  final String? photoPath;

  const AlertDetails({this.description, this.photoPath});

  bool get isEmpty =>
      (description == null || description!.isEmpty) && photoPath == null;
}

/// Hoja para completar una alerta con comentario y foto, después de enviarla.
///
/// Nada aquí es obligatorio: la alerta ya salió y la patrulla ya está avisada.
class AddDetailsSheet extends StatefulWidget {
  const AddDetailsSheet({super.key});

  static Future<AlertDetails?> show(BuildContext context) {
    return showModalBottomSheet<AlertDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SecuriaRadius.sheet),
        ),
      ),
      builder: (_) => const AddDetailsSheet(),
    );
  }

  @override
  State<AddDetailsSheet> createState() => _AddDetailsSheetState();
}

class _AddDetailsSheetState extends State<AddDetailsSheet> {
  final _commentController = TextEditingController();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  AlertDetails get _details => AlertDetails(
    description: _commentController.text.trim(),
    photoPath: _photoPath,
  );

  @override
  Widget build(BuildContext context) {
    final canSend = !_details.isEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SecuriaSpace.lg,
        SecuriaSpace.sm,
        SecuriaSpace.lg,
        MediaQuery.of(context).viewInsets.bottom + SecuriaSpace.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader(
              title: SosStrings.detailsTitle,
              subtitle: SosStrings.detailsSubtitle,
            ),
            const SizedBox(height: SecuriaSpace.md),
            ObservationField(controller: _commentController),
            const SizedBox(height: SecuriaSpace.sm),
            EvidencePhotoField(
              photoPath: _photoPath,
              onChanged: (path) => setState(() => _photoPath = path),
            ),
            const SizedBox(height: SecuriaSpace.md),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed:
                    canSend ? () => Navigator.of(context).pop(_details) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.onColor,
                  disabledBackgroundColor: AppColors.surfaceMuted,
                  disabledForegroundColor: AppColors.inkMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SecuriaRadius.lg),
                  ),
                ),
                child: Text(
                  SosStrings.detailsSend,
                  style: AppTypography.buttonLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
