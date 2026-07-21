import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../globals.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;

  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  bool _isOtpFocused = false;

  ThemeManager get _themeManager => themeManager;

  @override
  void initState() {
    super.initState();
    _otpFocus.addListener(() {
      setState(() => _isOtpFocused = _otpFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
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
          if (state is AuthAuthenticated) {
            // GoRouter's refreshListenable automatically redirects to the correct route
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
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
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
                      'Verify your code.',
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the 4-digit code sent to\n${widget.phoneNumber}',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 64),

                    // OTP Label
                    Text(
                      'ONE-TIME PIN',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      identifier: 'auth_otp_code_field',
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          border: Border.all(
                            color: _isOtpFocused
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
                          controller: _otpController,
                          focusNode: _otpFocus,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: textTheme.headlineMedium?.copyWith(
                            letterSpacing: 24.0,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••',
                            hintStyle: textTheme.headlineMedium?.copyWith(
                              letterSpacing: 24.0,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),

                    Semantics(
                      identifier: 'auth_otp_verify_button',
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final otp = _otpController.text.trim();
                                if (otp.isEmpty) return;
                                context.read<AuthCubit>().verifyOtp(
                                      phoneNumber: widget.phoneNumber,
                                      otp: otp,
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
                                'ENTER',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Resend action
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Didn't receive a code? ",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Semantics(
                            identifier: 'auth_otp_resend_button',
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<AuthCubit>().sendOtp(
                                            phoneNumber: widget.phoneNumber,
                                          );
                                    },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: colorScheme.primary,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Resend',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
