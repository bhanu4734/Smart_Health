import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../services/api_service.dart';
import '../../auth/controllers/auth_controller.dart';

class DesktopSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Map<String, dynamic>> items;
  final String? userRole;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    this.userRole,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  bool _isOperationsExpanded = true;

  bool get _isAdmin {
    final role = (widget.userRole ?? AuthController().userRole).toLowerCase();
    return role.contains('admin') || role.contains('district');
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Workspace Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 16, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Project Resilience',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        auth.phcName.isNotEmpty ? auth.phcName : 'Clinical Command Hub',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Sidebar collapse/expand toggle icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Icon(
                    Icons.view_sidebar_outlined,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Search Bar with shortcut indicator ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
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
                children: [
                  const Icon(Icons.search_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Search network...',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Text(
                      '/',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Scrollable Navigation Section (Overflow Safe) ─────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryHeader('Essentials'),
                  ...widget.items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return _buildSidebarItem(
                      index: idx,
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      badgeText: item['badge'] as String?,
                    );
                  }),

                  // Admin-Only Command & Logistics Sections
                  if (_isAdmin) ...[
                    // Subtle secondary items with active handlers
                    _buildSecondarySidebarItem(
                      Icons.notifications_active_outlined,
                      'Emergency Alerts',
                      badge: '3',
                      badgeIsCount: true,
                      onTap: () => _showEmergencyAlerts(context),
                    ),
                    _buildSecondarySidebarItem(
                      Icons.auto_awesome_outlined,
                      'Optimizer Engine',
                      onTap: () => _showOptimizerEngine(context),
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1, indent: 14, endIndent: 14, color: AppColors.borderSubtle),
                    const SizedBox(height: 10),

                    // ── Operations & Logistics Section (Collapsible) ──────────
                    _buildCategoryHeader(
                      'Operations',
                      hasChevron: true,
                      isExpanded: _isOperationsExpanded,
                      onTapToggle: () {
                        setState(() {
                          _isOperationsExpanded = !_isOperationsExpanded;
                        });
                      },
                    ),
                    if (_isOperationsExpanded) ...[
                      _buildSecondarySidebarItem(
                        Icons.explore_outlined,
                        'PHC Directory',
                        onTap: () => _showPhcDirectory(context),
                      ),
                      _buildSecondarySidebarItem(
                        Icons.inventory_2_outlined,
                        'Supply Requisitions',
                        onTap: () => _showSupplyRequisition(context),
                      ),
                      _buildSecondarySidebarItem(
                        Icons.hub_outlined,
                        'District Mesh',
                        count: '24',
                        onTap: () => _showDistrictMesh(context),
                      ),
                      _buildSecondarySidebarItem(
                        Icons.local_shipping_outlined,
                        'Depot Logistics',
                        onTap: () => _showDepotLogistics(context),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // ── Compact Sync Telemetry Indicator ─────────────────────────────
          InkWell(
            onTap: () => _showDistrictMesh(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
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
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.greenDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'MySQL • SciPy Active',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.greenBg,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.greenText),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Settings / Support links
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                _buildFooterLink(
                  Icons.wb_sunny_outlined,
                  'Appearance',
                  onTap: () => _showAppearanceDialog(context),
                ),
                _buildFooterLink(
                  Icons.help_outline_rounded,
                  'Help & support',
                  onTap: () => _showHelpSupportDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    String title, {
    bool hasChevron = false,
    bool isExpanded = true,
    VoidCallback? onTapToggle,
  }) {
    return InkWell(
      onTap: onTapToggle,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: -0.1,
              ),
            ),
            if (hasChevron)
              Icon(
                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
    String? badgeText,
  }) {
    final isSelected = widget.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
      child: InkWell(
        onTap: () => widget.onDestinationSelected(index),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondarySidebarItem(
    IconData icon,
    String label, {
    String? badge,
    bool badgeIsCount = false,
    String? count,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        hoverColor: Colors.black.withValues(alpha: 0.03),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (count != null)
                Text(
                  count,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(IconData icon, String label, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── MODAL DIALOG HANDLERS ──────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  // 1. Emergency Alerts Modal
  void _showEmergencyAlerts(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.redBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppColors.redText, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Active Emergency Alerts (3)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAlertCard(
                severity: 'CRITICAL',
                title: 'PHC Gudur: Zero-Stock Imminent',
                desc: 'Anti-Rabies Serum projected deficit in under 4 hours due to canine attack surge in Mandal 4.',
                color: AppColors.redText,
                bgColor: AppColors.redBg,
              ),
              const SizedBox(height: 8),
              _buildAlertCard(
                severity: 'WARNING',
                title: 'Khammam Sub-Center: Buffer Depletion',
                desc: 'Amoxicillin 250mg inventory below minimum 30-day reserve threshold (14% remaining).',
                color: AppColors.amberText,
                bgColor: AppColors.amberBg,
              ),
              const SizedBox(height: 8),
              _buildAlertCard(
                severity: 'TELEMETRY',
                title: 'Cold-Box #B2: In Transit via SH-14',
                desc: 'Temperature verified at 6.8°C (Within 2.0°C – 8.0°C clinical threshold). ETA: 32 mins.',
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final res = await ApiService.injectOutbreak(surgeFactor: 3.0);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? 'Outbreak surge simulation triggered successfully!'),
                    backgroundColor: AppColors.amberText,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.flash_on_rounded, size: 16),
            label: const Text('Simulate 3.0x Outbreak Surge'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Acknowledge All'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String severity,
    required String title,
    required String desc,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  severity,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.3),
          ),
        ],
      ),
    );
  }

  // 2. Optimizer Engine Modal
  void _showOptimizerEngine(BuildContext context) {
    double radius = 45.0;
    bool isRunning = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'SciPy Redistribution Optimizer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solves Linear Sum Assignment Optimization with cold-chain transit radius constraints across all 24 PHC cluster nodes.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Max Transport Radius:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('${radius.toInt()} km', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                          ],
                        ),
                        Slider(
                          value: radius,
                          min: 15.0,
                          max: 90.0,
                          divisions: 15,
                          label: '${radius.toInt()} km',
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (v) => setDialogState(() => radius = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('15 km (Local)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('45 km (District standard)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text('90 km (Regional)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (isRunning)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 10),
                            Text('Running SciPy Linear Assignment...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: isRunning
                    ? null
                    : () async {
                        setDialogState(() => isRunning = true);
                        final res = await ApiService.executeOptimizer(maxTransportRadiusKm: radius);
                        setDialogState(() => isRunning = false);
                        if (dialogContext.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res['message'] ?? 'Redistribution optimization complete!'),
                              backgroundColor: const Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Run Optimization'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 3. PHC Directory Modal
  void _showPhcDirectory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.explore_rounded, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'District PHC Directory',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 540,
          height: 420,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchPHCs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final phcs = snapshot.data ?? [];
              if (phcs.isEmpty) {
                return const Center(child: Text('No PHC nodes discovered. Check MySQL sync.'));
              }
              return ListView.separated(
                itemCount: phcs.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, idx) {
                  final phc = phcs[idx];
                  final name = phc['name'] ?? phc['id'] ?? 'PHC Node';
                  final district = phc['district_name'] ?? 'Warangal District';
                  final beds = phc['available_beds'] ?? 10;
                  final staff = phc['staff_on_duty_count'] ?? 6;

                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEFF6FF),
                      radius: 18,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text('$district • $beds Beds • $staff Staff on duty', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenBg,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.greenBorder),
                      ),
                      child: const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.greenText)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // 4. Supply Requisitions Modal
  void _showSupplyRequisition(BuildContext context) {
    final medController = TextEditingController(text: 'Paracetamol 500mg');
    final qtyController = TextEditingController(text: '500');
    final reasonController = TextEditingController(text: 'Anticipated weekend clinical demand surge');
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFD97706), size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Emergency Supply Requisition',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Request stock dispatch directly to the District Medical Queue.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: medController,
                    decoration: const InputDecoration(
                      labelText: 'Essential Medicine',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Requested Quantity',
                      suffixText: 'units',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      ActionChip(label: const Text('250 units'), onPressed: () => qtyController.text = '250'),
                      ActionChip(label: const Text('500 units'), onPressed: () => qtyController.text = '500'),
                      ActionChip(label: const Text('1000 units'), onPressed: () => qtyController.text = '1000'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Clinical Urgency & Reason',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setDialogState(() => isSubmitting = true);
                        final auth = AuthController();
                        final res = await ApiService.requestEmergencyStock(
                          phcId: auth.phcId.isNotEmpty ? auth.phcId : 'PHC-WAR-001',
                          medicineId: medController.text.trim(),
                          requestedQuantity: int.tryParse(qtyController.text.trim()) ?? 500,
                          reason: reasonController.text.trim(),
                        );
                        setDialogState(() => isSubmitting = false);
                        if (dialogCtx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res['message'] ?? 'Requisition submitted to district queue!'),
                              backgroundColor: const Color(0xFF2563EB),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Requisition'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 5. District Mesh Modal
  void _showDistrictMesh(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hub_rounded, color: AppColors.greenText, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'District Mesh Telemetry (24 Nodes)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.greenBorder),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.greenText, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cluster Health: 100% Operational\nAll 24 PHC edge nodes reporting telemetry without latency degradation.',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.greenText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildMeshStat('Average Latency', '38 ms')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMeshStat('MySQL Schema', 'Synced')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMeshStat('SciPy Daemon', 'Active')),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Node Connectivity Grid (24 Nodes):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(24, (i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.greenDot, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text('PHC-${i + 1 < 10 ? '0' : ''}${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshStat(String label, String val) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // 6. Depot Logistics Modal
  void _showDepotLogistics(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF0D9488), size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Central Depot Logistics & Fleet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Central Buffer Reserve Capacity:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildMeshStat('Anti-Rabies Serum', '2,400 Vials (Cold)')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMeshStat('Paracetamol 500mg', '45,000 Units')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildMeshStat('ORS Sachets', '32,000 Packs')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMeshStat('Amoxicillin 250mg', '18,500 Units')),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Active Cold-Chain Transport Corridors:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _buildLogisticsFleetRow('Van #04', 'Warangal Depot ➔ Nalgonda Rural', 'Cold-Box #B2 • 4.2°C', 'ETA: 24 mins'),
              const SizedBox(height: 6),
              _buildLogisticsFleetRow('Van #09', 'Central Hub ➔ Khammam Corridor', 'Ambient Medical Kit', 'ETA: 48 mins'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsFleetRow(String vehicle, String route, String spec, String eta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$vehicle • $route', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(spec, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(eta, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }

  // 7. Appearance Dialog
  void _showAppearanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.wb_sunny_rounded, color: Color(0xFFD97706), size: 20),
            SizedBox(width: 8),
            Text('Appearance & Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Project Resilience is running in Enterprise Modern Clean Light Theme designed for high-visibility healthcare command rooms.\n\nDark mode synchronization will follow hospital terminal operating standards.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 8. Help & Support Dialog
  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: Color(0xFF2563EB), size: 20),
            SizedBox(width: 8),
            Text('Clinical Support & Emergency Desk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('District Medical Office 24/7 Hotline: 1800-425-HEALTH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('Cold-Chain Dispatch Telemetry Support: ext. 4022', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text('Central MySQL Ledger & Telemetry Ops: admin@resilience.health.gov', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 6),
            Text('SciPy optimization routine executes periodically every 15 minutes or upon manual trigger.', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
