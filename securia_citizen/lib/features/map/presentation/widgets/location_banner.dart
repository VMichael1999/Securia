import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../data/location_service.dart';

/// Tarjeta superior del mapa: dónde estás y con qué precisión.
///
/// Si la ubicación falla, se nota antes de necesitarla. El SOS nunca se
/// desactiva: solo se explica con qué ubicación saldría.
class LocationBanner extends StatelessWidget {
  final LocationStatus status;
  final String address;
  final double? accuracyMeters;
  final DateTime? takenAt;
  final int nearbyReports;
  final VoidCallback onFixLocation;

  const LocationBanner({
    super.key,
    required this.status,
    required this.address,
    required this.accuracyMeters,
    required this.takenAt,
    required this.nearbyReports,
    required this.onFixLocation,
  });

  int get _meters => (accuracyMeters ?? 0).round();

  String get _age {
    final at = takenAt;
    if (at == null) return SosStrings.agoMinutes(1);
    return SosStrings.agoMinutes(DateTime.now().difference(at).inMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      LocationStatus.locating => const _Card(
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(width: SecuriaSpace.sm),
              Expanded(child: Text(SosStrings.locating)),
            ],
          ),
        ),
      LocationStatus.precise => _Card(
          child: Row(
            children: [
              const Icon(Icons.my_location_rounded,
                  color: AppColors.help, size: 22),
              const SizedBox(width: SecuriaSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label,
                          ),
                        ),
                        const SizedBox(width: SecuriaSpace.xs),
                        Text(
                          SosStrings.accuracy(_meters),
                          style: AppTypography.mono(
                            size: 13,
                            color: AppColors.help,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      nearbyReports == 0
                          ? SosStrings.noNearbyReports
                          : SosStrings.nearbyReports(nearbyReports),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      LocationStatus.imprecise => _Warning(
          icon: Icons.location_searching_rounded,
          title: SosStrings.impreciseTitle,
          body: SosStrings.impreciseBody(_age, _meters),
          action: SosStrings.impreciseAction,
          onAction: onFixLocation,
        ),
      LocationStatus.denied => _Warning(
          icon: Icons.location_disabled_rounded,
          title: SosStrings.deniedTitle,
          body: SosStrings.deniedBody,
          action: SosStrings.deniedAction,
          onAction: onFixLocation,
        ),
      LocationStatus.disabled => _Warning(
          icon: Icons.location_off_rounded,
          title: SosStrings.disabledTitle,
          body: SosStrings.disabledBody,
          action: SosStrings.disabledAction,
          onAction: onFixLocation,
        ),
    };
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.ink.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(SecuriaRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SecuriaSpace.md,
          vertical: SecuriaSpace.sm,
        ),
        child: DefaultTextStyle(style: AppTypography.label, child: child),
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onAction;

  const _Warning({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.ink, size: 22),
                const SizedBox(width: SecuriaSpace.sm),
                Expanded(child: Text(title, style: AppTypography.titleMedium)),
              ],
            ),
            const SizedBox(height: SecuriaSpace.xxs),
            Text(body, style: AppTypography.bodySmall),
            const SizedBox(height: SecuriaSpace.xs),
            SizedBox(
              height: SecuriaTouch.min,
              child: OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.ink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SecuriaRadius.md),
                  ),
                ),
                child: Text(action, style: AppTypography.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
