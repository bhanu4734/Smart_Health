import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../shared/models/command_node.dart';
import '../../services/api_service.dart';

class CommandScreen extends StatefulWidget {
  const CommandScreen({super.key});

  @override
  State<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  late List<CommandNode> _nodes;
  bool _isCrisisSimulated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nodes = CommandNode.getInitialMockData();
    _loadNodesFromApi();
  }

  String _districtTitle = 'Srikakulam District Command';

  Future<void> _loadNodesFromApi() async {
    setState(() => _isLoading = true);
    final rawData = await ApiService.fetchPHCs();
    if (rawData.isNotEmpty) {
      final loaded = rawData.map((j) => CommandNode.fromJson(j)).toList();
      final distName = rawData.first['district_name'] ?? 'State';
      setState(() {
        _districtTitle = '$distName Health Sector Command';
        _nodes = loaded.take(6).toList(); // Show top nodes
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
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
          backgroundColor: AppColors.redDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _triggerFederatedLearning() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌐 Initiating Sovereign Federated Learning across district silos...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final res = await ApiService.executeFederatedLearning(numDistricts: 5, numRounds: 3);
    final msg = res['message'] ?? 'Federated Learning simulation completed!';
    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          title: const Row(
            children: [
              Icon(Icons.hub_rounded, color: AppColors.primaryBlue, size: 22),
              SizedBox(width: 8),
              Text('Federated Learning Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28.0 : 16.0,
        vertical: isDesktop ? 20.0 : 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OPERATIONAL JURISDICTION
          const Text(
            'OPERATIONAL JURISDICTION',
            style: AppTextStyles.contextNode,
          ),
          const SizedBox(height: 4),

          // District Command Heading
          Text(
            _districtTitle,
            style: AppTextStyles.pageHeading,
          ),
          const SizedBox(height: 10),

          // Network Synced 2m ago pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, size: 6, color: AppColors.greenDot),
                SizedBox(width: 6),
                Text(
                  'Network Synced 2m ago',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Metric Card 1: Critical Shortages (with red left border)
          AppCard(
            leftAccentColor: AppColors.redDark,
            leftAccentWidth: 4.0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Critical Shortages',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.redBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.redBorder),
                      ),
                      child: Text(
                        _isCrisisSimulated ? '+4 from yesterday' : '+2 from yesterday',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.redText,
                        ),
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
                      _isCrisisSimulated ? '9 PHCs' : '7 PHCs',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Immediate Restock Required',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.redText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Metric Card 2: Available Beds
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Beds',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.greenBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.greenBorder),
                      ),
                      child: const Text(
                        '68% capacity available',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '412 Beds',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Across 24 nodes',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section: Primary Health Centers & Sort by Severity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text(
                    'Primary Health\nCenters',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '(24 Active\nNodes)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.2,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Sort by\nSeverity',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.unfold_more_rounded, size: 16, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nodes list
          ..._nodes.map((node) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildNodeCard(node),
              )),

          const SizedBox(height: 12),

          // Action buttons: Simulate Outbreak & Federated Learning
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: _showSimulateCrisisDialog,
                  icon: const Text(
                    '*',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.redText,
                    ),
                  ),
                  label: const Text(
                    'Simulate Outbreak / Crisis',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.redDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.redBorder, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _triggerFederatedLearning,
                  icon: const Icon(Icons.hub_rounded, size: 18),
                  label: const Text(
                    'Execute Sovereign Federated Learning (FedAvg)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

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

    return AppCard(
      padding: const EdgeInsets.all(12),
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
            child: Row(
              children: [
                // Icon square
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBoxBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(iconData, size: 18, color: iconColor),
                  ),
                ),
                const SizedBox(width: 10),

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
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),

                // Chevron
                Icon(
                  node.isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Expanded Content
          if (node.isExpanded) ...[
            const SizedBox(height: 12),
            if (node.depletedSupplies != null) ...[
              // Depleted essential supplies box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.redBorder, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEPLETED ESSENTIAL SUPPLIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.redText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      node.depletedSupplies!,
                      style: const TextStyle(
                        fontSize: 12,
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
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Emergency Reroute Button
                    SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: _handleEmergencyReroute,
                        icon: const Icon(Icons.local_shipping_outlined, size: 15),
                        label: const Text(
                          'Emergency Reroute',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 4 Stat Grid (Cold Chain, Occupancy, Transit ETA, Medical Officer)
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Cold Chain',
                    node.coldChain ?? '3.8°C (Optimal)',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'Occupancy',
                    node.occupancy ?? '92%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Transit ETA',
                    node.transitEta ?? '42 mins',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'Medical Officer',
                    node.medicalOfficer ?? 'Dr. S. Rao',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
