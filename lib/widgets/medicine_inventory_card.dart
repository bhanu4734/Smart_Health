import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/medicine_inventory_item.dart';
import 'action_button.dart';
import 'custom_dispense_dialog.dart';

class MedicineInventoryCard extends StatefulWidget {
  final MedicineInventoryItem item;
  final ValueChanged<int> onDispense;

  const MedicineInventoryCard({
    super.key,
    required this.item,
    required this.onDispense,
  });

  @override
  State<MedicineInventoryCard> createState() => _MedicineInventoryCardState();
}

class _MedicineInventoryCardState extends State<MedicineInventoryCard> {
  bool _isExpanded = false;

  (Color bg, Color border, Color text) _getCategoryColors(String category) {
    switch (category.toUpperCase()) {
      case 'ANTIBIOTIC':
        return (
          AppColors.tagAntibioticBg,
          AppColors.tagAntibioticBorder,
          AppColors.tagAntibioticText,
        );
      case 'REHYDRATION':
        return (
          AppColors.tagRehydrationBg,
          AppColors.tagRehydrationBorder,
          AppColors.tagRehydrationText,
        );
      case 'ANALGESIC':
        return (
          AppColors.tagAnalgesicBg,
          AppColors.tagAnalgesicBorder,
          AppColors.tagAnalgesicText,
        );
      case 'EMERGENCY':
        return (
          AppColors.tagEmergencyBg,
          AppColors.tagEmergencyBorder,
          AppColors.tagEmergencyText,
        );
      default:
        return (
          AppColors.tagAntibioticBg,
          AppColors.tagAntibioticBorder,
          AppColors.tagAntibioticText,
        );
    }
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => CustomDispenseDialog(
        item: widget.item,
        onConfirm: widget.onDispense,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final (catBg, catBorder, catText) = _getCategoryColors(item.category);
    final isCritical = item.priority == 'Triage' || item.availableUnits < 20;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? AppColors.redBadgeBorder : AppColors.borderCard,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge + ID
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: catBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: catBorder, width: 0.8),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: catText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ID: ${item.id}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Medicine Name
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 1),

          // Subtitle / Form description
          Text(
            item.formDescription,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),

          // Units count & Safe Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${item.availableUnits}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'units',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCritical ? AppColors.redBadgeBg : AppColors.greenBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCritical ? AppColors.redBadgeBorder : AppColors.greenBadgeBorder,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isCritical ? AppColors.redText : AppColors.greenDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.safetyStatus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isCritical ? AppColors.redText : AppColors.greenText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Expandable Details trigger
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.subCardBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Batch', item.batchNumber ?? 'N/A'),
                    const SizedBox(height: 2),
                    _buildDetailRow('Expiry', item.expiryDate ?? 'N/A'),
                    const SizedBox(height: 2),
                    _buildDetailRow('Storage', item.storage ?? 'Standard hospital store'),
                  ],
                ),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),

          // Action bottom bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Ready for dispense',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionButton(
                    label: '-1',
                    onPressed: item.availableUnits >= 1 ? () => widget.onDispense(1) : () {},
                  ),
                  const SizedBox(width: 6),
                  ActionButton(
                    label: '-5',
                    onPressed: item.availableUnits >= 5 ? () => widget.onDispense(5) : () {},
                  ),
                  const SizedBox(width: 6),
                  ActionButton(
                    label: 'Custom',
                    isPrimary: true,
                    onPressed: () => _showCustomDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
