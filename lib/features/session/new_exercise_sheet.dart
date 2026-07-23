import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptics.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../widgets/buttons.dart';

/// Creates a custom exercise: name, muscle, sets × rep range, done. It goes
/// into the library permanently and syncs to the account like everything else.
class NewExerciseSheet extends ConsumerStatefulWidget {
  const NewExerciseSheet({super.key});

  /// Returns the created exercise, or null if the user backed out.
  static Future<ExerciseRow?> show(BuildContext context) {
    return showModalBottomSheet<ExerciseRow>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => const NewExerciseSheet(),
    );
  }

  @override
  ConsumerState<NewExerciseSheet> createState() => _NewExerciseSheetState();
}

class _NewExerciseSheetState extends ConsumerState<NewExerciseSheet> {
  final _name = TextEditingController();
  MuscleGroup _group = MuscleGroup.chest;
  int _sets = 3;
  int _repMin = 8;
  int _repMax = 12;
  bool _bodyweight = false;
  bool _perSide = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Give the exercise a name.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final exercise = await ref
        .read(workoutRepositoryProvider)
        .createExercise(
          name: name,
          muscleGroup: _group,
          targetSets: _sets,
          repRangeMin: _repMin,
          repRangeMax: _repMax,
          isBodyweight: _bodyweight,
          isUnilateral: _perSide,
        );

    if (!mounted) return;
    Haptics.impact();
    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEW EXERCISE', style: theme.textTheme.labelSmall),
              const SizedBox(height: 6),
              Text(
                'Saved to your library forever — use it in any workout.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Exercise name',
                  prefixIcon: Icon(Icons.fitness_center, size: 20),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              Text('MUSCLE', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in MuscleGroup.values)
                    _GroupChip(
                      group: group,
                      selected: _group == group,
                      onTap: () => setState(() => _group = group),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              _StepRow(
                label: 'Sets',
                value: '$_sets',
                onMinus: _sets <= 1
                    ? null
                    : () => setState(() => _sets--),
                onPlus: _sets >= 8 ? null : () => setState(() => _sets++),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StepRow(
                label: 'Reps from',
                value: '$_repMin',
                onMinus: _repMin <= 1
                    ? null
                    : () => setState(() => _repMin--),
                onPlus: _repMin >= _repMax
                    ? null
                    : () => setState(() => _repMin++),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StepRow(
                label: 'Reps to',
                value: '$_repMax',
                onMinus: _repMax <= _repMin
                    ? null
                    : () => setState(() => _repMax--),
                onPlus: _repMax >= 30 ? null : () => setState(() => _repMax++),
              ),

              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _FlagChip(
                      label: 'Bodyweight',
                      hint: 'log added load only',
                      value: _bodyweight,
                      onTap: () =>
                          setState(() => _bodyweight = !_bodyweight),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _FlagChip(
                      label: 'Per side',
                      hint: 'left/right separately',
                      value: _perSide,
                      onTap: () => setState(() => _perSide = !_perSide),
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
              VoltButton(
                label: _busy ? 'Creating…' : 'Create exercise',
                icon: Icons.check_rounded,
                onPressed: _busy ? null : _create,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final MuscleGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.muscleColors[group.key] ?? AppColors.volt;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.2) : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: selected ? accent : AppColors.border),
        ),
        child: Text(
          group.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
        IconPill(icon: Icons.remove, size: 34, onTap: onMinus),
        SizedBox(
          width: 52,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconPill(icon: Icons.add, size: 34, onTap: onPlus),
      ],
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? AppColors.voltDim : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          border: Border.all(
            color: value ? AppColors.volt : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: value ? AppColors.volt : AppColors.textPrimary,
              ),
            ),
            Text(hint, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
