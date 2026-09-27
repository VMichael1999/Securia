import 'package:securia_core/securia_core.dart';

/// Textos de inicio de sesión, registro y cierre de sesión del ciudadano
class AuthStrings {
  AuthStrings._();

  // Login
  static const String loginTitle = 'Iniciar sesión';
  static const String loginSubtitle =
      'Ingresa con tu DNI y el celular con el que te registraste.';
  static const String dniLabel = 'DNI';
  static const String dniHint = '8 dígitos';
  static const String phoneLabel = 'Celular';
  static const String phoneHint = '9 dígitos';
  static const String loginButton = 'Ingresar';
  static const String noAccount = '¿Primera vez en Securia?';
  static const String goToRegister = 'Crear cuenta';

  // Registro
  static const String registerTitle = 'Crear cuenta';
  static const String registerSubtitle =
      'Tus datos llegan a la patrulla cuando envías una alerta.';
  static const String fullNameLabel = 'Nombres y apellidos';
  static const String fullNameHint = 'Como figura en tu DNI';
  static const String emergencySection = 'Contacto de emergencia (opcional)';
  static const String emergencyNameLabel = 'Nombre del contacto';
  static const String emergencyNameHint = 'Ej.: Ana Pérez (hermana)';
  static const String emergencyPhoneLabel = 'Celular del contacto';
  static const String registerButton = 'Crear cuenta e ingresar';
  static const String haveAccount = '¿Ya tienes cuenta?';
  static const String goToLogin = 'Iniciar sesión';

  // Validación
  static const String dniInvalid = 'El DNI debe tener 8 dígitos';
  static const String phoneInvalid = 'El celular debe tener 9 dígitos';
  static const String fullNameInvalid = 'Ingresa tu nombre completo';

  static String error(CitizenAuthError error) => switch (error) {
    CitizenAuthError.notRegistered =>
      'No encontramos una cuenta con ese DNI. Crea una para continuar.',
    CitizenAuthError.phoneMismatch =>
      'El celular no coincide con el registrado para ese DNI.',
    CitizenAuthError.alreadyRegistered =>
      'Ese DNI ya tiene una cuenta. Inicia sesión.',
  };

  // Cierre de sesión
  static const String logout = 'Cerrar sesión';
  static const String logoutTitle = '¿Cerrar sesión?';
  static const String logoutBody =
      'Para enviar alertas tendrás que volver a ingresar con tu DNI.';
  static const String logoutConfirm = 'Cerrar sesión';
  static const String logoutCancel = 'Cancelar';

  // Perfil sin datos
  static const String notRegistered = 'No registrado';
}
