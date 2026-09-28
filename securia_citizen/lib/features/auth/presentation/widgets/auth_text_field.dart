import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Campo de formulario de acceso: etiqueta arriba, ícono y mensaje de error
class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool digitsOnly;
  final String? errorText;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.digitsOnly = false,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(SecuriaRadius.md),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: SecuriaSpace.xxs + 2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          style: AppTypography.bodyLarge,
          inputFormatters:
              digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.inkMuted),
            errorText: errorText,
            errorStyle: AppTypography.caption.copyWith(color: AppColors.sos),
            prefixIcon: Icon(icon, color: AppColors.ink),
            filled: true,
            fillColor: AppColors.surface,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.ink, width: 2),
            ),
            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.sos, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
