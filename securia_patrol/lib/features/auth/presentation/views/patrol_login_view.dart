import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/injection.dart';
import '../../../../app/strings/shift_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/widgets/patrol_buttons.dart';
import '../../../shell/presentation/views/patrol_shell_view.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_event.dart';

/// Inicio de guardia: elegir la unidad, escribir el CIP e iniciar.
class PatrolLoginView extends StatefulWidget {
  const PatrolLoginView({super.key});

  @override
  State<PatrolLoginView> createState() => _PatrolLoginViewState();
}

class _PatrolLoginViewState extends State<PatrolLoginView> {
  late final List<PatrolUnitModel> _units =
      getIt<ISecuriaRepository>().getSnapshotPatrols();
  late PatrolUnitModel _selected = _units.first;

  // En debug se precarga un CIP ficticio para probar rápido
  final _cip = TextEditingController(text: kDebugMode ? '30000001' : '');
  bool _showError = false;

  static bool _isValidCip(String value) =>
      RegExp(r'^\d{6,9}$').hasMatch(value.trim());

  @override
  void dispose() {
    _cip.dispose();
    super.dispose();
  }

  void _start() {
    if (!_isValidCip(_cip.text)) {
      setState(() => _showError = true);
      return;
    }
    context.read<PatrolBloc>().add(PatrolStarted(_selected));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PatrolShellView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SecuriaSpace.lg,
            SecuriaSpace.xl,
            SecuriaSpace.lg,
            SecuriaSpace.xl,
          ),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: PatrolColors.elevated,
                    borderRadius: BorderRadius.circular(SecuriaRadius.md + 2),
                    border: Border.all(color: PatrolColors.border),
                  ),
                  child: const Icon(
                    Icons.local_police_rounded,
                    color: PatrolColors.action,
                  ),
                ),
                const SizedBox(width: SecuriaSpace.sm),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      ShiftStrings.appName,
                      style: PatrolTypography.titleLarge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SecuriaSpace.md),
            Text(ShiftStrings.loginSubtitle, style: PatrolTypography.bodyLarge),
            const SizedBox(height: SecuriaSpace.xl),

            Text(ShiftStrings.unitLabel, style: PatrolTypography.caption),
            const SizedBox(height: SecuriaSpace.xs),
            for (final unit in _units) ...[
              _UnitOption(
                unit: unit,
                selected: unit.id == _selected.id,
                onTap: () => setState(() => _selected = unit),
              ),
              const SizedBox(height: SecuriaSpace.xs),
            ],
            const SizedBox(height: SecuriaSpace.md),

            Text(ShiftStrings.cipLabel, style: PatrolTypography.caption),
            const SizedBox(height: SecuriaSpace.xs),
            TextField(
              controller: _cip,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: PatrolTypography.mono(size: 18),
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              onSubmitted: (_) => _start(),
              decoration: InputDecoration(
                hintText: ShiftStrings.cipHint,
                hintStyle: PatrolTypography.bodyMedium.copyWith(
                  color: PatrolColors.inkMuted,
                ),
                errorText: _showError ? ShiftStrings.cipError : null,
                errorMaxLines: 2,
                prefixIcon: const Icon(
                  Icons.badge_outlined,
                  color: PatrolColors.inkMuted,
                ),
                filled: true,
                fillColor: PatrolColors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SecuriaSpace.md,
                  vertical: SecuriaSpace.md + 2,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SecuriaRadius.lg),
                  borderSide: const BorderSide(
                    color: PatrolColors.border,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SecuriaRadius.lg),
                  borderSide: const BorderSide(
                    color: PatrolColors.inkMuted,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SecuriaSpace.xl),

            PrimaryActionButton(
              label: ShiftStrings.startShift,
              icon: Icons.play_arrow_rounded,
              onPressed: _start,
            ),
          ],
        ),
      ),
    );
  }
}

/// Unidad a elegir: el código en grande y a quién pertenece
class _UnitOption extends StatelessWidget {
  final PatrolUnitModel unit;
  final bool selected;
  final VoidCallback onTap;

  const _UnitOption({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SecuriaRadius.lg);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '${unit.unitCode}, ${unit.officerName}, ${unit.location.address}',
      excludeSemantics: true,
      child: Material(
        color: selected ? PatrolColors.actionSoft : PatrolColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? PatrolColors.action : PatrolColors.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SecuriaTouch.primaryAction,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SecuriaSpace.md - 2,
                vertical: SecuriaSpace.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.unitCode,
                          style: PatrolTypography.mono(size: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${unit.officerName} · ${unit.location.address}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: PatrolTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SecuriaSpace.sm),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color:
                        selected ? PatrolColors.action : PatrolColors.inkMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
