import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/confidence_gauge.dart';
import '../../shared/models/transfer_directive.dart';
import '../../services/api_service.dart';
import '../auth/controllers/auth_controller.dart';

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
      if (!mounted) return;
      setState(() {
        _directives = loadedPending;
        _approvedDirectives.clear();
        _approvedDirectives.addAll(loadedApproved);
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveDirective(TransferDirective directive, {int? overrideQuantity}) async {
    final finalQty = overrideQuantity ?? directive.quantity;
    if (directive.id != null) {
      await ApiService.approveTransfer(directive.id!, overrideQuantity: finalQty);
    }

    setState(() {
      _directives.removeWhere((d) => d.directiveNumber == directive.directiveNumber || d.id == directive.id);
      directive.quantity = finalQty;
      if (directive.title.contains('•')) {
        final medName = directive.title.split('•').first.trim();
        directive.title = '$medName • $finalQty Units';
      }
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
              Expanded(child: Text('Signed & Approved ${directive.directiveNumber} ($finalQty units dispatched)')),
            ],
          ),
          backgroundColor: const Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditQuantityAndApproveDialog(TransferDirective directive) {
    final controller = TextEditingController(text: directive.quantity.toString());
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 22),
            SizedBox(width: 8),
            Text(
              'Adjust Transfer Quantity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Directive: ${directive.directiveNumber}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 4),
            Text(
              'Route: ${directive.originName.replaceAll('\n', ' ')} ➔ ${directive.targetName.replaceAll('\n', ' ')}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            const Text(
              'Count of Units to Re-arrange:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Unit Count',
                suffixText: 'units',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                ActionChip(label: const Text('250 units'), onPressed: () => controller.text = '250'),
                ActionChip(label: const Text('500 units'), onPressed: () => controller.text = '500'),
                ActionChip(label: const Text('1000 units'), onPressed: () => controller.text = '1000'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final newQty = int.tryParse(controller.text.trim()) ?? directive.quantity;
              Navigator.of(dialogCtx).pop();
              _approveDirective(directive, overrideQuantity: newQty);
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
            label: const Text('Confirm & Sign Directive'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(TransferDirective directive) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
            Text('Model Confidence: ${directive.confidencePercent}%', style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
            const SizedBox(height: 12),
            Text('Allocated Quantity: ${directive.quantity} Units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32.0 : 16.0,
        vertical: isDesktop ? 24.0 : 14.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Row ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, size: 5, color: Color(0xFF2563EB)),
                            SizedBox(width: 5),
                            Text(
                              'REGIONAL COLD-CHAIN DISPATCH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stock Redistribution',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_directives.length} Directives Awaiting DMO Signature',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              // Validated Logic Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified_user_outlined, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Validated Logic',
                          style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                        ),
                        Text(
                          'Rule 14-B Triaged',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Horizontal Filter Sub-tabs (Clean pill tabs) ───────────────────
          Row(
            children: [
              _buildTab(0, 'Pending (${_directives.length})', hasRedDot: _directives.isNotEmpty),
              const SizedBox(width: 10),
              _buildTab(1, 'Approved History (${_approvedDirectives.length + 1})', hasRedDot: false),
            ],
          ),
          const SizedBox(height: 18),

          // ── Tab Contents ─────────────────────────────────────────────────
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (_activeTab == 0) ...[
            if (_directives.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.task_alt_rounded, size: 40, color: AppColors.greenDot),
                    SizedBox(height: 10),
                    Text(
                      'All transfer directives approved and dispatched!',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
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

          const SizedBox(height: 18),

          // ── Bottom SOP Guidelines Card ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.edit_note_rounded, size: 22, color: Color(0xFF2563EB)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Digital signatures execute immediate dispatch notifications to regional logistics fleet and lock inventory in source ledgers.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'DMO SOP Guidelines',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── SUB-TAB PILL BUTTON ──────────────────────────────────────────────────
  Widget _buildTab(int index, String label, {required bool hasRedDot}) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.borderCard : AppColors.borderSubtle,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                letterSpacing: -0.1,
              ),
            ),
            if (hasRedDot) ...[
              const SizedBox(width: 6),
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

  // ── DIRECTIVE CARD ───────────────────────────────────────────────────────
  Widget _buildDirectiveCard(TransferDirective directive) {
    Color badgeBg = directive.isCriticalStatus ? AppColors.redBg : AppColors.amberBg;
    Color badgeBorder = directive.isCriticalStatus ? AppColors.redBorder : AppColors.amberBorder;
    Color badgeText = directive.isCriticalStatus ? AppColors.redText : AppColors.amberText;
    Color dotColor = directive.isCriticalStatus ? AppColors.redDot : AppColors.amberDot;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status badge & Directive ID
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
                        fontSize: 10.5,
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
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Expiry / Season info
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
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            directive.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            directive.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Route Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Origin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ORIGIN SOURCE',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            directive.originName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            directive.originSubtitle,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Direction Arrow
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
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
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: directive.isTargetCritical ? AppColors.redText : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            directive.targetName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            directive.targetSubtitle,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11,
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
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 8),

                // Transit corridor info
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${directive.transitTypeLabel}  ',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: directive.transitDetails,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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

          // Confidence & Reason
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConfidenceGauge(percentage: directive.confidencePercent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          directive.confidenceTitle,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${directive.confidenceBadge}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      directive.confidenceNote,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Builder(
            builder: (context) {
              final userRole = AuthController().userRole.toLowerCase();
              final isAdmin = userRole.contains('admin') || userRole.contains('district');

              if (isAdmin) {
                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditQuantityAndApproveDialog(directive),
                          icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF2563EB)),
                          label: const Text('Edit Unit Count', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderSubtle),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditQuantityAndApproveDialog(directive),
                          icon: const Icon(Icons.call_split_rounded, size: 16),
                          label: const Text('Approve Transfer Directive', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDetailsDialog(directive),
                          icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textPrimary),
                          label: const Text('View Status', style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderSubtle),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Calling District Officer Hotline (+91 98480 22334)...'),
                                  ],
                                ),
                                backgroundColor: Color(0xFF2563EB),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                          label: const Text('📞 Call District Hotline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedHistoryItem(String id, String title, String route, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                const SizedBox(height: 3),
                Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(route, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.greenBorder),
            ),
            child: Text(
              status,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.greenText),
            ),
          ),
        ],
      ),
    );
  }
}
