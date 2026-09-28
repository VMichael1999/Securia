import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/auth_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Casilla de consentimiento con área de toque completa (fila entera)
class ConsentTile extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ConsentTile({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: text,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(SecuriaRadius.md),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SecuriaSpace.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: SecuriaTouch.min,
                height: SecuriaTouch.min / 2 + 8,
                child: Checkbox(
                  value: value,
                  onChanged: (v) => onChanged(v ?? false),
                  activeColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.inkSecondary, width: 2),
                ),
              ),
              const SizedBox(width: SecuriaSpace.xxs),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: SecuriaSpace.xxs),
                  child: Text(text, style: AppTypography.bodyMedium.copyWith(color: AppColors.ink)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja con la política de datos en lenguaje simple
class DataPolicySheet extends StatelessWidget {
  const DataPolicySheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SecuriaRadius.sheet),
          ),
        ),
        builder: (_) => const DataPolicySheet(),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SecuriaSpace.xl,
          SecuriaSpace.xl,
          SecuriaSpace.xl,
          SecuriaSpace.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AuthStrings.policyTitle, style: AppTypography.titleLarge),
            const SizedBox(height: SecuriaSpace.md),
            for (final (title, body) in AuthStrings.policy) ...[
              Text(title, style: AppTypography.titleMedium),
              const SizedBox(height: SecuriaSpace.xxs),
              Text(body, style: AppTypography.bodyMedium),
              const SizedBox(height: SecuriaSpace.md),
            ],
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.onColor,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SecuriaRadius.lg),
                ),
              ),
              child: Text(AuthStrings.policyClose, style: AppTypography.buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
