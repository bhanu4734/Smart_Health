import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';

class MobileSplashScreen extends StatefulWidget {
  const MobileSplashScreen({super.key});

  @override
  State<MobileSplashScreen> createState() => _MobileSplashScreenState();
}

class _MobileSplashScreenState extends State<MobileSplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  int _stepIndex = 0;
  final List<String> _steps = [
    'Initializing Edge Clinical Ledger...',
    'Connecting to District MySQL Cloud Sync...',
    'Verifying SciPy Linear Assignment Worker...',
    'Cluster Synchronized. Terminal Ready.',
  ];

  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the central medical shield
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacityAnimation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress bar animation (2.2 seconds total duration)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    // Cycle through startup diagnostic messages
    _stepTimer = Timer.periodic(const Duration(milliseconds: 550), (timer) {
      if (_stepIndex < _steps.length - 1) {
        if (mounted) {
          setState(() => _stepIndex++);
        }
      } else {
        timer.cancel();
      }
    });

    // Auto-navigate when initialization completes
    _progressController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final auth = AuthController();
        await auth.init();
        if (!mounted) return;
        final nextRoute = auth.isAuthenticated ? AppRoutes.dashboard : AppRoutes.welcome;
        Navigator.of(context).pushReplacementNamed(nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Sleek deep command navy
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated pulsing shield with radar aura
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulsing aura
                            Container(
                              width: 130 * _pulseScaleAnimation.value,
                              height: 130 * _pulseScaleAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2563EB).withValues(alpha: 0.15 * _pulseOpacityAnimation.value),
                                border: Border.all(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3 * _pulseOpacityAnimation.value),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Inner core icon
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.health_and_safety_rounded,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // App Title & Slogan
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AI & SciPy Resilient Supply Chain Mesh',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.65),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ECG Wave simulation visualizer
                    SizedBox(
                      height: 36,
                      width: 220,
                      child: CustomPaint(
                        painter: _EcgWavePainter(
                          progress: _progressController.value,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Linear progress bar
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: Container(
                                height: 4,
                                width: double.infinity,
                                color: Colors.white.withValues(alpha: 0.1),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: _progressController.value,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Dynamic step text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _steps[_stepIndex],
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ECG WAVEFORM PAINTER ───────────────────────────────────────────────────
class _EcgWavePainter extends CustomPainter {
  final double progress;

  _EcgWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h / 2;

    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final pulsePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, midY);
    path.lineTo(w * 0.25, midY);
    path.lineTo(w * 0.32, midY - 6);
    path.lineTo(w * 0.38, midY + 5);
    path.lineTo(w * 0.44, midY - 16);
    path.lineTo(w * 0.50, midY + 14);
    path.lineTo(w * 0.56, midY - 4);
    path.lineTo(w * 0.62, midY);
    path.lineTo(w, midY);

    canvas.drawPath(path, basePaint);

    // Animated glow segment sweeping across
    final sweepPath = Path();
    final startX = (progress * w * 1.4) - (w * 0.4);
    final endX = startX + (w * 0.35);

    final clampedStart = startX.clamp(0.0, w);
    final clampedEnd = endX.clamp(0.0, w);

    if (clampedEnd > clampedStart) {
      sweepPath.moveTo(clampedStart, midY);
      if (clampedStart <= w * 0.44 && clampedEnd >= w * 0.50) {
        sweepPath.lineTo(w * 0.44, midY - 16);
        sweepPath.lineTo(w * 0.50, midY + 14);
      }
      sweepPath.lineTo(clampedEnd, midY);
      canvas.drawPath(sweepPath, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EcgWavePainter oldDelegate) => true;
}
