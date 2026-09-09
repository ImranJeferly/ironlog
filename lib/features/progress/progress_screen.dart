import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/brutal.dart';
import '../photos/photos_screen.dart';
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

  // Photos belong with the other "how is my body changing" views, and folding
  // them in here gets the bottom bar down from six tabs to five.
  static const _labels = ['Exercises', 'Muscles', 'Body', 'Photos'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrutalHeader(
            title: 'Progress',
            eyebrow: 'Numbers don’t lie',
            rule: false,
          ),
          SizedBox(
            height: 40,
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
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: IronRule(),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                ExercisesTab(),
                MuscleGroupsTab(),
                BodyTab(),
                PhotosScreen(embedded: true),
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
          color: active ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: AppText.display(
            size: 17,
            letterSpacing: 1.4,
            height: 1,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
