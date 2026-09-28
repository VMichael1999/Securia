/// Motivo por el que no se pudo iniciar sesión o registrar a un ciudadano
enum CitizenAuthError {
  /// No existe una cuenta con ese DNI
  notRegistered,

  /// El DNI existe pero el celular no coincide con el registrado
  phoneMismatch,

  /// Ya existe una cuenta con ese DNI
  alreadyRegistered,
}

/// Error de autenticación del ciudadano con su motivo tipado
class CitizenAuthException implements Exception {
  final CitizenAuthError error;

  const CitizenAuthException(this.error);

  @override
  String toString() => 'CitizenAuthException(${error.name})';
}

/// Normaliza un celular a solo dígitos para comparar ("900 000 001" == "900000001")
String normalizePhone(String phone) => phone.replaceAll(RegExp(r'\D'), '');
