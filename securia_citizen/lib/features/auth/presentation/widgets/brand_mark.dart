import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/auth_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Marca de Securia: escudo sobre azul sólido, sin degradados
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(SecuriaRadius.md),
          ),
          child: const Icon(Icons.shield_rounded, color: AppColors.onColor, size: 28),
        ),
        const SizedBox(width: SecuriaSpace.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AuthStrings.brand, style: AppTypography.titleLarge),
            Text(AuthStrings.brandTagline, style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}
