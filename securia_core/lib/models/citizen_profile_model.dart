/// Modelo de Perfil de Ciudadano
class CitizenProfileModel {
  final String id;
  final String fullName;
  final String dni;
  final String phone;
  final String email;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String bloodType;
  final String homeAddress;
  final String? avatarUrl;

  /// Cuándo aceptó el tratamiento de sus datos personales (Ley 29733)
  final DateTime? dataConsentAt;

  /// Cuándo autorizó guardar datos de salud (dato sensible, consentimiento aparte)
  final DateTime? healthDataConsentAt;

  bool get hasHealthDataConsent => healthDataConsentAt != null;

  const CitizenProfileModel({
    required this.id,
    required this.fullName,
    required this.dni,
    required this.phone,
    required this.email,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.bloodType = '',
    this.homeAddress = '',
    this.avatarUrl,
    this.dataConsentAt,
    this.healthDataConsentAt,
  });

  CitizenProfileModel copyWith({
    String? id,
    String? fullName,
    String? dni,
    String? phone,
    String? email,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? bloodType,
    String? homeAddress,
    String? avatarUrl,
    DateTime? dataConsentAt,
    DateTime? healthDataConsentAt,
  }) {
    return CitizenProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dni: dni ?? this.dni,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      bloodType: bloodType ?? this.bloodType,
      homeAddress: homeAddress ?? this.homeAddress,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dataConsentAt: dataConsentAt ?? this.dataConsentAt,
      healthDataConsentAt: healthDataConsentAt ?? this.healthDataConsentAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'dni': dni,
        'phone': phone,
        'email': email,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'bloodType': bloodType,
        'homeAddress': homeAddress,
        'avatarUrl': avatarUrl,
        'dataConsentAt': dataConsentAt?.toIso8601String(),
        'healthDataConsentAt': healthDataConsentAt?.toIso8601String(),
      };

  factory CitizenProfileModel.fromJson(Map<String, dynamic> json) =>
      CitizenProfileModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        dni: json['dni'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        emergencyContactName: json['emergencyContactName'] as String,
        emergencyContactPhone: json['emergencyContactPhone'] as String,
        bloodType: json['bloodType'] as String? ?? '',
        homeAddress: json['homeAddress'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        dataConsentAt: _date(json['dataConsentAt']),
        healthDataConsentAt: _date(json['healthDataConsentAt']),
      );

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
