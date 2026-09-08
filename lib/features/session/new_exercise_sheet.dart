import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptics.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';

/// Creates a custom exercise: name, primary (and optional secondary) muscle,
/// sets × rep range, flags. It goes into the library permanently and syncs
/// to the account like everything else.
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
  Muscle _primary = Muscle.chest;
  Muscle? _secondary;
  int _sets = 3;
  int _repMin = 8;
  int _repMax = 12;
  bool _bodyweight = false;
  bool _perSide = false;
  bool _explosive = false;
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
          primary: _primary,
          secondary: _secondary,
          targetSets: _sets,
          repRangeMin: _repMin,
          repRangeMax: _repMax,
          isBodyweight: _bodyweight,
          isUnilateral: _perSide,
          isExplosive: _explosive,
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
              Text('NEW EXERCISE', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Saved to your library forever — use it in any workout.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              const IronRule(),
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
              Text('PRIMARY MUSCLE', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in Muscle.values)
                    _MuscleChip(
                      muscle: m,
                      selected: _primary == m,
                      onTap: () => setState(() {
                        _primary = m;
                        if (_secondary == m) _secondary = null;
                      }),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              Text(
                'SECONDARY MUSCLE · counts half',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MuscleChip(
                    muscle: null,
                    selected: _secondary == null,
                    onTap: () => setState(() => _secondary = null),
                  ),
                  for (final m in Muscle.values)
                    if (m != _primary)
                      _MuscleChip(
                        muscle: m,
                        selected: _secondary == m,
                        onTap: () => setState(() => _secondary = m),
                      ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              _StepRow(
                label: 'Sets',
                value: '$_sets',
                onMinus: _sets <= 1 ? null : () => setState(() => _sets--),
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
              const SizedBox(height: AppSpacing.sm),
              _FlagChip(
                label: 'Explosive',
                hint: 'power work — not counted as hypertrophy volume, '
                    'no auto-progression',
                value: _explosive,
                onTap: () => setState(() => _explosive = !_explosive),
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

/// A muscle chip; `null` renders the "None" option for the secondary picker.
class _MuscleChip extends StatelessWidget {
  const _MuscleChip({
    required this.muscle,
    required this.selected,
    required this.onTap,
  });

  final Muscle? muscle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = muscle;
    final accent = m == null
        ? AppColors.textSecondary
        : (AppColors.muscleColors[m.group.key] ?? AppColors.volt);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.16) : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: selected ? accent : AppColors.borderStrong,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          (m?.label ?? 'None').toUpperCase(),
          style: AppText.display(
            size: 15,
            letterSpacing: 1.2,
            height: 1,
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
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
        IconPill(icon: Icons.remove, size: 34, onTap: onMinus),
        SizedBox(
          width: 52,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: AppText.numeric(size: 20, letterSpacing: 0),
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
            color: value ? AppColors.accent : AppColors.borderStrong,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color: value ? AppColors.accent : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 13,
                      color: AppColors.textPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 15,
                      color: value ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  Text(hint, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
