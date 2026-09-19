import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedFilter = 0; // 0: Last 30 days, 1: All PHCs, 2: Active, 3: Needs action
  bool _isLoading = true;

  double _bufferIntegrity = 91.4;
  int _activeTransitLots = 14;
  double _depletionVelocity = 1.8;
  int _predictedStockouts = 1;
  List<dynamic> _transferDirectives = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsFromApi();
  }

  Future<void> _loadAnalyticsFromApi() async {
    setState(() => _isLoading = true);
    final summaryData = await ApiService.fetchDistrictSummary();
    final directivesData = await ApiService.fetchTransferDirectives();

    if (mounted) {
      setState(() {
        if (summaryData.containsKey('summary')) {
          final sum = summaryData['summary'];
          _bufferIntegrity = (sum['buffer_integrity_pct'] as num?)?.toDouble() ?? 91.4;
          _activeTransitLots = (sum['active_transit_lots'] as num?)?.toInt() ?? 14;
          _depletionVelocity = (sum['depletion_velocity_multiplier'] as num?)?.toDouble() ?? 1.8;
          _predictedStockouts = (sum['predicted_stockout_phc_count'] as num?)?.toInt() ?? 1;
        }
        _transferDirectives = directivesData;
        _isLoading = false;
      });
    }
  }

  Future<void> _runOptimizerAction() async {
    final res = await ApiService.executeOptimizer();
    final msg = res['message'] ?? 'Optimization Complete! Cold-chain directives generated.';
    await _loadAnalyticsFromApi();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          // Header: Overview Title
          Row(
            children: const [
              Icon(Icons.grid_view_rounded, size: 22, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal Filter Chips (Matches Reference Screenshot)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(0, Icons.calendar_today_rounded, 'Last 30 days'),
                const SizedBox(width: 6),
                _buildFilterChip(1, null, 'All PHCs'),
                const SizedBox(width: 6),
                _buildFilterChip(2, null, 'Active'),
                const SizedBox(width: 6),
                _buildFilterChip(3, null, 'Needs action •', isRedText: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else ...[
            // Top Highlights Cards (Available to spend & Content awaiting approval style)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlueLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Available to spend / Buffer',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_bufferIntegrity.toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Covers $_predictedStockouts of 20 critical PHC nodes',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: _runOptimizerAction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Run Optimizer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.amberBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.amberBorder),
                          ),
                          child: const Icon(Icons.description_outlined, size: 18, color: AppColors.amberText),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Directives awaiting approval',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${_transferDirectives.length < 10 ? "0" : ""}${_transferDirectives.length}',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('directives', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '⏳ ${_transferDirectives.length} pending DMO signature • $_activeTransitLots active transit lots',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Performance Section
            const Text(
              'Performance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text('Attributed revenue / Buffer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('\$18,420', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.greenBorder)),
                              child: Row(
                                children: const [
                                  Icon(Icons.arrow_upward_rounded, size: 10, color: AppColors.greenText),
                                  SizedBox(width: 2),
                                  Text('+24.1%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.greenText)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('vs \$14,850', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.show_chart_rounded, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text('Return on spend / Surge', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('${_depletionVelocity}x', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.redBorder)),
                              child: Row(
                                children: const [
                                  Icon(Icons.arrow_downward_rounded, size: 10, color: AppColors.redText),
                                  SizedBox(width: 2),
                                  Text('-0.4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.redText)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('vs 3.1x', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Attributed Revenue Sector Visualizer (Honeycomb Matrix)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Attributed Stock Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          SizedBox(height: 2),
                          Text('\$6,750 Total Regional Allocation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          children: const [
                            Text('View full report', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryBlue),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Honeycomb Hexagon Matrix Visualizer
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _HoneycombPainter(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Breakdown Legend List (Matches Screenshot)
                  _buildSectorLegendItem(Colors.blue.shade600, 'Warangal Sector Buffer', '51%', '\$3,420', isPositive: true),
                  const Divider(height: 1, color: AppColors.borderLight),
                  _buildSectorLegendItem(Colors.orange.shade400, 'Nalgonda Reserve Hub', '28%', '\$1,880', isPositive: true),
                  const Divider(height: 1, color: AppColors.borderLight),
                  _buildSectorLegendItem(Colors.green.shade600, 'Khammam Area Sector', '12%', '\$840', isPositive: false),
                  const Divider(height: 1, color: AppColors.borderLight),
                  _buildSectorLegendItem(Colors.purple.shade500, 'Mahabubnagar Critical Node', '9%', '\$610', isPositive: true),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Campaigns / Directives That Need You (Actionable Table)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campaigns that need you / Directives',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
                ),
                const SizedBox(height: 10),

                AppCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        color: AppColors.surfaceMuted,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Campaign / Directive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            Text('Waiting on you', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            Text('Live Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),

                      _buildActionTableRow(
                        avatarColor: Colors.teal,
                        avatarLetter: 'S',
                        title: 'Stir in strength / Parvathagiri',
                        subtitle: '• Active • day 41',
                        waitingChip: '22 creators / units',
                        waitingDetail: '4 waiting over 5 days',
                        statNumber: '49',
                        statDetail: '12 this week',
                      ),
                      const Divider(height: 1, color: AppColors.borderLight),
                      _buildActionTableRow(
                        avatarColor: Colors.redAccent,
                        avatarLetter: 'H',
                        title: 'Healthier every day / Gudur',
                        subtitle: '• Active • day 189',
                        waitingChip: '4 creators / units',
                        waitingDetail: 'all within 48h target',
                        statNumber: '10',
                        statDetail: '2 this week',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, IconData? icon, String label, {bool isRedText = false}) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.borderCard : AppColors.borderSubtle,
            width: isSelected ? 1.2 : 1.0,
          ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isRedText
                    ? AppColors.redText
                    : (isSelected ? AppColors.textPrimary : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorLegendItem(Color dotColor, String title, String percentage, String amount, {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(4)),
                  child: Text(percentage, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: isPositive ? AppColors.greenText : AppColors.redText),
              const SizedBox(width: 2),
              Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isPositive ? AppColors.textPrimary : AppColors.redText)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTableRow({
    required Color avatarColor,
    required String avatarLetter,
    required String title,
    required String subtitle,
    required String waitingChip,
    required String waitingDetail,
    required String statNumber,
    required String statDetail,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(avatarLetter, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.greenDot, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.borderSubtle)),
                child: Text(waitingChip, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 2),
              Text(waitingDetail, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(statNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text(statDetail, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Honeycomb Hexagon Matrix
class _HoneycombPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w * 0.5;
    final centerY = h * 0.5;

    final paintBlue = Paint()..color = Colors.blue.shade600..style = PaintingStyle.fill;
    final paintOrange = Paint()..color = Colors.orange.shade400..style = PaintingStyle.fill;
    final paintGreen = Paint()..color = Colors.green.shade600..style = PaintingStyle.fill;
    final paintPurple = Paint()..color = Colors.purple.shade500..style = PaintingStyle.fill;
    final paintLight = Paint()..color = Color(0xFFF3F4F6)..style = PaintingStyle.fill;

    // Draw honeycomb hexagonal grid points
    const rows = 6;
    const cols = 14;
    const radius = 7.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = centerX + (c - cols / 2) * 16.0 + (r % 2 == 0 ? 0 : 8.0);
        final y = centerY + (r - rows / 2) * 16.0;

        Paint p = paintLight;
        final dist = ((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));

        if (dist < 1200) {
          p = paintPurple;
        } else if (dist < 2800) {
          p = (c % 2 == 0) ? paintGreen : paintOrange;
        } else if (dist < 5500) {
          p = paintBlue;
        }

        canvas.drawCircle(Offset(x, y), radius, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
