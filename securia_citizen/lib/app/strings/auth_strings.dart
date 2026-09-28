import 'package:securia_core/securia_core.dart';

/// Textos de inicio de sesión, registro, consentimiento y cierre de sesión
class AuthStrings {
  AuthStrings._();

  // Marca
  static const String brand = 'Securia';
  static const String brandTagline = 'Pide ayuda en segundos';

  // Login
  static const String loginTitle = 'Inicia sesión';
  static const String loginSubtitle =
      'Con tu DNI y el celular con el que te registraste.';
  static const String dniLabel = 'DNI';
  static const String dniHint = '8 dígitos';
  static const String phoneLabel = 'Celular';
  static const String phoneHint = '9 dígitos';
  static const String loginButton = 'Ingresar';
  static const String noAccount = '¿Primera vez en Securia?';
  static const String goToRegister = 'Crear cuenta';
  static const String demoButton = 'Entrar con la cuenta demo';
  static const String demoHint = 'Solo en desarrollo · datos ficticios';
  static const String emergencyNote =
      '¿Es una emergencia y no tienes cuenta? Llama al 105.';

  // Registro
  static const String registerTitle = 'Crea tu cuenta';
  static const String registerSubtitle =
      'Tus datos llegan a la patrulla solo cuando pides ayuda.';
  static const String fullNameLabel = 'Nombres y apellidos';
  static const String fullNameHint = 'Como figura en tu DNI';
  static const String emergencySection = 'Contacto de emergencia (opcional)';
  static const String emergencyNameLabel = 'Nombre del contacto';
  static const String emergencyNameHint = 'Ej.: Ana Pérez (hermana)';
  static const String emergencyPhoneLabel = 'Celular del contacto';
  static const String registerButton = 'Crear cuenta e ingresar';
  static const String haveAccount = '¿Ya tienes cuenta?';
  static const String goToLogin = 'Inicia sesión';

  // Consentimiento (Ley 29733)
  static const String consentSection = 'Tus datos';
  static const String dataConsent =
      'Acepto que Securia trate mis datos personales para atender mis alertas.';
  static const String healthConsent =
      'Autorizo guardar datos de salud (grupo sanguíneo, alergias) para que me atiendan mejor en una emergencia. Opcional.';
  static const String readPolicy = 'Leer cómo usamos tus datos';
  static const String consentRequired =
      'Para crear tu cuenta necesitamos tu autorización.';
  static const String policyTitle = 'Cómo usamos tus datos';
  static const List<(String, String)> policy = [
    (
      'Para qué',
      'Usamos tu nombre, DNI, celular y ubicación solo para enviar tus alertas a la patrulla más cercana y dar seguimiento a tu caso.',
    ),
    (
      'Quién los ve',
      'Solo la unidad que atiende tu alerta y la central. No los vendemos ni los compartimos con terceros.',
    ),
    (
      'Datos de salud',
      'Tu grupo sanguíneo y alergias son datos sensibles. Solo los guardamos si lo autorizas aparte, y puedes retirarlo cuando quieras.',
    ),
    (
      'Tus derechos',
      'Puedes pedir ver, corregir o borrar tus datos en cualquier momento, según la Ley N.° 29733 de Protección de Datos Personales.',
    ),
  ];
  static const String policyClose = 'Entendido';

  // Validación
  static const String dniInvalid = 'El DNI tiene 8 dígitos';
  static const String phoneInvalid = 'El celular tiene 9 dígitos';
  static const String fullNameInvalid = 'Escribe tu nombre y apellido';

  static String error(CitizenAuthError error) => switch (error) {
        CitizenAuthError.notRegistered =>
          'No encontramos una cuenta con ese DNI. Crea una para continuar.',
        CitizenAuthError.phoneMismatch =>
          'El celular no coincide con el que registraste para ese DNI.',
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
