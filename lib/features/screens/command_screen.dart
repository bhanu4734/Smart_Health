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
    if (!mounted) return;
    if (rawData.isNotEmpty) {
      final loaded = rawData.map((j) => CommandNode.fromJson(j)).toList();
      final distName = rawData.first['district_name'] ?? 'State';
      setState(() {
        _districtTitle = '$distName Health Sector Command';
        _nodes = loaded.take(6).toList();
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
          backgroundColor: AppColors.primaryBlue,
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
              Column(
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
            const SizedBox(height: 24),

            // ── Action Buttons Bar ──────────────────────────────────────────
            if (isDesktop)
              Row(
                children: [
                  Expanded(child: _buildSimulateOutbreakButton()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFederatedLearningButton()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGlobalPhc3DButton()),
                ],
              )
            else ...[
              _buildSimulateOutbreakButton(),
              const SizedBox(height: 10),
              _buildFederatedLearningButton(),
              const SizedBox(height: 10),
              _buildGlobalPhc3DButton(),
            ],
            const SizedBox(height: 22),

            // ── 3D Global PHC Network Mesh Showcase Banner ───────────────────
            _buildGlobalPhcShowcaseBanner(context, isDesktop),
            const SizedBox(height: 26),

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

  // ── ACTION BUTTONS ───────────────────────────────────────────────────────
  Widget _buildSimulateOutbreakButton() {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: _showSimulateCrisisDialog,
        icon: const Icon(Icons.crisis_alert_rounded, size: 16, color: AppColors.redText),
        label: const Text(
          'Simulate Outbreak / Crisis',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.redDark,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.redBorder, width: 1.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildFederatedLearningButton() {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: _triggerFederatedLearning,
        icon: const Icon(Icons.hub_rounded, size: 16),
        label: const Text(
          'Execute Sovereign Federated Learning (FedAvg)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalPhc3DButton() {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: () => PhcGlobeModal.show(context),
        icon: const Icon(Icons.map_rounded, size: 16, color: Color(0xFF0284C7)),
        label: const Text(
          'OpenStreetMap Mesh (24.54, 77.65)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalPhcShowcaseBanner(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 22.0 : 16.0,
        vertical: isDesktop ? 18.0 : 14.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                _buildShowcaseIconOrb(),
                const SizedBox(width: 18),
                Expanded(child: _buildShowcaseTextInfo()),
                const SizedBox(width: 20),
                _buildShowcaseLaunchButton(context),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildShowcaseIconOrb(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildShowcaseHeader()),
                  ],
                ),
                const SizedBox(height: 10),
                _buildShowcaseDescription(),
                const SizedBox(height: 12),
                _buildShowcaseMetaPills(),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: _buildShowcaseLaunchButton(context),
                ),
              ],
            ),
    );
  }

  Widget _buildShowcaseIconOrb() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE0F2FE),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.map_rounded,
        color: Color(0xFF0284C7),
        size: 24,
      ),
    );
  }

  Widget _buildShowcaseTextInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShowcaseHeader(),
        const SizedBox(height: 4),
        _buildShowcaseDescription(),
        const SizedBox(height: 8),
        _buildShowcaseMetaPills(),
      ],
    );
  }

  Widget _buildShowcaseHeader() {
    return Row(
      children: [
        const Text(
          'OPENSTREETMAP PHC NETWORK MESH',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: const Text(
            'LIVE GEODESIC GIS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF047857),
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShowcaseDescription() {
    return const Text(
      'Real OpenStreetMap cartography centered at (24.54° N, 77.65° E) with live Telangana PHC edge nodes, supply buffers, and inter-district reallocation corridors.',
      style: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        height: 1.35,
      ),
    );
  }

  Widget _buildShowcaseMetaPills() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildShowcaseBadge(Icons.hub_rounded, '24 Monitored Nodes'),
        _buildShowcaseBadge(Icons.alt_route_rounded, '7 Cold-Chain Corridors'),
        _buildShowcaseBadge(Icons.touch_app_rounded, 'OpenStreetMap GIS & Telemetry HUD'),
      ],
    );
  }

  Widget _buildShowcaseBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF0284C7)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseLaunchButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => PhcGlobeModal.show(context),
      icon: const Icon(Icons.fullscreen_rounded, size: 16),
      label: const Text(
        'Open Interactive Map',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
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
                          backgroundColor: const Color(0xFF1E293B),
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
