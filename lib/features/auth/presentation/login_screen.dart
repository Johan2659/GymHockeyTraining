import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../application/auth_controller.dart';

/// Login screen for existing users
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final controller = ref.read(authControllerProvider.notifier);
      final profile = await controller.login(username);

      if (!mounted) return;

      if (profile != null) {
        // Check if onboarding is completed
        if (profile.onboardingCompleted) {
          // Go to main app
          context.go('/');
        } else {
          // Complete onboarding
          context.go('/onboarding/welcome');
        }
      } else {
        setState(() {
          _errorMessage = 'Username not found. Please create an account.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        title: Text('Login', style: AppTextStyles.subtitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.card,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xxl + 8),

                // Icon
                Icon(
                  Icons.login,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.titleL,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Login to continue your training',
                  style: AppTextStyles.body.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xxl + 8),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                SizedBox(height: AppSpacing.lg),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm + 4),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.error),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.small.copyWith(color: AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) SizedBox(height: AppSpacing.lg),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.onPrimaryColor),
                          ),
                        )
                      : Text(
                          'Login',
                          style: AppTextStyles.button.copyWith(fontSize: 18),
                        ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.small.copyWith(color: AppTheme.secondaryTextColor),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.push('/auth/signup'),
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
