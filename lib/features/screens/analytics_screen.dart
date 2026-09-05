import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/app_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedView = 0; // 0: Heatmap, 1: Forecast, 2: Transfer Flow
  bool _isVectorDismissed = false;
  bool _isRerouteAuthorized = false;

  void _authorizeReroute() {
    setState(() => _isRerouteAuthorized = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Autonomous Reroute Authorized: 180 Units En Route (ETA 2.2 hrs)'),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28.0 : 16.0,
        vertical: isDesktop ? 20.0 : 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and 1 Critical Vector Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'District Analytics & Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.redBorder),
                ),
                child: const Text(
                  '1 Critical Vector',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.redText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Location line
          Row(
            children: const [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                'Warangal Operational Zone • 4 Sub-nodes Monitored',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segmented view toggle: Heatmap / Forecast / Transfer Flow
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.primaryBlueBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                _buildSegment(0, Icons.thermostat_rounded, 'Heatmap'),
                _buildSegment(1, Icons.show_chart_rounded, 'Forecast'),
                _buildSegment(2, Icons.alt_route_rounded, 'Transfer Flow'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2x2 Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  title: 'BUFFER INTEGRITY',
                  value: '91.4%',
                  badge: '+2.1%',
                  badgeColor: AppColors.greenBg,
                  badgeBorder: AppColors.greenBorder,
                  badgeTextColor: AppColors.greenText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricBox(
                  title: 'ACTIVE TRANSIT LOTS',
                  value: '14',
                  subtitle: 'In corridor',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  title: 'DEPLETION VELOCITY',
                  value: '1.8x',
                  badge: 'Surge alert',
                  badgeColor: AppColors.amberBg,
                  badgeBorder: AppColors.amberBorder,
                  badgeTextColor: AppColors.amberText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricBox(
                  title: 'PREDICTED STOCKOUTS',
                  value: '1 PHC',
                  badge: 'Immediate',
                  badgeColor: AppColors.redBg,
                  badgeBorder: AppColors.redBorder,
                  badgeTextColor: AppColors.redText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Critical Vector Focus Card (Parvathagiri PHC)
          if (!_isVectorDismissed) _buildVectorFocusCard(),

          const SizedBox(height: 14),

          // Bottom Informational Cards
          _buildInfoCard(
            icon: Icons.shield_outlined,
            title: 'Transit corridor Health',
            description:
                'All primary radial routes between Kazipet Hub and rural PHCs maintain zero temperature excursions across refrigerated fleets.',
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            icon: Icons.hub_outlined,
            title: 'Autonomous Rebalance Buffer',
            description:
                'Kazipet reserves currently sit at 3,240 units with dynamic reallocation locks reserved for Gudur and Parvathagiri zones.',
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            icon: Icons.verified_outlined,
            title: 'Audit Compliance Protocol',
            description:
                'Predictions generated via Bayesian epidemiological demand modeling. Verified against clinical dispense registers.',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSegment(int index, IconData icon, String label) {
    final isSelected = _selectedView == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedView = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    String? subtitle,
    String? badge,
    Color? badgeColor,
    Color? badgeBorder,
    Color? badgeTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: badgeBorder!),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                )
              else if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVectorFocusCard() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with dot & dismiss
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.redDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Parvathagiri PHC',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                onPressed: () => setState(() => _isVectorDismissed = true),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Critical Vector - Node ID: WRG-08',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.redText),
          ),
          const SizedBox(height: 10),

          // Predicted Stockout alert container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.redBorder, width: 0.8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.redText),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predicted Stockout in 36h',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.redText),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ORS Packets (75L equiv.) & Ciprofloxacin 500mg',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Depletion Curve Chart Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Projected Depletion Curve',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                '-82% by T+36h',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.redText),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Custom Painted Depletion Graph
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _DepletionGraphPainter(),
            ),
          ),
          const SizedBox(height: 4),

          // Timeline X labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('T-0h', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
              Text('T+12h', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
              Text('T+24h (Breach)', style: TextStyle(fontSize: 9, color: AppColors.redText, fontWeight: FontWeight.w600)),
              Text('T+48h', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 14),

          // Current lot balance & discharge run-rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'CURRENT LOT BALANCE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '42 Units Remaining',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'DISCHARGE RUN-RATE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '1.25 units/hr',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.redText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Button: Authorize Autonomous Reroute
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _isRerouteAuthorized ? null : _authorizeReroute,
              icon: Icon(
                _isRerouteAuthorized ? Icons.check_circle_outline_rounded : Icons.local_shipping_outlined,
                size: 16,
              ),
              label: Text(
                _isRerouteAuthorized ? 'Autonomous Reroute Active' : 'Authorize Autonomous Reroute',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Dispatches 180 units from Kazipet Central via NH-163 (ETA 2.2 hrs)',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DepletionGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background threshold line
    final thresholdY = h * 0.45;
    final thresholdPaint = Paint()
      ..color = AppColors.redBorder
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, Offset(0, thresholdY), Offset(w, thresholdY), thresholdPaint);

    // Threshold label text
    const textStyle = TextStyle(color: AppColors.redText, fontSize: 8, fontWeight: FontWeight.w700);
    const textSpan = TextSpan(text: 'CRITICAL BUFFER THRESHOLD', style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas, Offset(w - textPainter.width, thresholdY - 12));

    // Solid historical line (past up to now at ~45% width)
    final solidPath = Path()
      ..moveTo(0, h * 0.4)
      ..quadraticBezierTo(w * 0.2, h * 0.42, w * 0.45, h * 0.5);

    final solidPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(solidPath, solidPaint);

    // Dot at 'Now'
    final dotPaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(Offset(w * 0.45, h * 0.5), 3.5, dotPaint);

    // 'Now' label
    const nowSpan = TextSpan(text: 'Now', style: TextStyle(color: AppColors.textSecondary, fontSize: 8));
    final nowPainter = TextPainter(text: nowSpan, textDirection: TextDirection.ltr)..layout();
    nowPainter.paint(canvas, Offset(w * 0.45 - 8, h * 0.5 - 14));

    // Red dashed projected line (dropping steeply from now to end)
    final redDashPaint = Paint()
      ..color = AppColors.redText
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(w * 0.45, h * 0.5),
      Offset(w, h * 0.95),
      redDashPaint,
    );

    // Red dot on projection
    final redDotPaint = Paint()..color = AppColors.redText;
    canvas.drawCircle(Offset(w * 0.68, h * 0.68), 3.5, redDotPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = (Offset(dx, dy)).distance;
    final steps = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < steps; i++) {
      final startFrac = (i * (dashWidth + dashSpace)) / distance;
      final endFrac = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;
      canvas.drawLine(
        Offset(p1.dx + dx * startFrac, p1.dy + dy * startFrac),
        Offset(p1.dx + dx * endFrac, p1.dy + dy * endFrac),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
