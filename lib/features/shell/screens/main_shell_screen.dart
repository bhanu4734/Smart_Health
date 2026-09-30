import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/app_header.dart';
import '../../screens/dispense_screen.dart';
import '../../screens/command_screen.dart';
import '../../screens/transfers_screen.dart';
import '../../screens/analytics_screen.dart';
import '../../../widgets/quick_tour_dialog.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final String? userRole;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.userRole,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  late String _activeRole;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _activeRole = widget.userRole ?? AuthController().userRole;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AuthController().hasSeenTour) {
        QuickTourDialog.show(context);
      }
    });
  }

  bool get _isAdmin {
    final lower = _activeRole.toLowerCase();
    return lower.contains('admin') || lower.contains('district') || lower.contains('dmo');
  }

  bool get _isDriver {
    final lower = _activeRole.toLowerCase();
    return lower.contains('driver') || lower.contains('fleet') || lower.contains('transport');
  }

  List<Widget> get _screens {
    if (_isDriver) {
      return const [
        TransfersScreen(),
      ];
    } else if (_isAdmin) {
      return const [
        CommandScreen(),
        TransfersScreen(),
        AnalyticsScreen(),
      ];
    } else {
      return const [
        DispenseScreen(),
        TransfersScreen(),
      ];
    }
  }

  List<Map<String, dynamic>> get _navItems {
    if (_isDriver) {
      return const [
        {
          'icon': Icons.local_shipping_rounded,
          'label': 'My Assigned Deliveries',
          'badge': 'Active Fleet',
        },
      ];
    } else if (_isAdmin) {
      return const [
        {
          'icon': Icons.grid_view_rounded,
          'label': 'District Command Hub',
          'badge': 'Surge Center',
        },
        {
          'icon': Icons.swap_horiz_rounded,
          'label': 'Stock Logistics & OTP',
          'badge': 'Directives',
        },
        {
          'icon': Icons.auto_graph_rounded,
          'label': 'Surge Analytics',
          'badge': 'Outbreak ML',
        },
      ];
    } else {
      return const [
        {
          'icon': Icons.local_pharmacy_rounded,
          'label': 'Daily Dispensing',
          'badge': 'PHC Register',
        },
        {
          'icon': Icons.swap_horiz_rounded,
          'label': 'Directives & OTP Receipt',
          'badge': 'District Sync',
        },
      ];
    }
  }

  void _handleLogout() {
    AuthController().logout();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  void _handleSync() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project Resilience: Ledger & Telemetry Synced'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── MOBILE LAYOUT ─────────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    final screens = _screens;
    final activeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.symmetric(
                  vertical: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top App Bar: [+] Project Resilience & Role Badge / Logout Icon
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderLight, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlueLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primaryBlueBorder,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Project Resilience',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // RBAC Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isAdmin ? AppColors.purpleLight : AppColors.greenBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isAdmin ? AppColors.purpleAccent.withValues(alpha: 0.3) : AppColors.greenBorder,
                                ),
                              ),
                              child: Text(
                                _isAdmin ? '🛡️ Admin' : '🏥 PHC Staff',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _isAdmin ? AppColors.purpleAccent : AppColors.greenText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.sync_rounded,
                                size: 18,
                                color: AppColors.primaryBlue,
                              ),
                              onPressed: _handleSync,
                              tooltip: 'Sync Ledger & Telemetry',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                size: 20,
                                color: AppColors.redText,
                              ),
                              onPressed: _handleLogout,
                              tooltip: 'Logout & End Session',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Screen Body (Scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: KeyedSubtree(
                          key: ValueKey<int>(activeIndex),
                          child: screens[activeIndex],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Role-Filtered Navigation Bar
                  MobileBottomNav(
                    currentIndex: activeIndex,
                    items: _navItems,
                    onTap: (index) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── DESKTOP / TABLET LAYOUT ────────────────────────────────────────────────
  Widget _buildDesktopLayout() {
    final screens = _screens;
    final activeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top App Header bar (full width)
          AppHeader(
            onNotificationsTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No urgent critical stock alerts')),
              );
            },
            onSettingsTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Node Settings: Warangal Sector 4 (Live Session)')),
              );
            },
          ),

          // Sidebar + Content area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left sidebar navigation with dynamic RBAC items
                DesktopSidebar(
                  selectedIndex: activeIndex,
                  items: _navItems,
                  userRole: _activeRole,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                ),

                // Main content area — scrollable
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey<int>(activeIndex),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: screens[activeIndex],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
  }
}
