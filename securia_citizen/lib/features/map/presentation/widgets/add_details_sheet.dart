import 'package:flutter/material.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
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
            const SizedBox(height: 16),
            ObservationField(controller: _commentController),
            const SizedBox(height: 12),
            EvidencePhotoField(
              photoPath: _photoPath,
              onChanged: (path) => setState(() => _photoPath = path),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed:
                    canSend ? () => Navigator.of(context).pop(_details) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.pureWhite,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  SosStrings.detailsSend,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
