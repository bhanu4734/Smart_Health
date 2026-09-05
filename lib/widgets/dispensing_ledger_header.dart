import 'package:flutter/material.dart';
import '../app/theme.dart';

class DispensingLedgerHeader extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const DispensingLedgerHeader({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;

        Widget titles = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Dispensing Ledger',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Real-time unit decrement and\nimmediate batch validation',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.25,
              ),
            ),
          ],
        );

        Widget prioritySelector = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Priority: ',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPriorityOption('Standard'),
                    Container(height: 1, color: AppColors.borderLight),
                    _buildPriorityOption('Triage'),
                  ],
                ),
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titles,
              const SizedBox(height: 8),
              prioritySelector,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titles),
            const SizedBox(width: 8),
            prioritySelector,
          ],
        );
      },
    );
  }

  Widget _buildPriorityOption(String option) {
    final isSelected = selectedPriority == option;
    return InkWell(
      onTap: () => onPriorityChanged(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        color: isSelected ? AppColors.purpleLight.withValues(alpha: 0.6) : Colors.transparent,
        child: Text(
          option,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.purpleAccent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
