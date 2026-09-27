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
import 'citizen_register_view.dart';

/// Pantalla de acceso: cualquier ciudadano ingresa con su DNI y celular
class CitizenLoginView extends StatelessWidget {
  const CitizenLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CitizenAuthCubit(getIt<ISecuriaRepository>()),
      child: const _CitizenLoginForm(),
    );
  }
}

class _CitizenLoginForm extends StatefulWidget {
  const _CitizenLoginForm();

  @override
  State<_CitizenLoginForm> createState() => _CitizenLoginFormState();
}

class _CitizenLoginFormState extends State<_CitizenLoginForm> {
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _dniError;
  String? _phoneError;

  @override
  void dispose() {
    _dniController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final dni = _dniController.text;
    final phone = _phoneController.text;
    setState(() {
      _dniError =
          CitizenAuthValidators.isValidDni(dni) ? null : AuthStrings.dniInvalid;
      _phoneError =
          CitizenAuthValidators.isValidPhone(phone)
              ? null
              : AuthStrings.phoneInvalid;
    });
    if (_dniError != null || _phoneError != null) return;

    FocusScope.of(context).unfocus();
    context.read<CitizenAuthCubit>().signIn(dni: dni, phone: phone);
  }

  void _openHome(CitizenProfileModel citizen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => CitizenHomeShell(citizen: citizen)),
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
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // Logo y Marca
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.navyGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryNavy.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.shield_rounded,
                              color: AppColors.pureWhite,
                              size: 44,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Securia',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.primaryNavy,
                            fontSize: 32,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Red Ciudadana de Alerta y Seguridad',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  Text(
                    AuthStrings.loginTitle,
                    style: AppTypography.titleLarge.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AuthStrings.loginSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),

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
                  const SizedBox(height: 14),
                  AuthTextField(
                    label: AuthStrings.phoneLabel,
                    hint: AuthStrings.phoneHint,
                    icon: Icons.phone_iphone_rounded,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    digitsOnly: true,
                    errorText: _phoneError,
                    textInputAction: TextInputAction.done,
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 16),
                    AuthErrorBanner(message: AuthStrings.error(error)),
                  ],
                  const SizedBox(height: 24),

                  AuthSubmitButton(
                    label: AuthStrings.loginButton,
                    isLoading: state.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 8),
                  AuthSwitchLink(
                    question: AuthStrings.noAccount,
                    action: AuthStrings.goToRegister,
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CitizenRegisterView(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Banner informativo RENIEC
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.successEmerald,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Conectado a la Central 105 y Serenazgo Municipal. En caso de peligro presiona el botón SOS.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
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
