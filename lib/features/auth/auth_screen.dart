import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/enums.dart';
import '../../widgets/brutal.dart';
import '../../widgets/buttons.dart';

/// Full-screen sign in / create account. Shown before the app itself: the user
/// authenticates, their data is pulled from Firebase, then the gate lets them
/// into the app.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _createMode = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  String? _info;

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
      _info = null;
    });

    final auth = ref.read(authServiceProvider);
    final error = _createMode
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

    // Pull the account's data down (and push anything local up) so the app
    // opens already populated. forceFullPush also resets the pull cursor.
    final sync = ref.read(syncControllerProvider.notifier);
    await sync.forceFullPush();
    await sync.sync();
    if (!mounted) return;

    final status = ref.read(syncControllerProvider);
    if (status.state == SyncState.failed) {
      // Signed in, but the first sync failed — let them in anyway (offline
      // first), and surface the reason so it can be fixed.
      setState(() {
        _busy = false;
        _info = 'Signed in. Sync will retry — ${status.message ?? 'sync failed'}';
      });
    }
    // On success the authUser stream flips the gate to the app automatically.
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = 'Enter your email above first, then tap Forgot password.';
        _info = null;
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    final error = await ref.read(authServiceProvider).sendPasswordReset(email);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      _info = error == null
          ? 'Reset link sent to $email — set a new password, then sign in.'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Poster backdrop: the neon dumbbell, dimmed, with a stencil.
          const Positioned(
            top: -40,
            right: -60,
            child: Opacity(
              opacity: 0.55,
              child: Image(
                image: AssetImage('assets/branding/app_icon.png'),
                width: 360,
                height: 360,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 140),
              const IronRule(leadWidth: 40, thickness: 3),
              const SizedBox(height: AppSpacing.md),
              Text(
                'IronLog',
                style: theme.textTheme.displaySmall?.copyWith(fontSize: 56),
              ),
              const SizedBox(height: 6),
              Text(
                _createMode
                    ? 'Create an account to keep your training synced across '
                          'devices.'
                    : 'Sign in to load your training and pick up where you '
                          'left off.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              PillToggle<bool>(
                values: const [false, true],
                selected: _createMode,
                labelOf: (v) => v ? 'CREATE ACCOUNT' : 'SIGN IN',
                onChanged: (v) {
                  if (_busy) return;
                  setState(() {
                    _createMode = v;
                    _error = null;
                    _info = null;
                  });
                },
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
              if (_info != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _info!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.volt,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
              VoltButton(
                label: _busy
                    ? 'Working…'
                    : (_createMode ? 'Create account' : 'Sign in'),
                icon: Icons.arrow_forward_rounded,
                onPressed: _busy ? null : _submit,
              ),
              if (!_createMode) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _busy ? null : _resetPassword,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        'Forgot password?',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }
}
