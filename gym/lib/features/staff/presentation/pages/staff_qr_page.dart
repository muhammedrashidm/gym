import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/di/injection.dart';
import '../cubit/staff_qr_cubit.dart';
import '../cubit/staff_qr_state.dart';

class StaffQrPage extends StatelessWidget {
  const StaffQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffQrCubit(getIt())..generateQrToken(),
      child: const _StaffQrView(),
    );
  }
}

class _StaffQrView extends StatefulWidget {
  const _StaffQrView();

  @override
  State<_StaffQrView> createState() => _StaffQrViewState();
}

class _StaffQrViewState extends State<_StaffQrView> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  double _progress = 1.0;
  static const _totalDuration = Duration(minutes: 5);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime expiresAt) {
    _timer?.cancel();
    _updateTimer(expiresAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimer(expiresAt);
      }
    });
  }

  void _updateTimer(DateTime expiresAt) {
    final now = DateTime.now();
    final remaining = expiresAt.difference(now);
    if (remaining.isNegative) {
      setState(() {
        _timeRemaining = Duration.zero;
        _progress = 0.0;
      });
      _timer?.cancel();
    } else {
      setState(() {
        _timeRemaining = remaining;
        _progress = remaining.inSeconds / _totalDuration.inSeconds;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'SHARE QR',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<StaffQrCubit, StaffQrState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (token) => _startTimer(token.expiresAt),
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                state.when(
                  initial: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (msg) => Center(
                    child: Text(
                      msg.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  loaded: (token) {
                    final hasExpired = _timeRemaining == Duration.zero;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Large high-contrast white QR Code with sharp 1px border
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: hasExpired
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.black,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'TOKEN EXPIRED',
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : QrImageView(
                                  data: token.qrToken,
                                  version: QrVersions.auto,
                                  gapless: true,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 40),
                        // Countdown Text
                        Text(
                          hasExpired
                              ? 'TOKEN EXPIRED'
                              : 'TOKEN EXPIRES IN ${_formatDuration(_timeRemaining)}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFA3A3A3),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Thin progress bar
                        SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: const Color(0xFF2C2C2C),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(flex: 3),
                // Bottom prominent action button (0px radius)
                GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    context.read<StaffQrCubit>().generateQrToken();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text(
                        'REFRESH QR CODE',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
