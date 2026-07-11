import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../cubit/trainer_signup_cubit.dart';
import '../cubit/trainer_signup_state.dart';

class TrainerSignupPage extends StatelessWidget {
  const TrainerSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrainerSignupCubit(getIt()),
      child: const _TrainerSignupView(),
    );
  }
}

class _TrainerSignupView extends StatefulWidget {
  const _TrainerSignupView();

  @override
  State<_TrainerSignupView> createState() => _TrainerSignupViewState();
}

class _TrainerSignupViewState extends State<_TrainerSignupView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _experienceController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    String initialName = '';
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      initialName = '${profileState.profile.firstName ?? ''} ${profileState.profile.lastName ?? ''}'.trim();
    }
    _nameController = TextEditingController(text: initialName);
    _experienceController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickCertificates() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && mounted) {
      context.read<TrainerSignupCubit>().addCertificates(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF131313);
    const Color surfaceColor = Color(0xFF1E1E1E);
    const Color mutedColor = Color(0xFFA3A3A3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<TrainerSignupCubit, TrainerSignupState>(
        listener: (context, state) async {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
                ),
                backgroundColor: const Color(0xFFba1a1a),
              ),
            );
          }
          if (state.isSuccess && state.token != null) {
            // updateTokens re-decodes the JWT, picks up the new staff role,
            // and emits AuthAuthenticated.
            final authCubit = context.read<AuthCubit>();
            await authCubit.updateTokens(state.token!);

            // Set the persisted role in shared pref to staff and select it
            final authState = authCubit.state;
            if (authState is AuthAuthenticated) {
              final staffRole = authState.availableRoles
                  .where((r) => r.roleEnum == Role.staff)
                  .firstOrNull;
              if (staffRole != null) {
                authCubit.selectRole(staffRole);
              }
            }

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Application submitted successfully! Workspace switched to Trainer.',
                  style: TextStyle(fontFamily: 'Inter', color: Colors.black),
                ),
                backgroundColor: Colors.white,
              ),
            );

            context.go(AppRoute.staff.path);
          }
        },
        child: BlocBuilder<TrainerSignupCubit, TrainerSignupState>(
          builder: (context, state) {
            return SafeArea(
              child: Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      children: [
                        // Header
                        Text(
                          'BECOME A TRAINER',
                          style: GoogleFonts.manrope(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submit your application and credentials to join our sanctuary of performance.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Full Name Input
                        _buildLabel('FULL NAME'),
                        TextFormField(
                          controller: _nameController,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _buildInputDecoration('e.g. Alexander Kinetic'),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Years of Experience Input
                        _buildLabel('YEARS OF EXPERIENCE'),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _buildInputDecoration('e.g. 5'),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Years of experience is required';
                            }
                            final numVal = int.tryParse(val);
                            if (numVal == null || numVal <= 0) {
                              return 'Must be a valid positive integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Bio Input
                        _buildLabel('BIO / DESCRIPTION'),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 4,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _buildInputDecoration('Tell us about your fitness philosophy...'),
                        ),
                        const SizedBox(height: 28),

                        // Specializations
                        _buildLabel('SPECIALIZATIONS'),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            'Strength',
                            'Yoga',
                            'HIIT',
                            'Cardio',
                            'CrossFit',
                            'Nutrition'
                          ].map((spec) {
                            final isSelected = state.selectedSpecializations.contains(spec);
                            return GestureDetector(
                              onTap: () => context
                                  .read<TrainerSignupCubit>()
                                  .toggleSpecialization(spec),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : surfaceColor,
                                  borderRadius: BorderRadius.zero, // 0px
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text(
                                  spec.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: isSelected ? Colors.black : mutedColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),

                        // File Upload Section
                        _buildLabel('UPLOAD CERTIFICATES & CREDENTIALS'),
                        GestureDetector(
                          onTap: _pickCertificates,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              border: Border.all(
                                color: const Color(0xFF444748),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'TAP TO UPLOAD FILES',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PDF, JPG, PNG up to 10MB',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Selected Files List
                        if (state.certificates.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...state.certificates.map((file) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: surfaceColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      file.name,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color(0xFFffb4ab),
                                      size: 18,
                                    ),
                                    onPressed: () => context
                                        .read<TrainerSignupCubit>()
                                        .removeCertificate(file),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 48),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<TrainerSignupCubit>().submit(
                                      name: _nameController.text,
                                      bio: _bioController.text,
                                      experienceYears: int.parse(_experienceController.text),
                                    );
                              }
                            },
                            child: Text(
                              'SUBMIT APPLICATION',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Loading Overlay
                  if (state.isSubmitting)
                    Container(
                      color: const Color(0xB3000000), // 0.7 opacity black
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: const Color(0xFFc4c7c8),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF737373),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.all(18),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFffb4ab), width: 1),
        borderRadius: BorderRadius.zero,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFffb4ab), width: 1),
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
