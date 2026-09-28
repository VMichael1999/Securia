import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/strings/auth_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../home/presentation/views/citizen_home_shell.dart';
import '../cubit/citizen_auth_cubit.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/consent_tile.dart';

/// Registro de un nuevo ciudadano: solo lo necesario para que la patrulla
/// sepa quién pide ayuda y a quién avisar
class CitizenRegisterView extends StatelessWidget {
  const CitizenRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CitizenAuthCubit(getIt<ISecuriaRepository>()),
      child: const _CitizenRegisterForm(),
    );
  }
}

class _CitizenRegisterForm extends StatefulWidget {
  const _CitizenRegisterForm();

  @override
  State<_CitizenRegisterForm> createState() => _CitizenRegisterFormState();
}

class _CitizenRegisterFormState extends State<_CitizenRegisterForm> {
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  String? _nameError;
  String? _dniError;
  String? _phoneError;
  String? _contactPhoneError;
  bool _dataConsent = false;
  bool _healthConsent = false;
  bool _showConsentError = false;

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _dniController,
      _phoneController,
      _contactNameController,
      _contactPhoneController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final contactPhone = _contactPhoneController.text;
    setState(() {
      _nameError =
          CitizenAuthValidators.isValidFullName(_nameController.text)
              ? null
              : AuthStrings.fullNameInvalid;
      _dniError =
          CitizenAuthValidators.isValidDni(_dniController.text)
              ? null
              : AuthStrings.dniInvalid;
      _phoneError =
          CitizenAuthValidators.isValidPhone(_phoneController.text)
              ? null
              : AuthStrings.phoneInvalid;
      // El contacto es opcional, pero si se escribe debe ser válido
      _contactPhoneError =
          contactPhone.isEmpty ||
                  CitizenAuthValidators.isValidPhone(contactPhone)
              ? null
              : AuthStrings.phoneInvalid;
    });
    final hasErrors = [
      _nameError,
      _dniError,
      _phoneError,
      _contactPhoneError,
    ].any((e) => e != null);
    setState(() => _showConsentError = !_dataConsent);
    if (hasErrors || !_dataConsent) return;

    final now = DateTime.now();
    FocusScope.of(context).unfocus();
    context.read<CitizenAuthCubit>().register(
      fullName: _nameController.text,
      dni: _dniController.text,
      phone: _phoneController.text,
      emergencyContactName: _contactNameController.text,
      emergencyContactPhone: contactPhone,
      dataConsentAt: now,
      healthDataConsentAt: _healthConsent ? now : null,
    );
  }

  void _openHome(CitizenProfileModel citizen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => CitizenHomeShell(citizen: citizen)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CitizenAuthCubit, CitizenAuthState>(
      listenWhen: (prev, curr) => curr.citizen != null && prev.citizen == null,
      listener: (context, state) => _openHome(state.citizen!),
      builder: (context, state) {
        final error = state.error;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            foregroundColor: AppColors.ink,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SecuriaSpace.xl,
                0,
                SecuriaSpace.xl,
                SecuriaSpace.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AuthStrings.registerTitle,
                    style: AppTypography.headline,
                  ),
                  const SizedBox(height: SecuriaSpace.xxs),
                  Text(
                    AuthStrings.registerSubtitle,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: SecuriaSpace.xl),
                  AuthTextField(
                    label: AuthStrings.fullNameLabel,
                    hint: AuthStrings.fullNameHint,
                    icon: Icons.person_outline_rounded,
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    errorText: _nameError,
                  ),
                  const SizedBox(height: SecuriaSpace.md),
                  AuthTextField(
                    label: AuthStrings.dniLabel,
                    hint: AuthStrings.dniHint,
                    icon: Icons.badge_outlined,
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    digitsOnly: true,
                    errorText: _dniError,
                  ),
                  const SizedBox(height: SecuriaSpace.md),
                  AuthTextField(
                    label: AuthStrings.phoneLabel,
                    hint: AuthStrings.phoneHint,
                    icon: Icons.phone_iphone_rounded,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    digitsOnly: true,
                    errorText: _phoneError,
                  ),
                  const SizedBox(height: SecuriaSpace.xl),
                  Text(
                    AuthStrings.emergencySection,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: SecuriaSpace.sm),
                  AuthTextField(
                    label: AuthStrings.emergencyNameLabel,
                    hint: AuthStrings.emergencyNameHint,
                    icon: Icons.contact_emergency_outlined,
                    controller: _contactNameController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: SecuriaSpace.md),
                  AuthTextField(
                    label: AuthStrings.emergencyPhoneLabel,
                    hint: AuthStrings.phoneHint,
                    icon: Icons.phone_forwarded_outlined,
                    controller: _contactPhoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    digitsOnly: true,
                    errorText: _contactPhoneError,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: SecuriaSpace.xl),
                  Text(AuthStrings.consentSection, style: AppTypography.titleMedium),
                  const SizedBox(height: SecuriaSpace.xxs),
                  ConsentTile(
                    text: AuthStrings.dataConsent,
                    value: _dataConsent,
                    onChanged: (v) => setState(() {
                      _dataConsent = v;
                      if (v) _showConsentError = false;
                    }),
                  ),
                  ConsentTile(
                    text: AuthStrings.healthConsent,
                    value: _healthConsent,
                    onChanged: (v) => setState(() => _healthConsent = v),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => DataPolicySheet.show(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        minimumSize: const Size(SecuriaTouch.min, SecuriaTouch.min),
                      ),
                      child: Text(
                        AuthStrings.readPolicy,
                        style: AppTypography.buttonLabel.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  if (_showConsentError)
                    AuthErrorBanner(message: AuthStrings.consentRequired),
                  if (error != null) ...[
                    const SizedBox(height: SecuriaSpace.md),
                    AuthErrorBanner(message: AuthStrings.error(error)),
                  ],
                  const SizedBox(height: SecuriaSpace.xl),
                  AuthSubmitButton(
                    label: AuthStrings.registerButton,
                    isLoading: state.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: SecuriaSpace.xs),
                  AuthSwitchLink(
                    question: AuthStrings.haveAccount,
                    action: AuthStrings.goToLogin,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
