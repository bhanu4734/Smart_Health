import 'package:flutter/material.dart';
import '../app/theme.dart';

class InventorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onScanBarcode;

  const InventorySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Search medicine or scan barcode',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              splashRadius: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          InkWell(
            onTap: onScanBarcode,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
