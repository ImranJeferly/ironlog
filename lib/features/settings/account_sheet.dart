import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/buttons.dart';

/// Email + password sheet for creating the permanent account or signing back
/// into it. On success every local stat is pushed to the signed-in account,
/// so nothing is ever left behind on a device.
class AccountSheet extends ConsumerStatefulWidget {
  const AccountSheet({super.key, required this.createMode});

  /// True = create account (links the anonymous user, keeping its data),
  /// false = sign in to an existing account.
  final bool createMode;

  static Future<bool?> show(BuildContext context, {required bool createMode}) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => AccountSheet(createMode: createMode),
    );
  }

  @override
  ConsumerState<AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<AccountSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password needs at least 6 characters.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final auth = ref.read(authServiceProvider);
    final error = widget.createMode
        ? await auth.createAccount(email, password)
        : await auth.signIn(email, password);

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }

    // Make sure every local stat ends up under the signed-in account —
    // creating an account links the anonymous uid (data already there), and
    // signing into another account gets the full local history pushed to it.
    final sync = ref.read(syncControllerProvider.notifier);
    await sync.forceFullPush();
    await sync.sync();

    if (mounted) Navigator.of(context).pop(true);
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
              Text(
                widget.createMode ? 'CREATE ACCOUNT' : 'SIGN IN',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 6),
              Text(
                widget.createMode
                    ? 'Your stats stay yours — the account keeps them safe '
                          'across reinstalls and phones.'
                    : 'Sign back into your account to pull your stats onto '
                          'this device.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !_busy,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email, size: 20),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _password,
                obscureText: _obscure,
                enabled: !_busy,
                style: theme.textTheme.bodyLarge,
                onSubmitted: (_) => _busy ? null : _submit(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
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
                label: _busy
                    ? 'Working…'
                    : (widget.createMode ? 'Create account' : 'Sign in'),
                icon: Icons.check_rounded,
                onPressed: _busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
