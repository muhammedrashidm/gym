import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../cubit/initiate_program/initiate_program_cubit.dart';
import '../cubit/initiate_program/initiate_program_state.dart';

class InitiateProgramPage extends StatelessWidget {
  final String clientId;

  const InitiateProgramPage({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InitiateProgramCubit(getIt()),
      child: InitiateProgramView(clientId: clientId),
    );
  }
}

class InitiateProgramView extends StatefulWidget {
  final String clientId;

  const InitiateProgramView({
    super.key,
    required this.clientId,
  });

  @override
  State<InitiateProgramView> createState() => _InitiateProgramViewState();
}

class _InitiateProgramViewState extends State<InitiateProgramView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: const Color(0xFF131313),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);
    final mutedColor = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'INITIATE PROGRAM',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocConsumer<InitiateProgramCubit, InitiateProgramState>(
        listener: (context, state) {
          state.mapOrNull(
            success: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('WORKOUT PROGRAM INITIATED SUCCESSFULLY'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            },
            error: (errState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errState.message.toUpperCase()),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: borderCol),
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROGRAM CONFIGURATION',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: mutedColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Program Name field
                        Text(
                          'PROGRAM NAME',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          style: GoogleFonts.manrope(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'E.G. HYPERTROPHY PHASE II',
                            hintStyle: GoogleFonts.inter(
                              color: mutedColor,
                              fontSize: 11,
                            ),
                            border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'PROGRAM NAME IS REQUIRED';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Start Date Field
                        Text(
                          'START DATE',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: isLoading ? null : () => _selectDate(context),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1),
                              border: Border.all(color: borderCol),
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd').format(_startDate),
                                  style: GoogleFonts.manrope(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.calendar_month, color: mutedColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<InitiateProgramCubit>().createProfile(
                                    clientId: widget.clientId,
                                    name: _nameController.text.trim(),
                                    startDate: DateFormat('yyyy-MM-dd').format(_startDate),
                                  );
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      color: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                              ),
                            )
                          : Text(
                              'CREATE PROGRAM PROFILE',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: cardColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
