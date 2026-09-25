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

  const CitizenProfileModel({
    required this.id,
    required this.fullName,
    required this.dni,
    required this.phone,
    required this.email,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.bloodType = 'O+',
    this.homeAddress = 'Av. Javier Prado Este 2450, San Borja',
    this.avatarUrl,
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
        bloodType: json['bloodType'] as String? ?? 'O+',
        homeAddress: json['homeAddress'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );
}
