import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/models/command_node.dart';
import '../../services/api_service.dart';
import '../analytics/widgets/phc_globe_modal.dart';

class CommandScreen extends StatefulWidget {
  const CommandScreen({super.key});

  @override
  State<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  late List<CommandNode> _nodes;
  late List<CommandNode> _allRawNodes;
  bool _isCrisisSimulated = false;
  bool _isLoading = true;
  int _nodeFilterIndex = 0; // 0: All, 1: At Risk / Stockouts, 2: Normal / Surplus Stock
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allRawNodes = [];
    _nodes = CommandNode.getInitialMockData();
    _loadNodesFromApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _districtTitle = 'Srikakulam District Command';

  Future<void> _loadNodesFromApi({String? query}) async {
    setState(() => _isLoading = true);
    final searchQuery = query ?? _searchController.text.trim();
    final rawData = await ApiService.fetchPHCs(search: searchQuery.isNotEmpty ? searchQuery : null);
    if (!mounted) return;
    if (rawData.isNotEmpty) {
      final loaded = rawData.map((j) => CommandNode.fromJson(j)).toList();
      final distName = rawData.first['district_name'] ?? 'State';
      
      List<CommandNode> filtered = loaded;
      if (_nodeFilterIndex == 1) {
        filtered = loaded.where((n) => n.statusType == NodeStatusType.critical || n.statusType == NodeStatusType.warning).toList();
      } else if (_nodeFilterIndex == 2) {
        filtered = loaded.where((n) => n.statusType == NodeStatusType.surplus).toList();
      }

      setState(() {
        _districtTitle = '$distName Health Sector Command';
        _allRawNodes = loaded;
        _nodes = filtered;
        _isLoading = false;
      });
    } else {
      setState(() {
        _allRawNodes = [];
        _nodes = [];
        _isLoading = false;
      });
    }
  }

  void _handleEmergencyReroute() async {
    final res = await ApiService.executeOptimizer();
    final msg = res['message'] ?? 'Emergency Reroute Dispatched via SciPy Optimizer';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18),
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

