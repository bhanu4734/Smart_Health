import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../utils/responsive.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    this.onNotificationsTap,
    this.onSettingsTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

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
                'PHC.Dispensing',
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
                    color: AppColors.greenBadgeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greenBadgeBorder, width: 0.8),
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
                  onPressed: onNotificationsTap ?? () {},
                  tooltip: 'Notifications',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onSettingsTap ?? () {},
                  tooltip: 'Node Settings',
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, indent: 14, endIndent: 14),
                const SizedBox(width: 12),
              ],
              InkWell(
                onTap: onProfileTap ?? () {},
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 14 : 16,
                      backgroundColor: AppColors.purpleLight,
                      child: const Text(
                        'RW',
                        style: TextStyle(
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
                        children: const [
                          Text(
                            'Dr. R. Warangal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Pharmacist Officer',
                            style: TextStyle(
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
