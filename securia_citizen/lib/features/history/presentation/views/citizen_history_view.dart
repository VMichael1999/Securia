import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/history_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../map/presentation/bloc/citizen_bloc.dart';
import '../../../map/presentation/bloc/citizen_state.dart';
import '../widgets/report_date.dart';
import 'incident_detail_view.dart';

/// Mis reportes: cómo terminó cada caso, que es lo que el ciudadano quiere recordar
class CitizenHistoryView extends StatelessWidget {
  const CitizenHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        centerTitle: false,
        title: Text(HistoryStrings.title, style: AppTypography.headline),
      ),
      body: BlocBuilder<CitizenBloc, CitizenState>(
        builder: (context, state) {
          if (state.isLoading) return const _SkeletonList();

          final reports = state.myReportedIncidents
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          if (reports.isEmpty) return const _EmptyReports();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SecuriaSpace.md,
              SecuriaSpace.xs,
              SecuriaSpace.md,
              SecuriaSpace.xl,
            ),
            children: [
              for (final report in reports) ...[
                _ReportCard(
                  incident: report,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IncidentDetailView(incident: report),
                    ),
                  ),
                ),
                const SizedBox(height: SecuriaSpace.sm),
              ],
              const SizedBox(height: SecuriaSpace.xs),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.inkMuted),
                  const SizedBox(width: SecuriaSpace.xs),
                  Expanded(
                    child: Text(HistoryStrings.privacy, style: AppTypography.caption),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const _ReportCard({required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = incident.status;
    final (Color outcomeColor, IconData outcomeIcon) = switch (status) {
      IncidentStatus.resuelto => (AppColors.help, Icons.check_circle_rounded),
      IncidentStatus.cancelado => (AppColors.inkMuted, Icons.block_rounded),
      // Tu alerta en curso: el único rojo de esta pantalla
      _ => (AppColors.sos, Icons.radio_button_checked_rounded),
    };

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(SecuriaRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(SecuriaRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(SecuriaSpace.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SecuriaRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceMuted,
                child: Icon(incident.type.icon, color: AppColors.incident, size: 22),
              ),
              const SizedBox(width: SecuriaSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(incident.type.title, style: AppTypography.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${formatReportDate(incident.timestamp)} · ${incident.location.address}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: SecuriaSpace.xs),
                    Row(
                      children: [
                        Icon(outcomeIcon, size: 16, color: outcomeColor),
                        const SizedBox(width: SecuriaSpace.xxs),
                        Flexible(
                          child: Text(
                            HistoryStrings.outcomeOf(incident),
                            style: AppTypography.label.copyWith(color: outcomeColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SecuriaSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(Icons.inbox_rounded, size: 32, color: AppColors.inkMuted),
            ),
            const SizedBox(height: SecuriaSpace.md),
            Text(
              HistoryStrings.emptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: SecuriaSpace.xxs),
            Text(
              HistoryStrings.emptyBody,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Esqueleto mientras cargan los reportes
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(SecuriaSpace.md),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: SecuriaSpace.sm),
      itemBuilder: (_, __) => Container(
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(SecuriaRadius.lg),
        ),
      ),
    );
  }
}
