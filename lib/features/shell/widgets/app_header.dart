import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/screens/welcome_screen.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSettingsTap;

  const AppHeader({
    super.key,
    this.onNotificationsTap,
    this.onSettingsTap,
  });

  void _showProfileModal(BuildContext context) {
    final auth = AuthController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.purpleLight,
              radius: 18,
              child: const Text('RW', style: TextStyle(color: AppColors.purpleAccent, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.userName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(auth.userRole, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Official Email: ${auth.userEmail}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            const Text('Terminal ID: PHC-WAR-882 (Live Session)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            const Divider(),
            const Text(
              'End session and lock clinical terminal?',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (r) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purpleAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final auth = AuthController();

    return Container(
      height: isMobile ? 48 : 56,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: App icon & enterprise title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.devices_outlined,
                  size: 18,
                  color: AppColors.purpleAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.purpleAccent,
                  letterSpacing: -0.3,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greenBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 6, color: AppColors.greenDot),
                      SizedBox(width: 5),
                      Text(
                        'Cloud Sync Online',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // Right side actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onNotificationsTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No urgent critical stock alerts')),
                        );
                      },
                  tooltip: 'Notifications',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onSettingsTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Node settings: Warangal Sector 4')),
                        );
                      },
                  tooltip: 'Node Settings',
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, indent: 14, endIndent: 14),
                const SizedBox(width: 12),
              ],
              InkWell(
                onTap: () => _showProfileModal(context),
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 14 : 16,
                      backgroundColor: AppColors.purpleLight,
                      child: Text(
                        auth.isGuest ? 'G' : 'RW',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.purpleAccent,
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            auth.userName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            auth.userRole,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
