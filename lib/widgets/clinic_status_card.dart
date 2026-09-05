import 'package:flutter/material.dart';
import '../app/theme.dart';

class ClinicStatusCard extends StatelessWidget {
  final int availableBeds;
  final int totalBeds;
  final int staffOnDuty;
  final int totalStaff;

  const ClinicStatusCard({
    super.key,
    this.availableBeds = 10,
    this.totalBeds = 24,
    this.staffOnDuty = 3,
    this.totalStaff = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$availableBeds/$totalBeds Beds Available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const TextSpan(
                    text: '  •  ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: '$staffOnDuty/$totalStaff Staff on Duty',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
