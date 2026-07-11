import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/di/injection.dart';
import '../cubit/trainer_connection_cubit.dart';
import '../cubit/trainer_connection_state.dart';

class ClientScannerPage extends StatelessWidget {
  const ClientScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrainerConnectionCubit(getIt()),
      child: const _ClientScannerView(),
    );
  }
}

class _ClientScannerView extends StatefulWidget {
  const _ClientScannerView();

  @override
  State<_ClientScannerView> createState() => _ClientScannerViewState();
}

class _ClientScannerViewState extends State<_ClientScannerView> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasDetected = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final token = barcodes.first.rawValue;
      if (token != null && token.isNotEmpty) {
        setState(() {
          _hasDetected = true;
        });
        context.read<TrainerConnectionCubit>().connectToTrainer(token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: BlocConsumer<TrainerConnectionCubit, TrainerConnectionState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (_) {
              // Allow scanning again on error
              setState(() {
                _hasDetected = false;
              });
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isSuccess = state.maybeWhen(
            connected: (_) => true,
            orElse: () => false,
          );

          return Stack(
            children: [
              // Live camera view (or dummy indicator if camera not active)
              Positioned.fill(
                child: isSuccess
                    ? Container(color: const Color(0xFF131313))
                    : MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                        placeholderBuilder: (ctx) => Container(
                          color: const Color(0xFF131313),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
              ),

              // Semi-transparent overlay with square cutout
              if (!isSuccess)
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(),
                  ),
                ),

              // Top AppBar Overlaid
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'SCAN QR CODE',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    if (!isSuccess)
                      ValueListenableBuilder(
                        valueListenable: _scannerController,
                        builder: (context, scannerState, child) {
                          final torchEnabled = scannerState.torchState == TorchState.on;
                          return IconButton(
                            icon: Icon(
                              torchEnabled ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                            ),
                            onPressed: () => _scannerController.toggleTorch(),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Bottom Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: state.when(
                    initial: () => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ALIGN QR CODE WITHIN FRAME TO CONNECT',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFA3A3A3),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    connecting: () => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ESTABLISHING CONNECTION...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    connected: (connection) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.greenAccent,
                              size: 40,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SUCCESSFULLY CONNECTED TO TRAINER MARCUS CHEN',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => context.pop(true),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'DONE',
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
                      ],
                    ),
                    error: (message) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 32,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.redAccent,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'TRY SCANNING THE QR CODE AGAIN',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFA3A3A3),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.read<TrainerConnectionCubit>().reset();
                                  setState(() {
                                    _hasDetected = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: Text(
                                      'RETRY',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
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
            ],
          );
        },
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // Draw the full overlay
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Cutout size: square in the middle
    const double cutoutSize = 250.0;
    final double left = (size.width - cutoutSize) / 2;
    final double top = (size.height - cutoutSize) / 2;
    final cutoutRect = Rect.fromLTWH(left, top, cutoutSize, cutoutSize);

    // Path combining full screen and subtracting the cutout
    final path = Path()
      ..addRect(rect)
      ..addRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw thin white border around cutout
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(cutoutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
