import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/confidence_gauge.dart';
import '../../shared/models/transfer_directive.dart';
import '../../services/api_service.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  int _activeTab = 0; // 0: Pending, 1: Approved History
  late List<TransferDirective> _directives;
  final List<TransferDirective> _approvedDirectives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _directives = TransferDirective.getInitialMockData();
    _loadDirectivesFromApi();
  }

  Future<void> _loadDirectivesFromApi() async {
    setState(() => _isLoading = true);
    final rawData = await ApiService.fetchTransferDirectives();
    if (rawData.isNotEmpty) {
      final loadedPending = <TransferDirective>[];
      final loadedApproved = <TransferDirective>[];
      for (final item in rawData) {
        final dir = TransferDirective.fromJson(item);
        if (dir.isApproved) {
          loadedApproved.add(dir);
        } else {
          loadedPending.add(dir);
        }
      }
      setState(() {
        _directives = loadedPending;
        _approvedDirectives.clear();
        _approvedDirectives.addAll(loadedApproved);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveDirective(TransferDirective directive) async {
    if (directive.id != null) {
      await ApiService.approveTransfer(directive.id!);
    }

    setState(() {
      _directives.removeWhere((d) => d.directiveNumber == directive.directiveNumber || d.id == directive.id);
      directive.isApproved = true;
      _approvedDirectives.insert(0, directive);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Signed & Approved ${directive.directiveNumber}'),
            ],
          ),
          backgroundColor: AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetailsDialog(TransferDirective directive) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text(
          directive.directiveNumber,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(directive.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(directive.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text('Route: ${directive.transitDetails}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Model Confidence: ${directive.confidencePercent}%', style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28.0 : 16.0,
        vertical: isDesktop ? 20.0 : 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill: REGIONAL COLD-CHAIN DISPATCH
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.primaryBlueBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, size: 6, color: AppColors.primaryBlue),
                SizedBox(width: 6),
                Text(
                  'REGIONAL COLD-CHAIN DISPATCH',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Title: Stock Redistribution
          const Text(
            'Stock Redistribution',
            style: AppTextStyles.pageHeading,
          ),
          const SizedBox(height: 2),

          // Subtitle: Directives Awaiting DMO Signature
          Text(
            '${_directives.length} Directives Awaiting DMO Signature',
            style: AppTextStyles.subtext,
          ),
          const SizedBox(height: 12),

          // Validated Logic / Rule 14-B Triaged Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validated Logic',
                      style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Rule 14-B Triaged',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sub-tabs: Pending (2) •  /  Approved History (1)
          Row(
            children: [
              _buildTab(0, 'Pending (${_directives.length})', hasRedDot: _directives.isNotEmpty),
              const SizedBox(width: 24),
              _buildTab(1, 'Approved History (${_approvedDirectives.length + 1})', hasRedDot: false),
            ],
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 14),

          // Tab contents
          if (_activeTab == 0) ...[
            if (_directives.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: const [
                    Icon(Icons.task_alt_rounded, size: 36, color: AppColors.greenDot),
                    SizedBox(height: 8),
                    Text('All transfer directives approved and dispatched!'),
                  ],
                ),
              )
            else
              ..._directives.map((dir) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildDirectiveCard(dir),
                  )),
          ] else ...[
            // Approved History Tab
            _buildApprovedHistoryItem(
              'Directive #DR-9018',
              'Amoxicillin 500mg • 2,000 Units',
              'Central Depot -> PHC Gudur',
              'Signed by DMO • Dispatched at 14:20 IST',
            ),
            ..._approvedDirectives.map((dir) => _buildApprovedHistoryItem(
                  dir.directiveNumber,
                  dir.title,
                  '${dir.originName.replaceAll('\n', ' ')} -> ${dir.targetName.replaceAll('\n', ' ')}',
                  'Signed & Approved just now',
                )),
          ],

          const SizedBox(height: 14),

          // DMO SOP Guidelines info card at bottom
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primaryBlueBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: const [
                Icon(Icons.edit_note_rounded, size: 22, color: AppColors.primaryBlue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Digital signatures execute immediate dispatch notifications to regional logistics fleet and lock inventory in source ledgers.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'DMO SOP Guidelines',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, {required bool hasRedDot}) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
              ),
            ),
            if (hasRedDot) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.redDot,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDirectiveCard(TransferDirective directive) {
    Color badgeBg = directive.isCriticalStatus ? AppColors.redBg : AppColors.amberBg;
    Color badgeBorder = directive.isCriticalStatus ? AppColors.redBorder : AppColors.amberBorder;
    Color badgeText = directive.isCriticalStatus ? AppColors.redText : AppColors.amberText;
    Color dotColor = directive.isCriticalStatus ? AppColors.redDot : AppColors.amberDot;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header line: badge + directive #
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: badgeBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 5, color: dotColor),
                    const SizedBox(width: 5),
                    Text(
                      directive.statusBadge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                directive.directiveNumber,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Expiry Risk / Season info
          Row(
            children: [
              Icon(
                directive.isCriticalStatus ? Icons.access_time_rounded : Icons.event_note_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                directive.riskInfo,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            directive.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            directive.description,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Route Flow Container (Light Blue)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryBlueBorder.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Origin Source
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ORIGIN SOURCE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            directive.originName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            directive.originSubtitle,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBlueBorder),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryBlue),
                      ),
                    ),

                    // Target
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            directive.isTargetCritical ? 'TARGET CRITICAL' : 'TARGET DESTINATION',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: directive.isTargetCritical ? AppColors.redText : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            directive.targetName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            directive.targetSubtitle,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: directive.isTargetCritical ? FontWeight.w600 : FontWeight.normal,
                              color: directive.isTargetCritical ? AppColors.redText : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.primaryBlueBorder),
                const SizedBox(height: 8),

                // Transit Corridor
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${directive.transitTypeLabel}  ',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: directive.transitDetails,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Confidence & AI Reason
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConfidenceGauge(percentage: directive.confidencePercent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          directive.confidenceTitle,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${directive.confidenceBadge}',
                          style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      directive.confidenceNote,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetailsDialog(directive),
                    icon: const Icon(Icons.visibility_outlined, size: 15, color: AppColors.textPrimary),
                    label: const Text('Review Details', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderSubtle),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _approveDirective(directive),
                    icon: const Icon(Icons.call_split_rounded, size: 15),
                    label: const Text('Approve Transfer Directive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedHistoryItem(String id, String title, String route, String status) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(route, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.greenBorder),
            ),
            child: Text(
              status,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.greenText),
            ),
          ),
        ],
      ),
    );
  }
}
