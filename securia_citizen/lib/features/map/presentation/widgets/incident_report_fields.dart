import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Cuadrícula de tipos de incidente de alto fijo (no depende del ancho)
class IncidentTypeGrid extends StatelessWidget {
  final List<IncidentType> types;
  final ValueChanged<IncidentType> onSelected;
  final IncidentType? selected;

  const IncidentTypeGrid({
    super.key,
    required this.types,
    required this.onSelected,
    this.selected,
  });

  static const double _tileHeight = 104;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: types.length > 6 ? 4 : 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // Crece con el tamaño de texto del sistema (hasta 150 %)
        mainAxisExtent: MediaQuery.textScalerOf(context).scale(_tileHeight),
      ),
      children: [
        for (final type in types)
          IncidentTypeTile(
            type: type,
            selected: type == selected,
            onTap: () => onSelected(type),
          ),
      ],
    );
  }
}

/// Mosaico grande y táctil de un tipo de incidente.
///
/// En azul neutro con un ícono distinto por tipo: el ciudadano no ve colores
/// de urgencia, que asigna el sistema según el tipo.
class IncidentTypeTile extends StatelessWidget {
  final IncidentType type;
  final VoidCallback onTap;
  final bool selected;

  const IncidentTypeTile({
    super.key,
    required this.type,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SecuriaRadius.lg);

    return Semantics(
      button: true,
      selected: selected,
      label: type.title,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.ink : AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? AppColors.ink : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: SecuriaSpace.xxs,
              vertical: SecuriaSpace.xs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  size: 28,
                  color: selected ? AppColors.onColor : AppColors.incident,
                ),
                const SizedBox(height: SecuriaSpace.xs),
                Text(
                  type.shortLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: selected ? AppColors.onColor : AppColors.ink,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo de observación libre del ciudadano
class ObservationField extends StatelessWidget {
  final TextEditingController controller;

  const ObservationField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 2,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: SosStrings.detailsHint,
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
        counterText: '',
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.all(SecuriaSpace.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SecuriaRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Foto de evidencia: botones Cámara/Galería o la foto adjunta con opción a quitarla
class EvidencePhotoField extends StatelessWidget {
  final String? photoPath;
  final ValueChanged<String?> onChanged;

  const EvidencePhotoField({
    super.key,
    required this.photoPath,
    required this.onChanged,
  });

  Future<void> _pick(ImageSource source) async {
    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) onChanged(photo.path);
    } catch (_) {
      // Simulador o cámara no disponible: se adjunta evidencia simulada
      onChanged(SosStrings.simulatedPhoto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    if (path != null) {
      return _AttachedPhoto(path: path, onRemove: () => onChanged(null));
    }

    return Row(
      children: [
        Expanded(
          child: _PhotoButton(
            label: SosStrings.detailsCamera,
            icon: Icons.camera_alt_outlined,
            onPressed: () => _pick(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PhotoButton(
            label: SosStrings.detailsGallery,
            icon: Icons.photo_library_outlined,
            onPressed: () => _pick(ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PhotoButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.ink),
      label: Text(label, style: AppTypography.label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(SecuriaTouch.min + 4),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SecuriaRadius.md),
        ),
      ),
    );
  }
}

class _AttachedPhoto extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _AttachedPhoto({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isSimulated = path == SosStrings.simulatedPhoto;

    return Container(
      padding: const EdgeInsets.all(SecuriaSpace.xs),
      decoration: BoxDecoration(
        color: AppColors.helpSoft,
        borderRadius: BorderRadius.circular(SecuriaRadius.md),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(SecuriaRadius.sm),
            child: SizedBox(
              width: 48,
              height: 48,
              child:
                  isSimulated
                      ? const ColoredBox(
                        color: AppColors.ink,
                        child: Icon(
                          Icons.photo_camera_back_rounded,
                          color: AppColors.onColor,
                        ),
                      )
                      : Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: SecuriaSpace.sm),
          Expanded(
            child: Text(
              SosStrings.detailsPhotoAttached,
              style: AppTypography.label.copyWith(color: AppColors.help),
            ),
          ),
          IconButton(
            tooltip: SosStrings.detailsRemovePhoto,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.inkSecondary,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// Encabezado común de las hojas inferiores: agarre, título y subtítulo
class SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;

  const SheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.borderStrong,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (leading != null) ...[leading!, const SizedBox(height: 12)],
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    );
  }
}