  void _triggerFederatedLearning() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🤖 Running AI Demand Forecast across PHC nodes...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final res = await ApiService.executeFederatedLearning(numDistricts: 5, numRounds: 3);
    final msg = res['message'] ?? 'AI Demand Prediction completed!';
    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          title: const Row(
            children: [
              Icon(Icons.psychology_rounded, color: AppColors.primaryBlue, size: 22),
              SizedBox(width: 8),
              Text('AI Demand Forecast Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text(msg, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _showSimulateCrisisDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Row(
          children: [
            Icon(Icons.crisis_alert_rounded, color: AppColors.redText, size: 22),
            SizedBox(width: 8),
            Text('Simulate Outbreak / Crisis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Simulate a sudden spike in disease outbreaks across rural sectors. This will trigger automated SciPy reallocation directives and deplete buffer stock.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              setState(() => _isCrisisSimulated = true);
              final outRes = await ApiService.injectOutbreak(surgeFactor: 3.0);
              await ApiService.executeOptimizer();
              await _loadNodesFromApi();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(outRes['message'] ?? 'Crisis alert active: Stockout emergency injected!'),
                    backgroundColor: AppColors.redDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Initiate Crisis Simulation'),
          ),
        ],
      ),
    );
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
          // ── Top Title Row: Operational Jurisdiction ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OPERATIONAL JURISDICTION',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _districtTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Network status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 5, color: AppColors.greenDot),
                    SizedBox(width: 6),
                    Text(
                      'Network Synced 2m ago',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else ...[
            // ── Top 2 Metric Cards (Critical Shortages & Available Beds) ───────
            if (isDesktop)
              Row(
                children: [
                  Expanded(child: _buildShortagesMetricCard()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildBedsMetricCard()),
                ],
              )
            else ...[
              _buildShortagesMetricCard(),
              const SizedBox(height: 12),
              _buildBedsMetricCard(),
            ],
            const SizedBox(height: 16),

            // ── Unified Search & Control Hub ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
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
                  // Search Bar Input
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _loadNodesFromApi(query: val.trim());
                      },
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search PHC nodes by name, mandal, or stock status...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadNodesFromApi(query: '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills & Quick Tools Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildNodeFilterPill(0, '🏢 All PHC Nodes'),
                        const SizedBox(width: 6),
                        _buildNodeFilterPill(1, '🔴 At Risk Stock', badgeCount: _allRawNodes.where((n) => n.statusType != NodeStatusType.surplus).length),
                        const SizedBox(width: 6),
                        _buildNodeFilterPill(2, '🟢 Normal Stock', badgeCount: _allRawNodes.where((n) => n.statusType == NodeStatusType.surplus).length),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 18, color: AppColors.borderSubtle),
                        const SizedBox(width: 12),
                        _buildQuickToolsRow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section: Primary Health Centers ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text(
                      'Primary Health Centers',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(24 Active Nodes)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _nodes = _nodes.reversed.toList();
                    });
                  },
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Sort by Severity',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.unfold_more_rounded, size: 14, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Nodes List ──────────────────────────────────────────────────
            ..._nodes.map((node) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNodeCard(node),
                )),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── SHORTAGES METRIC CARD ────────────────────────────────────────────────
  Widget _buildShortagesMetricCard() {
    return InkWell(
      onTap: () {
        setState(() {
          _nodeFilterIndex = 1;
        });
        _loadNodesFromApi();
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: _nodeFilterIndex == 1 ? AppColors.redBorder : AppColors.borderSubtle),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.redBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.redText),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Critical Shortages',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.redBorder),
                ),
                child: Text(
                  _isCrisisSimulated ? '+4 from yesterday' : '+2 from yesterday',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.redText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _isCrisisSimulated ? '9 PHCs' : '7 PHCs',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Immediate Restock Required',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.redText,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  // ── BEDS METRIC CARD ─────────────────────────────────────────────────────
  Widget _buildBedsMetricCard() {
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.greenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bed_outlined, size: 16, color: AppColors.greenText),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Available Beds',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.greenBorder),
                ),
                child: const Text(
                  '68% capacity available',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '412 Beds',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Across 24 nodes',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── QUICK TOOLS ROW ───────────────────────────────────────────────────────
  Widget _buildQuickToolsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Outbreak Sim Pill
        InkWell(
          onTap: _showSimulateCrisisDialog,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.redBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.crisis_alert_rounded, size: 13, color: AppColors.redDark),
                SizedBox(width: 4),
                Text('Outbreak Sim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.redDark)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // AI Predictor Pill
        InkWell(
          onTap: _triggerFederatedLearning,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_rounded, size: 13, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text('AI Predictor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // PHC Map Pill
        InkWell(
          onTap: () => PhcGlobeModal.show(context),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_rounded, size: 13, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text('PHC Map', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
              ],
            ),
          ),
        ),
      ],
    );
  }



  // ── NODE CARD ────────────────────────────────────────────────────────────
  Widget _buildNodeCard(CommandNode node) {
    Color iconBoxBg;
    Color iconColor;
    IconData iconData;
    Color badgeBg;
    Color badgeBorder;
    Color badgeText;
    Color? statusDot;

    switch (node.statusType) {
      case NodeStatusType.critical:
        iconBoxBg = AppColors.redBg;
        iconColor = AppColors.redText;
        iconData = Icons.power_settings_new_rounded;
        badgeBg = AppColors.redBg;
        badgeBorder = AppColors.redBorder;
        badgeText = AppColors.redText;
        statusDot = AppColors.redDot;
        break;
      case NodeStatusType.warning:
        iconBoxBg = AppColors.amberBg;
        iconColor = AppColors.amberText;
        iconData = Icons.warning_amber_rounded;
        badgeBg = AppColors.amberBg;
        badgeBorder = AppColors.amberBorder;
        badgeText = AppColors.amberText;
        statusDot = null;
        break;
      case NodeStatusType.surplus:
        iconBoxBg = AppColors.greenBg;
        iconColor = AppColors.greenText;
        iconData = Icons.check_circle_outline_rounded;
        badgeBg = AppColors.greenBg;
        badgeBorder = AppColors.greenBorder;
        badgeText = AppColors.greenText;
        statusDot = null;
        break;
    }

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
          // Header row
          InkWell(
            onTap: () {
              setState(() {
                node.isExpanded = !node.isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Row(
              children: [
                // Icon square
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBoxBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(iconData, size: 19, color: iconColor),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            node.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (node.statusType == NodeStatusType.critical) ...[
                            const SizedBox(width: 6),
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
                      const SizedBox(height: 2),
                      Text(
                        node.distanceSector,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: badgeBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (statusDot != null) ...[
                        Icon(Icons.circle, size: 5, color: statusDot),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        node.badgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: badgeText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Chevron
                Icon(
                  node.isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Expanded Content
          if (node.isExpanded) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 12),

            if (node.depletedSupplies != null) ...[
              // Depleted essential supplies box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEPLETED ESSENTIAL SUPPLIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.redText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      node.depletedSupplies!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    if (node.recommendedDonor != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Recommended Donor: ${node.recommendedDonor!}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Emergency Reroute & Assign Tablets Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton.icon(
                              onPressed: _handleEmergencyReroute,
                              icon: const Icon(Icons.local_shipping_outlined, size: 15),
                              label: const Text(
                                'Emergency Reroute',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: OutlinedButton.icon(
                              onPressed: () => _showAssignTabletsModal(node),
                              icon: const Icon(Icons.medication_rounded, size: 15, color: Color(0xFF2563EB)),
                              label: const Text(
                                '💊 Assign Tablets',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF2563EB)),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
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
              const SizedBox(height: 10),
            ],

            // 4 Stat Grid (Cold Chain, Occupancy, Transit ETA, Medical Officer)
            Row(
              children: [
                Expanded(child: _buildMetricTile('Cold Chain', node.coldChain ?? '3.8°C (Optimal)')),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricTile('Occupancy', node.occupancy ?? '92%')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMetricTile('Transit ETA', node.transitEta ?? '42 mins')),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricTile('Medical Officer', node.medicalOfficer ?? 'Dr. S. Rao')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeFilterPill(int index, String label, {int? badgeCount}) {
    final isSelected = _nodeFilterIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _nodeFilterIndex = index;
        });
        _loadNodesFromApi();
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.borderCard : AppColors.borderSubtle,
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAssignTabletsModal(CommandNode node) {
    String selectedMedId = 'MED-AMOX-500';
    String selectedMedName = 'Amoxicillin 500mg Tablets';
    int selectedQty = 500;

    final tabletOptions = [
      {'id': 'MED-AMOX-500', 'name': 'Amoxicillin 500mg Tablets'},
      {'id': 'MED-PARA-650', 'name': 'Paracetamol 650mg Tablets'},
      {'id': 'MED-ORS-75', 'name': 'ORS Hydration Sachets (21g)'},
      {'id': 'MED-INSU-100', 'name': 'Human Insulin 100IU Vials'},
      {'id': 'MED-MAL-20', 'name': 'Artemether + Lumefantrine Tablets'},
      {'id': 'MED-OXY-10', 'name': 'Oxytocin Injection 10IU Ampoules'},
      {'id': 'MED-AZI-500', 'name': 'Azithromycin 500mg Tablets'},
      {'id': 'MED-CIP-500', 'name': 'Ciprofloxacin 500mg Tablets'},
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              title: Row(
                children: [
                  const Icon(Icons.medication_rounded, color: Color(0xFF2563EB), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Assign Tablets to ${node.name}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Tablet / Medicine Type:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedMedId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    items: tabletOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt['id'],
                        child: Text(opt['name']!, style: const TextStyle(fontSize: 12.5)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedMedId = val;
                          selectedMedName = tabletOptions.firstWhere((o) => o['id'] == val)['name']!;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Quantity (Units / Tablets):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [200, 500, 1000].map((q) {
                      final isSel = selectedQty == q;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$q units'),
                          selected: isSel,
                          onSelected: (sel) {
                            if (sel) setDialogState(() => selectedQty = q);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogCtx).pop();
                    final res = await ApiService.requestEmergencyStock(
                      phcId: node.id,
                      medicineId: selectedMedId,
                      requestedQuantity: selectedQty,
                      reason: 'DMO Priority Allocation of $selectedMedName ($selectedQty units) to ${node.name}',
                    );
                    await _loadNodesFromApi();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['message'] ?? '💊 Successfully assigned $selectedQty units of $selectedMedName to ${node.name}!'),
                          backgroundColor: const Color(0xFF2563EB),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Dispatch Tablets'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
