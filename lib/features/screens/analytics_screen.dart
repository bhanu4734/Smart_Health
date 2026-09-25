import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../services/api_service.dart';
import '../analytics/widgets/phc_globe_viewer.dart';
import '../analytics/widgets/phc_globe_modal.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedFilter = 0; // 0: Last 30 days, 1: All PHCs, 2: Normal Stock, 3: At Risk
  String _dateRangeText = 'Last 30 days';
  bool _isLoading = true;

  double _bufferIntegrity = 91.4;
  int _activeTransitLots = 14;
  double _depletionVelocity = 1.8;
  int _predictedStockouts = 1;
  List<dynamic> _transferDirectives = [];

  double get effectiveBufferIntegrity {
    if (_selectedFilter == 2) return 98.6;
    if (_selectedFilter == 3) return 42.5;
    return _bufferIntegrity;
  }

  int get effectiveStockoutCount {
    if (_selectedFilter == 2) return 0;
    if (_selectedFilter == 3) return 1;
    return _predictedStockouts;
  }

  String get effectiveDepletionVel {
    if (_selectedFilter == 2) return '1.1×';
    if (_selectedFilter == 3) return '3.4×';
    return '${_depletionVelocity.toStringAsFixed(1)}×';
  }

  String get effectiveDepletionTrend {
    if (_selectedFilter == 2) return '-0.4×';
    if (_selectedFilter == 3) return '+1.6×';
    return '+0.3×';
  }

  bool get effectiveDepletionIsPositive {
    if (_selectedFilter == 2) return true;
    return false;
  }

  int get effectiveActiveTransitLots {
    if (_selectedFilter == 2) return 8;
    if (_selectedFilter == 3) return 6;
    return _activeTransitLots;
  }

  String get effectiveMonitoredNodesCount {
    if (_selectedFilter == 2) return '23';
    if (_selectedFilter == 3) return '1';
    return '24';
  }

  String get effectiveMonitoredNodesSub {
    if (_selectedFilter == 2) return 'healthy stock nodes';
    if (_selectedFilter == 3) return 'breaching safety limit';
    return 'all nodes synced';
  }

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

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Analysis Timeframe', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
        children: [
          'Last 7 days',
          'Last 14 days',
          'Last 30 days',
          'Last 90 days',
          'Year to Date',
        ].map((range) {
          final isSelected = _dateRangeText == range;
          return SimpleDialogOption(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _dateRangeText = range;
                _selectedFilter = 0;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    range,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF2563EB) : AppColors.textPrimary,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_rounded, size: 16, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32.0 : 16.0,
        vertical: isDesktop ? 24.0 : 14.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Row: Overview Title ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 22, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFilter == 2
                            ? 'District Logistics Overview (Normal Stock)'
                            : (_selectedFilter == 3
                                ? 'District Logistics Overview (At Risk)'
                                : 'District Logistics Overview'),
                        style: TextStyle(
                          fontSize: isDesktop ? 22 : 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedFilter != 0) ...[
                const SizedBox(width: 6),
                TextButton.icon(
                  onPressed: () => setState(() => _selectedFilter = 0),
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Reset', style: TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Horizontal Filter Chips ──────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  0,
                  Icons.calendar_today_outlined,
                  _dateRangeText,
                  onTapCustom: _showDateRangePicker,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(1, null, '🏢 All PHCs'),
                const SizedBox(width: 6),
                _buildFilterChip(2, null, '🟢 Normal Stock'),
                const SizedBox(width: 6),
                _buildFilterChip(3, null, '🔴 At Risk', hasRedDot: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else ...[
            // ── Top Row: 2 Highlight Cards (Buffer Stock Integrity & Pending Transfer Directives)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBufferIntegrityCard()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildAwaitingApprovalCard()),
                ],
              )
            else ...[
              _buildBufferIntegrityCard(),
              const SizedBox(height: 12),
              _buildAwaitingApprovalCard(),
            ],
            const SizedBox(height: 24),

            // ── Performance Section Header ─────────────────────────────────
            const Text(
              'District Logistics Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),

            // ── 3 Metric Cards Row (Depletion Velocity, Active Transit Lots, Monitored Nodes)
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceMetricCard(
                      icon: Icons.speed_rounded,
                      label: 'Depletion Velocity',
                      value: effectiveDepletionVel,
                      trendText: effectiveDepletionTrend,
                      isPositive: effectiveDepletionIsPositive,
                      comparisonText: 'vs 1.5× baseline',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPerformanceMetricCard(
                      icon: Icons.local_shipping_outlined,
                      label: 'Active Transit Lots',
                      value: '$effectiveActiveTransitLots',
                      trendText: _selectedFilter == 3 ? '+6' : '+4',
                      isPositive: true,
                      comparisonText: _selectedFilter == 3 ? 'urgent corridors' : 'vs 10 last week',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPerformanceMetricCard(
                      icon: Icons.hub_outlined,
                      label: 'Monitored PHC Nodes',
                      value: effectiveMonitoredNodesCount,
                      trendText: _selectedFilter == 3 ? '4.2%' : (_selectedFilter == 2 ? '95.8%' : '100%'),
                      isPositive: _selectedFilter != 3,
                      comparisonText: effectiveMonitoredNodesSub,
                    ),
                  ),
                ],
              )
            else ...[
              _buildPerformanceMetricCard(
                icon: Icons.speed_rounded,
                label: 'Depletion Velocity',
                value: effectiveDepletionVel,
                trendText: effectiveDepletionTrend,
                isPositive: effectiveDepletionIsPositive,
                comparisonText: 'vs 1.5× baseline',
              ),
              const SizedBox(height: 10),
              _buildPerformanceMetricCard(
                icon: Icons.local_shipping_outlined,
                label: 'Active Transit Lots',
                value: '$effectiveActiveTransitLots',
                trendText: _selectedFilter == 3 ? '+6' : '+4',
                isPositive: true,
                comparisonText: _selectedFilter == 3 ? 'urgent corridors' : 'vs 10 last week',
              ),
              const SizedBox(height: 10),
              _buildPerformanceMetricCard(
                icon: Icons.hub_outlined,
                label: 'Monitored PHC Nodes',
                value: effectiveMonitoredNodesCount,
                trendText: _selectedFilter == 3 ? '4.2%' : (_selectedFilter == 2 ? '95.8%' : '100%'),
                isPositive: _selectedFilter != 3,
                comparisonText: effectiveMonitoredNodesSub,
              ),
            ],
            const SizedBox(height: 20),

            // ── 3D Interactive Global PHC Network Mesh Showcase ─────────────
            _build3DGlobeMeshCard(context, isDesktop),
            const SizedBox(height: 24),

            // ── Charts Row (Stock Allocation Honeycomb Mesh + Dispensing Velocity Bar Chart)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildStockAllocationCard()),
                  const SizedBox(width: 14),
                  Expanded(flex: 4, child: _buildDispensingVelocityCard()),
                ],
              )
            else ...[
              _buildStockAllocationCard(),
              const SizedBox(height: 14),
              _buildDispensingVelocityCard(),
            ],
            const SizedBox(height: 24),

            // ── Directives & Critical Interventions (Table Section) ─────────
            _buildDirectivesTable(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── FILTER CHIP ─────────────────────────────────────────────────────────
  Widget _buildFilterChip(int index, IconData? icon, String label, {bool hasRedDot = false, VoidCallback? onTapCustom}) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: onTapCustom ?? () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.borderCard : Colors.transparent,
            width: 1.0,
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
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                letterSpacing: -0.1,
              ),
            ),
            if (hasRedDot) ...[
              const SizedBox(width: 5),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.redDot,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── BUFFER INTEGRITY CARD ────────────────────────────────────────────────
  Widget _buildBufferIntegrityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Buffer Stock Integrity',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${effectiveBufferIntegrity.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _selectedFilter == 3 ? AppColors.redText : AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: _selectedFilter == 3 ? AppColors.redText : AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$effectiveStockoutCount PHC node${effectiveStockoutCount == 1 ? '' : 's'} at stockout risk',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _selectedFilter == 3 ? FontWeight.w700 : FontWeight.w400,
                              color: _selectedFilter == 3 ? AppColors.redText : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: _runOptimizerAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Run Optimizer', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CONTENT AWAITING APPROVAL CARD ───────────────────────────────────────
  Widget _buildAwaitingApprovalCard() {
    final count = _transferDirectives.length;
    final countStr = count < 10 ? '0$count' : '$count';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.swap_horiz_rounded, size: 18, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Pending Transfer Directives',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                countStr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'directives',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '$effectiveActiveTransitLots active transit lots across district',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PERFORMANCE METRIC CARD ──────────────────────────────────────────────
  Widget _buildPerformanceMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String trendText,
    required bool isPositive,
    required String comparisonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.greenBg : AppColors.redBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: isPositive ? AppColors.greenBorder : AppColors.redBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 10,
                      color: isPositive ? AppColors.greenText : AppColors.redText,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trendText,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isPositive ? AppColors.greenText : AppColors.redText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comparisonText,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STOCK ALLOCATION WITH HONEYCOMB ──────────────────────────────────────
  Widget _buildStockAllocationCard() {
    String meshTitle = 'District Stock Allocation Mesh';
    if (_selectedFilter == 2) meshTitle = '🟢 Normal Stock Allocation Mesh (23 Healthy PHCs)';
    if (_selectedFilter == 3) meshTitle = '🔴 At Risk Stock Vector Mesh (Parvathagiri & Gudur PHC)';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meshTitle,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: const [
                    Text(
                      'View full report',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textPrimary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${effectiveBufferIntegrity.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _selectedFilter == 3 ? AppColors.redText : AppColors.textPrimary,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 16),

          // Honeycomb Map Canvas
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(painter: _HoneycombPainter(selectedFilter: _selectedFilter)),
          ),
          const SizedBox(height: 16),

          // Sector Legend list
          if (_selectedFilter == 3) ...[
            _buildSectorLegendItem(const Color(0xFFDC2626), 'Parvathagiri PHC (Warangal)', 'Critical Deficit', '42 units (36h cover)', isPositive: false),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFFF97316), 'PHC Gudur (Nalgonda)', 'Zero Stock Imminent', '0 vials (Anti-Rabies)', isPositive: false),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFFD97706), 'PHC Rampur', 'Buffer Low', '600 packs ORS', isPositive: false),
          ] else if (_selectedFilter == 2) ...[
            _buildSectorLegendItem(const Color(0xFF059669), 'Warangal Central Hub', '48%', '2,310 units', isPositive: true),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFF10B981), 'Nalgonda Rural PHC', '26%', '1,250 units', isPositive: true),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFF047857), 'Khammam Tribal PHC', '16%', '770 units', isPositive: true),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFF34D399), 'Mahabubnagar Buffer', '10%', '490 units', isPositive: true),
          ] else ...[
            _buildSectorLegendItem(const Color(0xFF2563EB), 'Warangal Central Hub', '48%', '2,310 units', isPositive: true),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFFF97316), 'Nalgonda Rural PHC', '26%', '1,250 units', isPositive: true),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFF059669), 'Khammam Tribal PHC', '16%', '770 units', isPositive: false),
            const Divider(height: 1, color: AppColors.borderLight),
            _buildSectorLegendItem(const Color(0xFF8B5CF6), 'Mahabubnagar Buffer', '10%', '490 units', isPositive: true),
          ],
        ],
      ),
    );
  }

  // ── DISPENSING VELOCITY OVER TIME BAR CHART ──────────────────────────────
  Widget _buildDispensingVelocityCard() {
    String totalVolume = '1,420 units';
    String avgPerDay = '236 units avg/day';
    List<String> axisLabels = const ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

    if (_dateRangeText == 'Last 7 days') {
      totalVolume = '385 units';
      avgPerDay = '55 units avg/day';
      axisLabels = const ['Mon', 'Wed', 'Fri', 'Sun'];
    } else if (_dateRangeText == 'Last 14 days') {
      totalVolume = '740 units';
      avgPerDay = '53 units avg/day';
      axisLabels = const ['Day 1', 'Day 5', 'Day 10', 'Day 14'];
    } else if (_dateRangeText == 'Last 90 days') {
      totalVolume = '4,180 units';
      avgPerDay = '46 units avg/day';
      axisLabels = const ['Month 1', 'Month 2', 'Month 3', 'Current'];
    } else if (_dateRangeText == 'Year to Date') {
      totalVolume = '18,240 units';
      avgPerDay = '76 units avg/day';
      axisLabels = const ['Q1', 'Q2', 'Q3', 'Q4'];
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Dispensing Velocity',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  _dateRangeText,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalVolume,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                avgPerDay,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bar Chart simulation
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _VelocityBarChartPainter(
                selectedFilter: _selectedFilter,
                dateRange: _dateRangeText,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: axisLabels.map((lbl) => Text(lbl, style: const TextStyle(fontSize: 10, color: AppColors.textMuted))).toList(),
          ),
        ],
      ),
    );
  }

  // ── DIRECTIVES & CRITICAL INTERVENTIONS TABLE ─────────────────────────────
  Widget _buildDirectivesTable() {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    // Filter directives based on _selectedFilter
    List<dynamic> filteredDirectives = _transferDirectives;
    if (_selectedFilter == 2) {
      filteredDirectives = _transferDirectives.where((d) {
        final s = (d['status'] ?? '').toString().toLowerCase();
        return s == 'approved' || s == 'en route' || s == 'in transit';
      }).toList();
    } else if (_selectedFilter == 3) {
      filteredDirectives = _transferDirectives.where((d) {
        final s = (d['status'] ?? '').toString().toLowerCase();
        return s != 'approved' && s != 'en route';
      }).toList();
    }

    String filterBadge = '';
    Color filterColor = AppColors.textSecondary;
    if (_selectedFilter == 1) {
      filterBadge = 'Filter: All PHCs';
    } else if (_selectedFilter == 2) {
      filterBadge = 'Filter: Normal Stock (Approved Directives)';
      filterColor = const Color(0xFF059669);
    } else if (_selectedFilter == 3) {
      filterBadge = 'Filter: At Risk (Critical Stockout Imminent)';
      filterColor = AppColors.redText;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Directives & Critical Interventions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
            ),
            if (filterBadge.isNotEmpty)
              InkWell(
                onTap: () => setState(() => _selectedFilter = 0),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _selectedFilter == 3 ? AppColors.redBg : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: _selectedFilter == 3 ? AppColors.redBorder : AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filterBadge,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: filterColor),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.close_rounded, size: 12, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: isDesktop ? 600 : 450),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: AppColors.surfaceMuted,
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text('PHC Directive Route', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Allocation & Buffer', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Dispatch Status', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),

                  // Rows
                  if (filteredDirectives.isNotEmpty)
                    ...filteredDirectives.take(4).map((item) {
                      final fromName = (item['source_phc_name'] ?? item['source_phc_id'] ?? 'Central Hub').toString().replaceAll('\n', ' ');
                      final toName = (item['target_phc_name'] ?? item['target_phc_id'] ?? 'Target PHC').toString().replaceAll('\n', ' ');
                      final medName = item['medicine_name'] ?? item['medicine_id'] ?? 'Essential Medicine';
                      final qty = item['quantity'] ?? 500;
                      final status = (item['status'] ?? 'Pending').toString();
                      final isApproved = status.toLowerCase() == 'approved';

                      return Column(
                        children: [
                          _buildDirectiveRow(
                            avatarColor: isApproved ? const Color(0xFF059669) : const Color(0xFF2563EB),
                            avatarLetter: medName.isNotEmpty ? medName[0].toUpperCase() : 'M',
                            title: '$fromName ➔ $toName',
                            subtitle: '$medName • SciPy Linear Assignment',
                            allocationBadge: '$qty units',
                            allocationSubtext: 'Cold-chain compliant',
                            statMain: isApproved ? 'Approved' : 'Pending',
                            statSubtext: isApproved ? 'En route' : 'Awaiting DMO',
                          ),
                          const Divider(height: 1, color: AppColors.borderLight),
                        ],
                      );
                    })
                  else ...[
                    // Default realistic clinical directives filtered appropriately
                    if (_selectedFilter != 2) ...[
                      _buildDirectiveRow(
                        avatarColor: const Color(0xFF0D9488),
                        avatarLetter: 'A',
                        title: 'Warangal Depot ➔ Nalgonda Rural',
                        subtitle: 'Anti-Rabies Serum • Expiry Risk 6h Window',
                        allocationBadge: '45 vials',
                        allocationSubtext: 'Cold-Box #B2 verified',
                        statMain: 'Pending',
                        statSubtext: 'Zero-Stock Imminent',
                      ),
                      const Divider(height: 1, color: AppColors.borderLight),
                    ],
                    if (_selectedFilter != 3) ...[
                      _buildDirectiveRow(
                        avatarColor: const Color(0xFF2563EB),
                        avatarLetter: 'O',
                        title: 'Central Depot ➔ PHC Rampur',
                        subtitle: 'ORS Sachets • Preemptive Heatwave Stocking',
                        allocationBadge: '600 packs',
                        allocationSubtext: 'Non-Refrigerated Transit',
                        statMain: 'Approved',
                        statSubtext: 'En route via NH-363',
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectiveRow({
    required Color avatarColor,
    required String avatarLetter,
    required String title,
    required String subtitle,
    required String allocationBadge,
    required String allocationSubtext,
    required String statMain,
    required String statSubtext,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Route column
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: AppColors.greenDot, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Allocation column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    allocationBadge,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  allocationSubtext,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // Dispatch status column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statMain,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  statSubtext,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorLegendItem(Color dotColor, String title, String percentage, String amount, {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(percentage, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: isPositive ? AppColors.greenText : AppColors.redText,
              ),
              const SizedBox(width: 3),
              Text(
                amount,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── OPENSTREETMAP GIS SHOWCASE CARD ──────────────────────────────────────
  Widget _build3DGlobeMeshCard(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 22 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: const Icon(Icons.map_rounded, size: 20, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                const Text(
                                  'GLOBAL PHC GIS NETWORK',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Text(
                                    'OPENSTREETMAP TELEMETRY',
                                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Live Geodesic Telemetry (24.54° N, 77.65° E) • Telangana PHC Cluster & Arcs',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => PhcGlobeModal.show(context),
                  icon: const Icon(Icons.fullscreen_rounded, size: 16),
                  label: const Text('Launch Fullscreen GIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: const Icon(Icons.map_rounded, size: 18, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              const Text(
                                'GLOBAL PHC GIS NETWORK',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Text(
                                  'OPENSTREETMAP',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Live Geodesic Telemetry • Telangana PHC Cluster',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => PhcGlobeModal.show(context),
                    icon: const Icon(Icons.fullscreen_rounded, size: 16),
                    label: const Text('Launch Fullscreen GIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Container(
            height: isDesktop ? 380 : 300,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const PhcGlobeViewer(
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}

// ── HONEYCOMB CUSTOM PAINTER ────────────────────────────────────────────────
class _HoneycombPainter extends CustomPainter {
  final int selectedFilter;

  _HoneycombPainter({this.selectedFilter = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w * 0.5;
    final centerY = h * 0.5;

    final paintBlue = Paint()..color = const Color(0xFF2563EB)..style = PaintingStyle.fill;
    final paintOrange = Paint()..color = const Color(0xFFF97316)..style = PaintingStyle.fill;
    final paintGreen = Paint()..color = const Color(0xFF059669)..style = PaintingStyle.fill;
    final paintRed = Paint()..color = const Color(0xFFDC2626)..style = PaintingStyle.fill;
    final paintPurple = Paint()..color = const Color(0xFF8B5CF6)..style = PaintingStyle.fill;
    final paintLight = Paint()..color = const Color(0xFFF3F4F6)..style = PaintingStyle.fill;

    const rows = 7;
    const cols = 15;
    const radius = 6.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = centerX + (c - cols / 2) * 15.0 + (r % 2 == 0 ? 0 : 7.5);
        final y = centerY + (r - rows / 2) * 15.0;

        Paint p = paintLight;
        final dist = ((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));

        if (selectedFilter == 3) {
          // At Risk filter: Highlight danger vectors with Red and Orange
          if (dist < 1200) {
            p = paintRed;
          } else if (dist < 3500) {
            p = (c % 2 == 0) ? paintOrange : paintRed;
          } else {
            p = paintLight;
          }
        } else if (selectedFilter == 2) {
          // Normal Stock filter: Highlight healthy nodes with Emerald Green
          if (dist < 1500) {
            p = paintGreen;
          } else if (dist < 4500) {
            p = (c % 3 == 0) ? paintGreen : Paint()..color = const Color(0xFF10B981);
          } else {
            p = paintLight;
          }
        } else {
          // All PHCs / Default
          if (dist < 800) {
            p = paintPurple;
          } else if (dist < 2200) {
            p = (c % 2 == 0) ? paintGreen : paintOrange;
          } else if (dist < 5000) {
            p = paintBlue;
          }
        }

        canvas.drawCircle(Offset(x, y), radius, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HoneycombPainter oldDelegate) => oldDelegate.selectedFilter != selectedFilter;
}

// ── VELOCITY BAR CHART PAINTER ───────────────────────────────────────────────
class _VelocityBarChartPainter extends CustomPainter {
  final int selectedFilter;
  final String dateRange;

  _VelocityBarChartPainter({this.selectedFilter = 0, this.dateRange = 'Last 30 days'});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    // Draw horizontal dashed grid lines
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = h * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Bar colors based on filter
    Color baseBarColor = const Color(0xFFE2E8F0);
    Color activeBarColor = const Color(0xFF2563EB);

    if (selectedFilter == 3) {
      baseBarColor = const Color(0xFFFEE2E2);
      activeBarColor = const Color(0xFFDC2626);
    } else if (selectedFilter == 2) {
      baseBarColor = const Color(0xFFD1FAE5);
      activeBarColor = const Color(0xFF059669);
    }

    final barPaint = Paint()
      ..color = baseBarColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = activeBarColor
      ..style = PaintingStyle.fill;

    const barCols = 24;
    final barWidth = (w - (barCols * 3.0)) / barCols;

    for (int i = 0; i < barCols; i++) {
      final x = i * (barWidth + 3.0);
      final seed = (i * 7 + (selectedFilter * 5) + dateRange.length) % 13;
      final heightRatio = 0.2 + (0.75 * seed / 13.0);
      final barHeight = h * heightRatio;
      final y = h - barHeight;

      final p = (i > 14) ? highlightPaint : barPaint;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(rrect, p);
    }
  }

  @override
  bool shouldRepaint(covariant _VelocityBarChartPainter oldDelegate) =>
      oldDelegate.selectedFilter != selectedFilter || oldDelegate.dateRange != dateRange;
}
