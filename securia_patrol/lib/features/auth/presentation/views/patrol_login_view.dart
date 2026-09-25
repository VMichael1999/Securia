import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../shell/presentation/views/patrol_shell_view.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_event.dart';

/// Pantalla de Inicio de Turno y Autenticación de Unidad de Patrullaje
class PatrolLoginView extends StatefulWidget {
  const PatrolLoginView({super.key});

  @override
  State<PatrolLoginView> createState() => _PatrolLoginViewState();
}

class _PatrolLoginViewState extends State<PatrolLoginView> {
  // Unidades precargadas en el servicio policial
  final List<PatrolUnitModel> _availableUnits = const [
    PatrolUnitModel(
      id: 'patrol_01',
      unitCode: 'PL-402',
      officerName: 'Suboficial R. Mendoza',
      phone: '993 102 481',
      location: GeoLocation(
        latitude: -12.0835,
        longitude: -77.0378,
        address: 'Av. Guardia Civil con Av. Javier Prado, San Borja',
      ),
      coverageRadiusKm: 3.5,
      status: PatrolStatus.disponible,
    ),
    PatrolUnitModel(
      id: 'patrol_02',
      unitCode: 'MOTO-08',
      officerName: 'Técnico C. Paredes',
      phone: '981 742 590',
      location: GeoLocation(
        latitude: -12.0912,
        longitude: -77.0315,
        address: 'Calle Las Begonias, San Isidro',
      ),
      coverageRadiusKm: 2.5,
      status: PatrolStatus.disponible,
    ),
    PatrolUnitModel(
      id: 'patrol_03',
      unitCode: 'SERENAZGO-14',
      officerName: 'Agente M. Alarcón',
      phone: '974 610 289',
      location: GeoLocation(
        latitude: -12.0790,
        longitude: -77.0280,
        address: 'Av. San Borja Sur con Av. Aviación',
      ),
      coverageRadiusKm: 3.0,
      status: PatrolStatus.disponible,
    ),
  ];

  late PatrolUnitModel _selectedUnit;
  final _placaController = TextEditingController(text: 'PNP-74921');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedUnit = _availableUnits.first;
  }

  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);

    // Inicializar BLoC con la patrulla seleccionada
    context.read<PatrolBloc>().add(PatrolStarted(_selectedUnit));

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PatrolShellView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Logo e Iconografía Táctica Institucional
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: PatrolColors.policeBlue,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: PatrolColors.policeBlue.withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_police_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Column(
                  children: [
                    Text(
                      'SECURIA PATROL',
                      style: PatrolTypography.titleLarge.copyWith(
                        fontSize: 24,
                        letterSpacing: 1.5,
                        color: PatrolColors.policeBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terminal Policial de Despacho e Intervención',
                      style: PatrolTypography.bodySmall.copyWith(
                        color: PatrolColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Text(
                'Selección de Unidad de Patrullaje',
                style: PatrolTypography.titleMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Selector de Unidad Policial
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: PatrolColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PatrolColors.surfaceBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PatrolUnitModel>(
                    value: _selectedUnit,
                    isExpanded: true,
                    dropdownColor: PatrolColors.surfaceCard,
                    icon: const Icon(Icons.arrow_drop_down, color: PatrolColors.policeAccent),
                    items: _availableUnits.map((unit) {
                      return DropdownMenuItem<PatrolUnitModel>(
                        value: unit,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PatrolColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: PatrolColors.policeAccent),
                              ),
                              child: Text(
                                unit.unitCode,
                                style: PatrolTypography.tacticalCode.copyWith(
                                  fontSize: 11,
                                  color: PatrolColors.policeLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${unit.officerName} (${unit.location.address.split(',').first})',
                                style: const TextStyle(
                                  color: PatrolColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedUnit = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Número de Placa / Identificación Policial
              Text(
                'Placa Policial / CIP del Oficial',
                style: PatrolTypography.titleMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _placaController,
                style: const TextStyle(color: PatrolColors.textPrimary, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_outlined, color: PatrolColors.policeAccent),
                  filled: true,
                  fillColor: PatrolColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: PatrolColors.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: PatrolColors.surfaceBorder),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sector Operativo
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PatrolColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PatrolColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_searching_rounded, color: PatrolColors.policeAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sector Asignado',
                            style: TextStyle(
                              color: PatrolColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedUnit.location.address,
                            style: const TextStyle(
                              color: PatrolColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Botón Conectar Guardia Centrado
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PatrolColors.policeBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.power_settings_new_rounded, size: 20, color: Colors.white),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'INICIAR GUARDIA Y CONECTAR RADAR',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
