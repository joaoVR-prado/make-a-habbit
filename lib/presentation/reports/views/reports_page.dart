import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/presentation/reports/providers/reports_view_provider.dart';
import 'package:make_a_habbit/presentation/reports/widgets/general_report_view.dart';
import 'package:make_a_habbit/presentation/reports/widgets/habit_reports_list.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedView = ref.watch(reportsViewProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          //   child: Text(
          //     'Seu progresso',
          //     style: Theme.of(context).textTheme.titleLarge,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ReportsView>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      AppColors.positiveActionDialogTextColor,
                  selectedForegroundColor: Colors.white,
                ),
                key: const Key('reports-segmented-control'),
                segments: [
                  ButtonSegment(
                    value: ReportsView.general,
                    label: Text(
                      'Geral',
                      key: const Key('reports-general-segment'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    icon: Icon(Icons.dashboard_outlined, color: Colors.white),
                  ),
                  ButtonSegment(
                    value: ReportsView.habits,
                    label: Text(
                      'Hábitos',
                      key: const Key('reports-habits-segment'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    icon: Icon(Icons.checklist, color: Colors.white),
                  ),
                ],
                selected: {selectedView},
                onSelectionChanged: (selection) {
                  ref.read(reportsViewProvider.notifier).state =
                      selection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (selectedView) {
              ReportsView.general => const GeneralReportView(),
              ReportsView.habits => const HabitReportsList(),
            },
          ),
        ],
      ),
    );
  }
}
