import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/notifications.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/health/health_service.dart';
import '../../domain/enums.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';

/// The only setup step the plan allows: units + Apple Health permission.
class FirstRunScreen extends ConsumerStatefulWidget {
  const FirstRunScreen({super.key});

  @override
  ConsumerState<FirstRunScreen> createState() => _FirstRunScreenState();
}

class _FirstRunScreenState extends ConsumerState<FirstRunScreen> {
  WeightUnit _unit = WeightUnit.kg;
  bool _health = true;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Image(
                image: AssetImage('assets/branding/app_icon.png'),
                width: 96,
                height: 96,
              ),
              const SizedBox(height: AppSpacing.sm),
              const HazardStripes(height: 6),
              const SizedBox(height: AppSpacing.md),
              Text(
                'IronLog',
                style: theme.textTheme.displaySmall?.copyWith(fontSize: 64),
              ),
              const SizedBox(height: 6),
              Text(
                'Push · Pull · Legs. Double progression, offline first.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('WEIGHT UNIT', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              PillToggle<WeightUnit>(
                values: WeightUnit.values,
                selected: _unit,
                labelOf: (u) => u.label.toUpperCase(),
                onChanged: (u) => setState(() => _unit = u),
              ),

              const SizedBox(height: AppSpacing.lg),
              AppCard(
                onTap: () => setState(() => _health = !_health),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: _health ? AppColors.volt : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect ${HealthService.providerName}',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            HealthService.providerName == 'Health Connect'
                                ? 'Steps from Samsung Health, sleep & weight. Optional.'
                                : 'Steps, sleep and weight history. Optional.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _health,
                      onChanged: (v) => setState(() => _health = v),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              VoltButton(
                label: _busy ? 'Setting up…' : 'Start training',
                icon: Icons.arrow_forward_rounded,
                onPressed: _busy ? null : _finish,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your Push/Pull/Legs templates are already loaded.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    setState(() => _busy = true);
    final controller = ref.read(settingsProvider.notifier);

    await controller.setUnit(_unit);
    await controller.setHealthEnabled(_health);
    await Notifications.requestPermission();

    if (_health) {
      final health = ref.read(healthServiceProvider);
      final granted = await health.requestPermissions();
      if (granted) {
        // First-run backfill of weight and step history, per the plan.
        final settingsRepo = ref.read(settingsRepositoryProvider);
        if (!await settingsRepo.healthHistoryImported()) {
          await health.importHistory();
          await settingsRepo.markHealthHistoryImported();
        }
      }
    }

    await controller.completeFirstRun();
    if (mounted) setState(() => _busy = false);
  }
}
