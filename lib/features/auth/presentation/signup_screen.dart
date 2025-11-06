import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../application/auth_controller.dart';

/// Sign up screen for new users
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.trim().length < 3) return;

    setState(() => _isCheckingUsername = true);

    final controller = ref.read(authControllerProvider.notifier);
    final exists = await controller.usernameExists(username.trim());

    if (!mounted) return;

    setState(() {
      _isCheckingUsername = false;
      if (exists) {
        _errorMessage = 'Username already taken';
      } else {
        _errorMessage = null;
      }
    });
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_errorMessage != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final controller = ref.read(authControllerProvider.notifier);
      final profile = await controller.signUp(username);

      if (!mounted) return;

      if (profile != null) {
        // Go to onboarding to set role and goal
        context.go('/onboarding/welcome');
      } else {
        setState(() {
          _errorMessage = 'Sign up failed. Username may already exist.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Sign up failed. Please try again.';
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
        title: Text('Create Account', style: AppTextStyles.subtitle),
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
                  Icons.person_add,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  'What is your username?',
                  style: AppTextStyles.titleL.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose a unique username to get started',
                  style: AppTextStyles.body.copyWith(
                        color: Colors.grey[400],
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xxl + 8),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Choose a unique username',
                    prefixIcon: const Icon(Icons.person),
                    suffixIcon: _isCheckingUsername
                        ? Padding(
                            padding: EdgeInsets.all(AppSpacing.sm + 4),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _errorMessage == null &&
                                _usernameController.text.trim().length >= 3
                            ? Icon(Icons.check_circle,
                                color: AppTheme.success)
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm + 4),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    errorText: _errorMessage,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignUp(),
                  onChanged: (value) {
                    // Debounce username check
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_usernameController.text.trim() == value.trim()) {
                        _checkUsernameAvailability(value);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (value.trim().length > 20) {
                      return 'Username must be less than 20 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                SizedBox(height: AppSpacing.xl),

                // Sign up button
                ElevatedButton(
                  onPressed: _isLoading || _isCheckingUsername
                      ? null
                      : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
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
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: AppTextStyles.button.copyWith(fontSize: 18),
                        ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.small.copyWith(color: Colors.grey[400]),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.push('/auth/login'),
                      child: Text(
                        'Login',
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
