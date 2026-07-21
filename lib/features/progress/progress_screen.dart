import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../photos/photos_timeline.dart';
import 'body_tab.dart';
import 'exercises_tab.dart';
import 'muscle_groups_tab.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _tab = 0;

  static const _labels = ['Exercises', 'Muscles', 'Body', 'Photos'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text('Progress', style: theme.textTheme.headlineMedium),
          ),
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _labels.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TabChip(
                  label: _labels[i],
                  active: i == _tab,
                  onTap: () => setState(() => _tab = i),
                ),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                ExercisesTab(),
                MuscleGroupsTab(),
                BodyTab(),
                PhotosTimeline(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: active ? AppColors.volt : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: active ? AppColors.volt : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.bg : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
