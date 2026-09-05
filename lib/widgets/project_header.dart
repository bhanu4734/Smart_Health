import 'package:flutter/material.dart';
import '../app/theme.dart';

class ProjectHeader extends StatelessWidget {
  final VoidCallback? onRefresh;

  const ProjectHeader({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar inside the main container
        Row(
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
                      color: AppColors.tagAntibioticBorder,
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
                    letterSpacing: -0.2,
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
              onPressed: onRefresh ?? () {},
              tooltip: 'Sync Node',
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Clinic inventory node & active session
        Row(
          children: [
            const Text(
              'CLINICAL INVENTORY NODE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '/',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Active Session',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Main facility title
        const Text(
          'PHC Rampur',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),

        // Secondary location info
        const Text(
          'Mandal Warangal • Sector 4 Supply Node',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
