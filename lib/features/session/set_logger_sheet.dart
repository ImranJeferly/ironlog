import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../core/utils/haptics.dart';
import '../../domain/enums.dart';
import '../../domain/session_view.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../../widgets/wheel_picker.dart';

class SetLogResult {
  const SetLogResult({
    required this.weightKg,
    required this.reps,
    this.rpe,
    this.note,
    this.delete = false,
  });

  final double weightKg;
  final int reps;
  final int? rpe;
  final String? note;
  final bool delete;
}

/// The logging sheet: two big numeral wheels, an optional emoji RPE and a note.
class SetLoggerSheet extends StatefulWidget {
  const SetLoggerSheet({
    super.key,
    required this.exercise,
    required this.unit,
    this.initialWeightKg,
    this.initialReps,
    this.initialRpe,
    this.initialNote,
    this.isEdit = false,
  });

  final SessionExerciseView exercise;
  final WeightUnit unit;
  final double? initialWeightKg;
  final int? initialReps;
  final int? initialRpe;
  final String? initialNote;
  final bool isEdit;

  static Future<SetLogResult?> show(
    BuildContext context, {
    required SessionExerciseView exercise,
    required WeightUnit unit,
    double? initialWeightKg,
    int? initialReps,
    int? initialRpe,
    String? initialNote,
    bool isEdit = false,
  }) {
    return showModalBottomSheet<SetLogResult>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => SetLoggerSheet(
        exercise: exercise,
        unit: unit,
        initialWeightKg: initialWeightKg,
        initialReps: initialReps,
        initialRpe: initialRpe,
        initialNote: initialNote,
        isEdit: isEdit,
      ),
    );
  }

  @override
  State<SetLoggerSheet> createState() => _SetLoggerSheetState();
}

class _SetLoggerSheetState extends State<SetLoggerSheet> {
  late List<double> _weights;
  late List<double> _reps;
  late int _weightIndex;
  late int _repIndex;
  int? _rpe;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;

    // Wheel steps follow the plate maths in the user's own unit.
    final step = unit == WeightUnit.kg ? 1.25 : 2.5;
    _weights = wheelValues(min: 0, max: unit.fromKg(300), step: step);
    _reps = wheelValues(min: 1, max: 50, step: 1);

    final startWeightKg =
        widget.initialWeightKg ?? widget.exercise.defaultWeightKg();
    _weightIndex = nearestIndex(_weights, unit.fromKg(startWeightKg));
    _repIndex = nearestIndex(
      _reps,
      (widget.initialReps ?? widget.exercise.defaultReps()).toDouble(),
    );
    _rpe = widget.initialRpe;
    _note = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  double get _weightKg => widget.unit.toKg(_weights[_weightIndex]);

  int get _repCount => _reps[_repIndex].round();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = widget.exercise;
    final setNo = widget.isEdit
        ? null
        : exercise.sets.length + 1;
    // RPE is what the progression and deload rules run on, so it's mandatory
    // on the set that closes out an exercise and optional elsewhere.
    final requireRpe =
        !widget.isEdit && exercise.sets.length + 1 >= exercise.targetSets;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          setNo == null
                              ? 'Edit set'
                              : 'Set $setNo of ${exercise.targetSets} · '
                                    'target ${exercise.link.repRangeMin}–'
                                    '${exercise.link.repRangeMax}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (exercise.increaseFlagged)
                    const VoltBadge('↑ WEIGHT', filled: true),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.unit.label.toUpperCase(),
                          style: theme.textTheme.labelSmall,
                        ),
                        NumberWheel(
                          values: _weights,
                          index: _weightIndex,
                          accent: AppColors.volt,
                          labelOf: (v) => v == v.roundToDouble()
                              ? v.toStringAsFixed(0)
                              : v.toStringAsFixed(2)
                                    .replaceAll(RegExp(r'0$'), ''),
                          onChanged: (i) => setState(() => _weightIndex = i),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      '×',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('REPS', style: theme.textTheme.labelSmall),
                        NumberWheel(
                          values: _reps,
                          index: _repIndex,
                          accent: AppColors.textPrimary,
                          onChanged: (i) => setState(() => _repIndex = i),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Nudge buttons for when scrolling is fiddly mid-set.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Nudge(
                    label: '−',
                    onTap: _weightIndex > 0
                        ? () => setState(() => _weightIndex--)
                        : null,
                  ),
                  _Nudge(
                    label: '+',
                    onTap: _weightIndex < _weights.length - 1
                        ? () => setState(() => _weightIndex++)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _Nudge(
                    label: '−',
                    onTap: _repIndex > 0
                        ? () => setState(() => _repIndex--)
                        : null,
                  ),
                  _Nudge(
                    label: '+',
                    onTap: _repIndex < _reps.length - 1
                        ? () => setState(() => _repIndex++)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // ---- RPE (6–10; required on an exercise's last set) ----
              Row(
                children: [
                  Text('HOW DID IT FEEL?', style: theme.textTheme.labelSmall),
                  if (requireRpe) ...[
                    const SizedBox(width: 6),
                    Text(
                      _rpe == null ? '· required on the last set' : '· ✓',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _rpe == null
                            ? AppColors.warning
                            : AppColors.volt,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final level in RpeLevel.values)
                    _RpeChip(
                      level: level,
                      selected: _rpe == level.rpe,
                      onTap: () => setState(
                        () => _rpe = _rpe == level.rpe ? null : level.rpe,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _note,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Note (optional)',
                  prefixIcon: Icon(Icons.edit_note, size: 20),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (widget.isEdit) ...[
                    IconPill(
                      icon: Icons.delete_outline,
                      size: 52,
                      color: AppColors.danger,
                      onTap: () => Navigator.of(context).pop(
                        SetLogResult(
                          weightKg: _weightKg,
                          reps: _repCount,
                          delete: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: VoltButton(
                      label: widget.isEdit
                          ? 'Save set'
                          : 'Log ${Fmt.weight(_weightKg, widget.unit)} × $_repCount',
                      icon: Icons.check_rounded,
                      onPressed: (requireRpe && _rpe == null)
                          ? null
                          : () {
                        Haptics.impact();
                        Navigator.of(context).pop(
                          SetLogResult(
                            weightKg: _weightKg,
                            reps: _repCount,
                            rpe: _rpe,
                            note: _note.text.trim().isEmpty
                                ? null
                                : _note.text.trim(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Nudge extends StatelessWidget {
  const _Nudge({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              Haptics.tick();
              onTap!();
            }
          : null,
      child: Container(
        width: 44,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _RpeChip extends StatelessWidget {
  const _RpeChip({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final RpeLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.voltDim : AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          border: Border.all(
            color: selected ? AppColors.volt : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(level.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(
              level.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.volt : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
