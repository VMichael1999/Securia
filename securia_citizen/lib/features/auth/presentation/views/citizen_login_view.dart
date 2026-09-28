import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/strings/auth_strings.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/utils/phone_launcher.dart';
import '../../../home/presentation/views/citizen_home_shell.dart';
import '../cubit/citizen_auth_cubit.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/brand_mark.dart';
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
      _phoneError = CitizenAuthValidators.isValidPhone(phone)
          ? null
          : AuthStrings.phoneInvalid;
    });
    if (_dniError != null || _phoneError != null) return;

    FocusScope.of(context).unfocus();
    context.read<CitizenAuthCubit>().signIn(dni: dni, phone: phone);
  }

  /// Solo en desarrollo: entra con la cuenta ficticia de los datos semilla
  void _signInDemo() {
    context.read<CitizenAuthCubit>().signIn(
          dni: InMemorySecuriaRepository.demoDni,
          phone: InMemorySecuriaRepository.demoPhone,
        );
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
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SecuriaSpace.xl,
                SecuriaSpace.xl,
                SecuriaSpace.xl,
                SecuriaSpace.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BrandMark(),
                  const SizedBox(height: SecuriaSpace.xxl + SecuriaSpace.xs),
                  Text(AuthStrings.loginTitle, style: AppTypography.headline),
                  const SizedBox(height: SecuriaSpace.xxs),
                  Text(AuthStrings.loginSubtitle, style: AppTypography.bodyMedium),
                  const SizedBox(height: SecuriaSpace.xl),
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
                    textInputAction: TextInputAction.done,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: SecuriaSpace.md),
                    AuthErrorBanner(message: AuthStrings.error(error)),
                  ],
                  const SizedBox(height: SecuriaSpace.xl),
                  AuthSubmitButton(
                    label: AuthStrings.loginButton,
                    isLoading: state.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: SecuriaSpace.xs),
                  AuthSwitchLink(
                    question: AuthStrings.noAccount,
                    action: AuthStrings.goToRegister,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CitizenRegisterView(),
                      ),
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: SecuriaSpace.xs),
                    OutlinedButton(
                      onPressed: state.isLoading ? null : _signInDemo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inkSecondary,
                        side: const BorderSide(color: AppColors.borderStrong),
                        minimumSize: const Size.fromHeight(SecuriaTouch.min),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SecuriaRadius.md),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(AuthStrings.demoButton, style: AppTypography.buttonLabel),
                          Text(AuthStrings.demoHint, style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: SecuriaSpace.xl),
                  // Sin cuenta, la ayuda sigue a una llamada de distancia
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      SecuriaSpace.md,
                      SecuriaSpace.xs,
                      SecuriaSpace.xs,
                      SecuriaSpace.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(SecuriaRadius.md),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AuthStrings.emergencyNote,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              PhoneLauncher.call(SosStrings.policeNumber),
                          icon: const Icon(Icons.call_rounded, size: 18),
                          label: Text(SosStrings.call105, style: AppTypography.buttonLabel),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            minimumSize: const Size(SecuriaTouch.min, SecuriaTouch.min),
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
