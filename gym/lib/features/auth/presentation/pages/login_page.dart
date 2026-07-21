import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../globals.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  bool _isPhoneFocused = false;

  // Access global theme manager
  ThemeManager get _themeManager => themeManager;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      setState(() => _isPhoneFocused = _phoneFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDark = _themeManager.themeMode == ThemeMode.dark ||
        (_themeManager.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            context.push(
              AppRoute.otp.path,
              extra: state.phoneNumber,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () => _themeManager.toggleTheme(!isDark),
                  tooltip: 'Toggle Theme',
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Brand
                    Text(
                      'KINETIC',
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Peak Performance Management',
                      style: textTheme.labelSmall?.copyWith(
                        letterSpacing: 2.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 80),

                    Text(
                      'Enter your sanctuary.',
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Receive a one-time code to your phone number.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 64),

                    // Phone Field
                    Text(
                      'PHONE NUMBER',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      identifier: 'auth_login_phone_field',
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          border: Border.all(
                            color: _isPhoneFocused
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+]'),
                            ),
                          ],
                          style: textTheme.titleMedium,
                          decoration: InputDecoration(
                            hintText: '+1234567890',
                            hintStyle: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Send OTP Button
                    Semantics(
                      identifier: 'auth_login_send_code_button',
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final phone = _phoneController.text.trim();
                                if (phone.isEmpty) return;
                                context.read<AuthCubit>().sendOtp(
                                      phoneNumber: phone,
                                    );
                              },
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                'SEND CODE',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
