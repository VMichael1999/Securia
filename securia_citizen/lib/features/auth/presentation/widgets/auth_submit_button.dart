import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Botón principal de login y registro con estado de carga
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.onColor,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.inkMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SecuriaRadius.lg),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.ink,
                ),
              )
            : Text(label, style: AppTypography.buttonLabel),
      ),
    );
  }
}

/// Mensaje de error del formulario (qué pasó, en palabras simples)
class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(SecuriaSpace.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(SecuriaRadius.md),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.ink),
            const SizedBox(width: SecuriaSpace.xs),
            Expanded(child: Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.ink))),
          ],
        ),
      ),
    );
  }
}

/// Enlace inferior "¿Ya tienes cuenta? Inicia sesión"
class AuthSwitchLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const AuthSwitchLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap: con textos grandes o pantallas angostas el enlace baja de línea
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(question, style: AppTypography.bodyMedium),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.help,
            minimumSize: const Size(SecuriaTouch.min, SecuriaTouch.min),
          ),
          child: Text(action, style: AppTypography.buttonLabel),
        ),
      ],
    );
  }
}
