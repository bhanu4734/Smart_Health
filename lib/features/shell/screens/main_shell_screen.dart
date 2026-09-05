import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/app_header.dart';
import '../../screens/dispense_screen.dart';
import '../../screens/command_screen.dart';
import '../../screens/transfers_screen.dart';
import '../../screens/analytics_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DispenseScreen(),
    CommandScreen(),
    TransfersScreen(),
    AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                  // Top App Bar: [+] Project Resilience & Sync Icon
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.sync_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: _handleSync,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 18,
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
                          key: ValueKey<int>(_currentIndex),
                          child: _screens[_currentIndex],
                        ),
                      ),
                    ),
                  ),

                  // Bottom 4-Item Navigation Bar
                  MobileBottomNav(
                    currentIndex: _currentIndex,
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
                const SnackBar(content: Text('Node settings: Warangal Sector 4')),
              );
            },
          ),

          // Sidebar + Content area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left sidebar navigation
                DesktopSidebar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                ),

                // Main content area — scrollable
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentIndex),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Center(
                          child: ConstrainedBox(
                            // Constrain content width on very large screens
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: _screens[_currentIndex],
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
