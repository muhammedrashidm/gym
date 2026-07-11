import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../cubit/add_client_cubit.dart';
import '../cubit/add_client_state.dart';

class StaffAddClientPage extends StatelessWidget {
  const StaffAddClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddClientCubit(getIt()),
      child: const _StaffAddClientView(),
    );
  }
}

class _StaffAddClientView extends StatefulWidget {
  const _StaffAddClientView();

  @override
  State<_StaffAddClientView> createState() => _StaffAddClientViewState();
}

class _StaffAddClientViewState extends State<_StaffAddClientView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _bodyFatController = TextEditingController();

  String _selectedSex = 'MALE';
  String _selectedExp = 'BEGINNER';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _muscleMassController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      // Ensure phone has '+' prefix, if not prepended and isn't empty, we default to '+91' or pre-existing logic.
      // But let's assume it should have it, or we prepend +91 if it starts with digits without +
      String formattedPhone = phone;
      if (!phone.startsWith('+')) {
        formattedPhone = '+91$phone';
      }

      context.read<AddClientCubit>().createClient(
            phoneNumber: formattedPhone,
            fullName: _nameController.text.trim(),
            age: int.tryParse(_ageController.text),
            sex: _selectedSex,
            expLevel: _selectedExp,
            weight: double.tryParse(_weightController.text),
            height: double.tryParse(_heightController.text),
            muscleMass: double.tryParse(_muscleMassController.text),
            bodyFatPct: double.tryParse(_bodyFatController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific colors matching Slate & Sinew North Star
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final inputFillColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE);
    final textColor = isDark ? Colors.white : Colors.black;
    final textMutedColor = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AddClientCubit, AddClientState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (profile) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(20),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  content: Text(
                    'ATHLETE PROFILE REGISTERED & CONNECTED',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.black : Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              );
              context.pop(true);
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFFBA1A1A),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(20),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  content: Text(
                    message.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isSubmitting = state.maybeWhen(submitting: () => true, orElse: () => false);

          return SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  // Page Title
                  Text(
                    'ADD ATHLETE',
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an unclaimed workout profile on behalf of a member. They can scan your QR code later to link accounts.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.6,
                      color: textMutedColor,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Full Name
                  _buildLabel('FULL NAME', textMutedColor),
                  TextFormField(
                    controller: _nameController,
                    enabled: !isSubmitting,
                    style: GoogleFonts.manrope(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _buildInputDecoration(
                      hint: 'e.g. ALEXANDER KINETIC',
                      fillColor: inputFillColor,
                      focusedBorderColor: borderCol,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 24),

                  // Phone Number
                  _buildLabel('PHONE NUMBER', textMutedColor),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.manrope(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _buildInputDecoration(
                      hint: 'e.g. 9876543210',
                      prefixText: '+91 ',
                      fillColor: inputFillColor,
                      focusedBorderColor: borderCol,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      final digitsOnly = val.replaceAll(RegExp(r'\D'), '');
                      if (digitsOnly.length < 8 || digitsOnly.length > 15) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Age
                  _buildLabel('AGE (YEARS)', textMutedColor),
                  TextFormField(
                    controller: _ageController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.manrope(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _buildInputDecoration(
                      hint: 'e.g. 25',
                      fillColor: inputFillColor,
                      focusedBorderColor: borderCol,
                    ),
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final parsed = int.tryParse(val);
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid age';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Sex Selection (Brutalist blocks)
                  _buildLabel('SEX', textMutedColor),
                  Row(
                    children: ['MALE', 'FEMALE', 'OTHER'].map((sexOpt) {
                      final isSelected = _selectedSex == sexOpt;
                      return Expanded(
                        child: GestureDetector(
                          onTap: isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _selectedSex = sexOpt;
                                  });
                                },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : inputFillColor,
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              sexOpt,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Experience Level Selection (Brutalist blocks)
                  _buildLabel('EXPERIENCE LEVEL', textMutedColor),
                  Row(
                    children: [
                      _ExpOption(label: 'BEGINNER', value: 'BEGINNER'),
                      _ExpOption(label: 'INTERMEDIATE', value: 'INTERMEDIATE'),
                      _ExpOption(label: 'ADVANCED/PRO', value: 'PRO'),
                    ].map((expOpt) {
                      final isSelected = _selectedExp == expOpt.value;
                      return Expanded(
                        child: GestureDetector(
                          onTap: isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _selectedExp = expOpt.value;
                                  });
                                },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : inputFillColor,
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              expOpt.label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 36),

                  // Physical stats divider heading
                  _buildSectionHeader('BODY COMPOSITION', textColor),
                  const SizedBox(height: 16),

                  // Weight & Height
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('WEIGHT (KG)', textMutedColor),
                            TextFormField(
                              controller: _weightController,
                              enabled: !isSubmitting,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.manrope(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _buildInputDecoration(
                                hint: 'e.g. 75.2',
                                fillColor: inputFillColor,
                                focusedBorderColor: borderCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('HEIGHT (CM)', textMutedColor),
                            TextFormField(
                              controller: _heightController,
                              enabled: !isSubmitting,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.manrope(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _buildInputDecoration(
                                hint: 'e.g. 178',
                                fillColor: inputFillColor,
                                focusedBorderColor: borderCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Muscle Mass & Body Fat
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('MUSCLE MASS (%)', textMutedColor),
                            TextFormField(
                              controller: _muscleMassController,
                              enabled: !isSubmitting,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.manrope(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _buildInputDecoration(
                                hint: 'e.g. 38.5',
                                fillColor: inputFillColor,
                                focusedBorderColor: borderCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('BODY FAT (%)', textMutedColor),
                            TextFormField(
                              controller: _bodyFatController,
                              enabled: !isSubmitting,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.manrope(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _buildInputDecoration(
                                hint: 'e.g. 15.0',
                                fillColor: inputFillColor,
                                focusedBorderColor: borderCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Create Athlete Button
                  GestureDetector(
                    onTap: isSubmitting ? null : _submitForm,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Center(
                        child: isSubmitting
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'CREATE ATHLETE & CONNECT',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required Color fillColor,
    required Color focusedBorderColor,
    String? prefixText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.manrope(
        color: focusedBorderColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF737373),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        borderRadius: BorderRadius.zero,
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 1),
        borderRadius: BorderRadius.zero,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        borderRadius: BorderRadius.zero,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 11,
        color: const Color(0xFFBA1A1A),
      ),
    );
  }
}

class _ExpOption {
  final String label;
  final String value;
  const _ExpOption({required this.label, required this.value});
}
