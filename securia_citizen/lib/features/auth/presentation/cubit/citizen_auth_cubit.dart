import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';

/// Estado del inicio de sesión o registro
class CitizenAuthState {
  final bool isLoading;
  final CitizenAuthError? error;
  final CitizenProfileModel? citizen;

  const CitizenAuthState({this.isLoading = false, this.error, this.citizen});
}

/// Inicia sesión, registra y cierra sesión contra el repositorio
class CitizenAuthCubit extends Cubit<CitizenAuthState> {
  final ISecuriaRepository _repository;

  CitizenAuthCubit(this._repository) : super(const CitizenAuthState());

  Future<void> signIn({required String dni, required String phone}) =>
      _run(() => _repository.signInCitizen(dni: dni, phone: phone));

  Future<void> register({
    required String fullName,
    required String dni,
    required String phone,
    required DateTime dataConsentAt,
    DateTime? healthDataConsentAt,
    String emergencyContactName = '',
    String emergencyContactPhone = '',
  }) => _run(
    () => _repository.registerCitizen(
      fullName: fullName,
      dni: dni,
      phone: phone,
      dataConsentAt: dataConsentAt,
      healthDataConsentAt: healthDataConsentAt,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    ),
  );

  Future<void> _run(Future<CitizenProfileModel> Function() action) async {
    if (state.isLoading) return;
    emit(const CitizenAuthState(isLoading: true));
    try {
      emit(CitizenAuthState(citizen: await action()));
    } on CitizenAuthException catch (e) {
      emit(CitizenAuthState(error: e.error));
    }
  }
}

/// Validaciones de formulario compartidas por login y registro
class CitizenAuthValidators {
  CitizenAuthValidators._();

  static bool isValidDni(String value) =>
      RegExp(r'^\d{8}$').hasMatch(value.trim());

  static bool isValidPhone(String value) => normalizePhone(value).length == 9;

  static bool isValidFullName(String value) =>
      value.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length >= 2;
}
