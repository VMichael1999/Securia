import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/strings/auth_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../map/presentation/bloc/citizen_bloc.dart';
import '../../../map/presentation/bloc/citizen_state.dart';
import '../../../auth/presentation/views/citizen_login_view.dart';

/// Pantalla de Perfil del Ciudadano con Datos de Emergencia y Centrales de Auxilio
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
            child: const Text(AuthStrings.logoutCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              AuthStrings.logoutConfirm,
              style: TextStyle(
                color: AppColors.emergencyRed,
                fontWeight: FontWeight.w800,
              ),
            ),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Perfil y Seguridad',
          style: AppTypography.titleLarge.copyWith(fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CitizenBloc, CitizenState>(
        builder: (context, state) {
          final profile = state.citizenProfile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tarjeta de Usuario Ciudadano
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryNavy,
                        child: Text(
                          initialsOf(profile.fullName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: AppTypography.titleLarge.copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'DNI: ${profile.dni} • ${profile.phone}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '✓ Identidad Verificada RENIEC',
                                style: TextStyle(
                                  color: AppColors.successEmerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Datos Médicos de Emergencia
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.emergencyRed, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Ficha Médica para Rescate',
                            style: AppTypography.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow('Grupo Sanguíneo', _orNotRegistered(profile.bloodType)),
                      const Divider(height: 18, color: AppColors.border),
                      _buildInfoRow('Alergias Conocidas', 'Ninguna registrada'),
                      const Divider(height: 18, color: AppColors.border),
                      _buildInfoRow('Dirección Registrada', _orNotRegistered(profile.homeAddress)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Contacto de Emergencia
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.contact_phone_rounded, color: AppColors.accentBlue, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Contacto de Emergencia',
                            style: AppTypography.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Expanded: el nombre lo escribe el ciudadano y puede ser largo
                          Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _orNotRegistered(profile.emergencyContactName),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.emergencyContactPhone,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                              ),
                            ],
                          ),
                          ),
                          if (profile.emergencyContactPhone.trim().isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.accentBlue,
                                  content: Text('Llamando a ${profile.emergencyContactName}...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('Llamar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Centrales de Emergencia Nacional
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Líneas Gratuitas de Emergencia',
                        style: AppTypography.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildEmergencyPhoneRow(context, 'Policía Nacional del Perú', '105', Icons.local_police_rounded, AppColors.primaryBlue),
                      const Divider(height: 16, color: AppColors.border),
                      _buildEmergencyPhoneRow(context, 'Cuerpo General de Bomberos', '116', Icons.fire_truck_rounded, AppColors.emergencyRed),
                      const Divider(height: 16, color: AppColors.border),
                      _buildEmergencyPhoneRow(context, 'SAMU Ambulancia Médica', '106', Icons.medical_services_rounded, const Color(0xFFE11D48)),
                      const Divider(height: 16, color: AppColors.border),
                      _buildEmergencyPhoneRow(context, 'Central de Serenazgo y Vecinos', '318-5050', Icons.shield_rounded, AppColors.successEmerald),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Cerrar sesión
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      AuthStrings.logout,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.emergencyRed,
                      side: const BorderSide(color: AppColors.emergencyRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        // Flexible: una dirección larga baja de línea en vez de desbordar
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyPhoneRow(
    BuildContext context,
    String name,
    String number,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text('Marcar $number', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.call_outlined, color: color),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Llamando a $name ($number)...')),
            );
          },
        ),
      ],
    );
  }
}
