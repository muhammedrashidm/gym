import 'package:flutter/material.dart';

/// TEMPORARY: surfaces the OTP that the server echoes back in the
/// `request-otp` response while SMS delivery is unavailable. Delete this
/// together with `AuthOtpSent.debugCode` once the SMS provider is live.
void showOtpCodeSnackBar(BuildContext context, String code) {
  final colorScheme = Theme.of(context).colorScheme;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Code: $code  ·  SMS not enabled yet'),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
}
