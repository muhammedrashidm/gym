import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_manager.dart';

class OtpEntryPage extends StatefulWidget {
  final ThemeManager themeManager;
  
  const OtpEntryPage({super.key, required this.themeManager});

  @override
  State<OtpEntryPage> createState() => _OtpEntryPageState();
}

class _OtpEntryPageState extends State<OtpEntryPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  
  bool _isEmailFocused = false;
  bool _isOtpFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      setState(() => _isEmailFocused = _emailFocus.hasFocus);
    });
    _otpFocus.addListener(() {
      setState(() => _isOtpFocused = _otpFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDark = widget.themeManager.themeMode == ThemeMode.dark ||
        (widget.themeManager.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: colorScheme.onSurface),
            onPressed: () {
              widget.themeManager.toggleTheme(!isDark);
            },
            tooltip: 'Toggle Theme',
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // container-padding: 24px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40), // stack-md: 40px
              
              // Brand
              Text(
                'KINETIC',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: colorScheme.primary, // Using primary for high impact accent
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
              
              const SizedBox(height: 80), // section-gap: 80px
              
              Text(
                'Enter your sanctuary.',
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 12), // stack-sm: 12px
              
              Text(
                'Access your training dashboard with a secure one-time link.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 64), // stack-lg: 64px
              
              // Email Field (as per "one-time link" description)
              Text(
                'EMAIL ADDRESS',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: _isEmailFocused ? colorScheme.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  style: textTheme.titleMedium,
                  decoration: InputDecoration(
                    hintText: 'athlete@kinetic.com',
                    hintStyle: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // OTP Field
              Text(
                'ONE-TIME PIN',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: _isOtpFocused ? colorScheme.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextField(
                  controller: _otpController,
                  focusNode: _otpFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: textTheme.headlineMedium?.copyWith(
                    letterSpacing: 24.0, // Massive letter spacing
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    hintStyle: textTheme.headlineMedium?.copyWith(
                      letterSpacing: 24.0,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    counterText: "", // Hide the length counter
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              
              const SizedBox(height: 64), // stack-lg: 64px
              
              // Monolithic Button
              ElevatedButton(
                onPressed: () {
                  // Add verify logic
                },
                child: Text(
                  'ENTER',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Tertiary action
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'New to the temple? ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
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
                          'Request Access',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
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
  }
}
