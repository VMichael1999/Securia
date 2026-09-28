import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/strings/auth_strings.dart';
import '../../../../app/strings/profile_strings.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/utils/phone_launcher.dart';
import '../../../auth/presentation/views/citizen_login_view.dart';
import '../../../map/presentation/bloc/citizen_bloc.dart';
import '../../../map/presentation/bloc/citizen_state.dart';

/// Perfil del ciudadano: quién es, a quién avisar y a qué números llamar
class CitizenProfileView extends StatelessWidget {
  const CitizenProfileView({super.key});

  /// Iniciales para el avatar, tolerando espacios dobles o un solo nombre
  static String initialsOf(String fullName) => fullName
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  static String _orNotRegistered(String value) =>
      value.trim().isEmpty ? AuthStrings.notRegistered : value;

  Future<void> _call(BuildContext context, String number) async {
    final ok = await PhoneLauncher.call(number);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(SosStrings.callUnavailable)),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AuthStrings.logoutTitle),
        content: const Text(AuthStrings.logoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            child: const Text(AuthStrings.logoutCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.onColor,
            ),
            child: const Text(AuthStrings.logoutConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await getIt<ISecuriaRepository>().signOutCitizen();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CitizenLoginView()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: Text(ProfileStrings.title, style: AppTypography.headline),
      ),
      body: BlocBuilder<CitizenBloc, CitizenState>(
        builder: (context, state) {
          final profile = state.citizenProfile;
          final hasContact = profile.emergencyContactPhone.trim().isNotEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SecuriaSpace.md,
              0,
              SecuriaSpace.md,
              SecuriaSpace.xxl,
            ),
            children: [
              // Identidad
              _Card(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.ink,
                      child: Text(
                        initialsOf(profile.fullName),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: SecuriaSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.fullName, style: AppTypography.titleMedium),
                          Text(
                            ProfileStrings.idLine(profile.dni, profile.phone),
                            style: AppTypography.mono(size: 13, color: AppColors.inkSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contacto de emergencia
              _Card(
                title: ProfileStrings.contactTitle,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _orNotRegistered(profile.emergencyContactName),
                            style: AppTypography.label,
                          ),
                          if (hasContact)
                            Text(
                              profile.emergencyContactPhone,
                              style: AppTypography.mono(size: 13, color: AppColors.inkSecondary),
                            ),
                        ],
                      ),
                    ),
                    if (hasContact)
                      _CallButton(
                        label: ProfileStrings.call,
                        onPressed: () => _call(context, profile.emergencyContactPhone),
                      ),
                  ],
                ),
              ),

              // Ficha médica: solo con consentimiento de datos de salud
              _Card(
                title: ProfileStrings.medicalTitle,
                child: profile.hasHealthDataConsent
                    ? Column(
                        children: [
                          _InfoRow(
                            label: ProfileStrings.bloodType,
                            value: _orNotRegistered(profile.bloodType),
                          ),
                          const Divider(height: SecuriaSpace.lg, color: AppColors.border),
                          const _InfoRow(
                            label: ProfileStrings.allergies,
                            value: ProfileStrings.noAllergies,
                          ),
                        ],
                      )
                    : Text(ProfileStrings.medicalLocked, style: AppTypography.bodyMedium),
              ),

              _Card(
                title: ProfileStrings.addressTitle,
                child: Text(
                  _orNotRegistered(profile.homeAddress),
                  style: AppTypography.bodyLarge,
                ),
              ),

              // Centrales de emergencia
              _Card(
                title: ProfileStrings.linesTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ProfileStrings.linesNote, style: AppTypography.caption),
                    const SizedBox(height: SecuriaSpace.xs),
                    for (final (name, number) in ProfileStrings.lines)
                      Row(
                        children: [
                          Expanded(child: Text(name, style: AppTypography.bodyLarge)),
                          Text(number, style: AppTypography.mono(size: 16)),
                          const SizedBox(width: SecuriaSpace.xs),
                          IconButton(
                            tooltip: '${ProfileStrings.call} $number',
                            onPressed: () => _call(context, number),
                            icon: const Icon(Icons.call_rounded, color: AppColors.ink),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: SecuriaSpace.xs),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(AuthStrings.logout, style: AppTypography.buttonLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.borderStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SecuriaRadius.lg),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final Widget child;

  const _Card({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SecuriaSpace.sm),
      padding: const EdgeInsets.all(SecuriaSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(SecuriaRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTypography.caption),
            const SizedBox(height: SecuriaSpace.xs),
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTypography.bodyMedium),
        const SizedBox(width: SecuriaSpace.sm),
        // Flexible: un valor largo baja de línea en vez de desbordar
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(value, textAlign: TextAlign.end, style: AppTypography.label),
          ),
        ),
      ],
    );
  }
}

class _CallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CallButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.call_rounded, size: 18),
      label: Text(label, style: AppTypography.buttonLabel),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onColor,
        minimumSize: const Size(SecuriaTouch.min, SecuriaTouch.min),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SecuriaRadius.md),
        ),
      ),
    );
  }
}
