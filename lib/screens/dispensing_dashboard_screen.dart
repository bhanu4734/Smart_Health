import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/medicine_inventory_item.dart';
import '../utils/responsive.dart';
import '../widgets/app_header.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/mobile_bottom_navigation.dart';
import '../widgets/project_header.dart';
import '../widgets/clinic_status_card.dart';
import '../widgets/inventory_search_bar.dart';
import '../widgets/dispensing_ledger_header.dart';
import '../widgets/medicine_inventory_card.dart';
import 'login_screen.dart';

class DispensingDashboardScreen extends StatefulWidget {
  const DispensingDashboardScreen({super.key});

  @override
  State<DispensingDashboardScreen> createState() => _DispensingDashboardScreenState();
}

class _DispensingDashboardScreenState extends State<DispensingDashboardScreen> {
  int _selectedNavIndex = 0;
  String _selectedPriority = 'Standard';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late List<MedicineInventoryItem> _inventoryItems;

  @override
  void initState() {
    super.initState();
    _inventoryItems = MedicineInventoryItem.getInitialMockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleDispense(MedicineInventoryItem item, int quantity) {
    setState(() {
      final index = _inventoryItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        final current = _inventoryItems[index];
        final newQuantity = (current.availableUnits - quantity).clamp(0, 999999);
        _inventoryItems[index] = current.copyWith(availableUnits: newQuantity);
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Dispensed $quantity units of ${item.name}'),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleRefresh() {
    setState(() {
      _inventoryItems = MedicineInventoryItem.getInitialMockData();
      _searchController.clear();
      _searchQuery = '';
      _selectedPriority = 'Standard';
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inventory ledger synced with PHC Central Server'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBarcodeScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Simulating barcode scanner... MED-8821 detected!'),
        backgroundColor: AppColors.purpleAccent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    setState(() {
      _searchController.text = 'MED-8821';
      _searchQuery = 'MED-8821';
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, size: 20, color: AppColors.purpleAccent),
            SizedBox(width: 8),
            Text(
              'End Clinical Session?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Lock this dispensing terminal and return to the login screen?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  List<MedicineInventoryItem> get _filteredItems {
    return _inventoryItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesPriority = _selectedPriority.isEmpty ||
          item.priority.toLowerCase() == _selectedPriority.toLowerCase();

      return matchesSearch && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Row(
          children: [
            // Left Desktop Sidebar
            if (isDesktop)
              DesktopSidebar(
                selectedIndex: _selectedNavIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedNavIndex = index);
                },
              ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Application Header
                  AppHeader(
                    onNotificationsTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No urgent critical stock alerts')),
                      );
                    },
                    onSettingsTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Node settings: PHC Warangal Sector 4')),
                      );
                    },
                    onProfileTap: _handleLogout,
                  ),

                  // Main View Switcher
                  Expanded(
                    child: _buildSelectedTabContent(isDesktop),
                  ),

                  // Bottom Navigation on Mobile/Tablet
                  if (!isDesktop)
                    MobileBottomNavigation(
                      currentIndex: _selectedNavIndex,
                      onTap: (index) {
                        setState(() => _selectedNavIndex = index);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(bool isDesktop) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildDispensingWorkspace(isDesktop);
      case 1:
        return _buildPlaceholderScreen(
          icon: Icons.grid_view_rounded,
          title: 'Command Center',
          subtitle: 'Real-time ward capacity, doctor rota, and triage dispatch.',
        );
      case 2:
        return _buildPlaceholderScreen(
          icon: Icons.swap_horiz_rounded,
          title: 'Stock Transfers & Manifests',
          subtitle: 'Inbound supply logistics from District Warehouse Warangal.',
        );
      case 3:
        return _buildPlaceholderScreen(
          icon: Icons.auto_graph_rounded,
          title: 'Clinical Analytics & Consumption',
          subtitle: 'Daily burn rate, safe inventory forecasts, and stock coverage.',
        );
      default:
        return _buildDispensingWorkspace(isDesktop);
    }
  }

  Widget _buildDispensingWorkspace(bool isDesktop) {
    if (isDesktop) {
      // Desktop / Web layout with max-width or responsive grid
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: _buildWorkspaceCard(isDesktop: true),
          ),
        ),
      );
    } else {
      // Mobile / Tablet layout
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: _buildWorkspaceCard(isDesktop: false),
          ),
        ),
      );
    }
  }

  Widget _buildWorkspaceCard({required bool isDesktop}) {
    final filtered = _filteredItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purpleAccent,
          width: isDesktop ? 1.5 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleAccent.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Header with "Project Resilience" & sync
          ProjectHeader(
            onRefresh: _handleRefresh,
          ),
          const SizedBox(height: 14),

          // Inventory Status Progress / Pill
          const ClinicStatusCard(
            availableBeds: 10,
            totalBeds: 24,
            staffOnDuty: 3,
            totalStaff: 4,
          ),
          const SizedBox(height: 14),

          // Search Field
          InventorySearchBar(
            controller: _searchController,
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
            onScanBarcode: _handleBarcodeScan,
          ),
          const SizedBox(height: 16),

          // Dispensing Ledger Header with Priority Filter
          DispensingLedgerHeader(
            selectedPriority: _selectedPriority,
            onPriorityChanged: (priority) {
              setState(() => _selectedPriority = priority);
            },
          ),
          const SizedBox(height: 14),

          // Medicine Inventory List / Grid
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 36, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  const Text(
                    'No medicines found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try changing search query or priority filter ("$_selectedPriority")',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else if (isDesktop && filtered.length > 1)
            // 2-column grid for Desktop view
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: filtered.map((item) {
                      return SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: MedicineInventoryCard(
                          item: item,
                          onDispense: (qty) => _handleDispense(item, qty),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    children: filtered.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MedicineInventoryCard(
                          item: item,
                          onDispense: (qty) => _handleDispense(item, qty),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            )
          else
            // Single column for Mobile view
            Column(
              children: filtered.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MedicineInventoryCard(
                    item: item,
                    onDispense: (qty) => _handleDispense(item, qty),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderScreen({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.purpleAccent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _selectedNavIndex = 0);
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Dispensing Ledger'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
