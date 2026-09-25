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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userRole = AuthController().userRole.toLowerCase();
    final isDriver = userRole.contains('driver') || userRole.contains('fleet') || userRole.contains('transport');
    _directives = isDriver ? [] : TransferDirective.getInitialMockData();
    _loadDirectivesFromApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDirectivesFromApi({String? query}) async {
    setState(() => _isLoading = true);
    final userRole = AuthController().userRole.toLowerCase();
    final isAdmin = userRole.contains('admin') || userRole.contains('district') || userRole.contains('dmo');
    final isDriver = userRole.contains('driver') || userRole.contains('fleet') || userRole.contains('transport');
    final userPhcId = AuthController().phcId;
    final searchQuery = query ?? _searchController.text.trim();

    final rawData = await ApiService.fetchTransferDirectives(
      phcId: (isAdmin || isDriver) ? null : (userPhcId.isNotEmpty ? userPhcId : null),
      search: searchQuery.isNotEmpty ? searchQuery : null,
    );

    if (rawData.isNotEmpty) {
      final loadedPending = <TransferDirective>[];
      final loadedApproved = <TransferDirective>[];
      for (final item in rawData) {
        final dir = TransferDirective.fromJson(item);
        if (!isAdmin && !isDriver && userPhcId.isNotEmpty) {
          final isRelevant = dir.originName.contains(userPhcId) ||
              dir.targetName.contains(userPhcId) ||
              item['source_phc_id'] == userPhcId ||
              item['target_phc_id'] == userPhcId;
          if (!isRelevant) continue;
        }

        if (dir.isApproved) {
          loadedApproved.add(dir);
        } else if (!isDriver) {
          // Drivers only see assigned active deliveries, not unapproved DMO proposals
          loadedPending.add(dir);
        }
      }
      if (!mounted) return;
      setState(() {
        _directives = loadedPending;
        _approvedDirectives.clear();
        _approvedDirectives.addAll(loadedApproved);
        if (isDriver && _approvedDirectives.isEmpty) {
          _populateDriverMockAssignedDeliveries();
        }
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _directives = isDriver ? [] : TransferDirective.getInitialMockData();
        _approvedDirectives.clear();
        if (isDriver) {
          _populateDriverMockAssignedDeliveries();
        }
        _isLoading = false;
      });
    }
  }

  void _populateDriverMockAssignedDeliveries() {
    final driverName = AuthController().userName.isNotEmpty ? AuthController().userName : 'Testing Driver';
    _approvedDirectives.addAll([
      TransferDirective(
        id: 'TR-DRV-001',
        directiveNumber: 'Directive #TR-DRV-001',
        statusBadge: '📥 New Assignment (Pending Acceptance)',
        isCriticalStatus: true,
        riskInfo: 'Assigned by DMO: Urgent Dispatch',
        title: 'Anti-Rabies Serum (1000 IU) • 45 Vials',
        description: 'Assigned cold-chain delivery corridor.',
        originName: 'CHC Narsampet',
        originSubtitle: 'Surplus Reserve',
        targetName: 'PHC Gudur',
        targetSubtitle: 'Critical Stock Deficit',
        isTargetCritical: true,
        transitDetails: '18.4 km • ETA: 25 mins • Cold Van #TS-09-EV-4421',
        transitTypeLabel: 'Assigned Corridor',
        confidencePercent: 96,
        confidenceTitle: 'DMO Assignment',
        confidenceBadge: 'Assigned to Fleet',
        confidenceNote: 'Driver route optimized via OSRM.',
        quantity: 45,
        isApproved: true,
        status: 'approved',
        driverName: driverName,
        vehicleNumber: 'TS-09-EV-4421',
      ),
      TransferDirective(
        id: 'TR-DRV-002',
        directiveNumber: 'Directive #TR-DRV-002',
        statusBadge: '🚚 In-Transit (OTP Handover Active)',
        isCriticalStatus: false,
        riskInfo: 'Cold Storage: +4.2°C Nominal',
        title: 'ORS Sachets • 600 Packs',
        description: 'In-transit stock delivery.',
        originName: 'Central Depot',
        originSubtitle: 'Hub Stock',
        targetName: 'PHC Rampur',
        targetSubtitle: 'Buffer Replenishment',
        isTargetCritical: false,
        transitDetails: '42.0 km • ETA: 40 mins • Cold Van #TS-09-EV-4421',
        transitTypeLabel: 'Assigned Corridor',
        confidencePercent: 92,
        confidenceTitle: 'In-Transit Shipment',
        confidenceBadge: 'Accepted & En-Route',
        confidenceNote: 'En-route delivery with active cold storage monitoring.',
        quantity: 600,
        isApproved: true,
        status: 'in_transit',
        driverName: driverName,
        vehicleNumber: 'TS-09-EV-4421',
        handoverOtp: '8492',
      ),
    ]);
  }

  void _simulateNewDmoAssignment() {
    final driverName = AuthController().userName.isNotEmpty ? AuthController().userName : 'Testing Driver';
    final newId = 'TR-DRV-00${_approvedDirectives.length + 1}';
    final newDirective = TransferDirective(
      id: newId,
      directiveNumber: 'Directive #$newId',
      statusBadge: '📥 New Assignment (Pending Acceptance)',
      isCriticalStatus: true,
      riskInfo: 'Assigned by DMO: Urgent Dispatch',
      title: 'Paracetamol 650mg • 1,200 Tablets',
      description: 'Preemptive stock redistribution assigned by DMO.',
      originName: 'CHC Warangal Central',
      originSubtitle: 'Surplus Reserve',
      targetName: 'PHC Geesugonda',
      targetSubtitle: 'Seasonal Outbreak Deficit',
      isTargetCritical: true,
      transitDetails: '14.2 km • ETA: 20 mins • Cold Van #TS-09-EV-4421',
      transitTypeLabel: 'Assigned Corridor',
      confidencePercent: 95,
      confidenceTitle: 'DMO Assignment',
      confidenceBadge: 'Assigned to Fleet',
      confidenceNote: 'Driver route assigned by District Medical Officer.',
      quantity: 1200,
      isApproved: true,
      status: 'approved',
      driverName: driverName,
      vehicleNumber: 'TS-09-EV-4421',
    );
    setState(() {
      _approvedDirectives.insert(0, newDirective);
      _activeTab = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📥 New Delivery Assignment from DMO received! Review under New Assignments tab.'),
        backgroundColor: Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _acceptDeliveryAssignment(TransferDirective directive) async {
    if (directive.id != null && directive.driverId != null) {
      await ApiService.pickupTransfer(transferId: directive.id!, driverId: directive.driverId!);
    }
    final otp = directive.handoverOtp ?? '8492';
    setState(() {
      directive.status = 'in_transit';
      directive.handoverOtp = otp;
      _activeTab = 1;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text('Delivery Accepted & Route Started!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You accepted ${directive.directiveNumber} from ${directive.originName.replaceAll("\n", " ")} to ${directive.targetName.replaceAll("\n", " ")}.'),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    const Text('SECURE RECIPIENT HANDOVER OTP:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
                    const SizedBox(height: 4),
                    Text(otp, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.black87)),
                    const SizedBox(height: 2),
                    const Text('Provide this OTP to destination PHC staff upon arrival.', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              child: const Text('OK, Start Navigation'),
            ),
          ],
        ),
      );
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
      directive.status = 'approved';
      _approvedDirectives.insert(0, directive);
      _activeTab = 1; // Auto-switch to Approved & En Route Logistics tab
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

      // Immediately open Driver Assignment dialog for the approved directive
      _showAssignDriverDialog(directive);
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

  void _showAssignDriverDialog(TransferDirective directive) async {
    final drivers = await ApiService.fetchDrivers();
    if (!mounted) return;

    if (drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No drivers available in fleet currently.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: const [
            Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB), size: 22),
            SizedBox(width: 8),
            Text('Assign Transport Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Directive: ${directive.directiveNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              const SizedBox(height: 4),
              Text('Route: ${directive.originName.replaceAll('\n', ' ')} ➔ ${directive.targetName.replaceAll('\n', ' ')}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              const Text('Select Available Driver:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...drivers.map((drv) {
                final dName = drv['name'] ?? 'Driver';
                final vType = drv['vehicle_type'] ?? 'Cold Van';
                final vNum = drv['vehicle_number'] ?? 'TS-03';
                final dPhone = drv['phone'] ?? '';
                final dId = drv['driver_id'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                      ),
                      title: Text('$dName ($vNum)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: Text('$vType • $dPhone', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: () async {
                          Navigator.of(dialogCtx).pop();
                          if (directive.id != null) {
                            final res = await ApiService.assignDriver(transferId: directive.id!, driverId: dId);
                            if (res['success'] == true) {
                              setState(() {
                                directive.driverId = dId;
                                directive.driverName = dName;
                                directive.vehicleNumber = vNum;
                                directive.driverPhone = dPhone;
                                directive.status = 'approved';
                                directive.isApproved = true;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Driver $dName ($vNum) assigned to ${directive.directiveNumber}! Loading stock...')),
                                );
                                // Automatically trigger pickup & OTP code generation modal
                                _pickupStockDriver(directive);
                              }
                            }
                          }
                        },
                        child: const Text('Assign', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _pickupStockDriver(TransferDirective directive) async {
    if (directive.id == null || directive.driverId == null) {
      _showAssignDriverDialog(directive);
      return;
    }
    final res = await ApiService.pickupTransfer(transferId: directive.id!, driverId: directive.driverId!);
    if (res['success'] == true) {
      final otp = res['handover_otp'] ?? '8492';
      setState(() {
        directive.status = 'in_transit';
        directive.handoverOtp = otp;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 22),
                SizedBox(width: 8),
                Text('Stock Picked Up & In-Transit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Driver ${directive.driverName ?? "Driver"} has loaded stock from ${directive.originName.replaceAll("\n", " ")}.'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    children: [
                      const Text('SECURE HANDOVER OTP CODE:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
                      const SizedBox(height: 4),
                      Text(otp, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.black87)),
                      const SizedBox(height: 2),
                      const Text('Give this OTP code to recipient PHC staff upon arrival.', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK, Track Delivery'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showOtpDialog(TransferDirective directive) {
    final otp = directive.handoverOtp ?? '8492';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Text('Secure Handover OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Directive: ${directive.directiveNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
            const SizedBox(height: 4),
            Text('Driver: ${directive.driverName ?? "Assigned Fleet Driver"} (${directive.vehicleNumber ?? "Cold Van"})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text('HANDOVER VERIFICATION CODE:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
                  const SizedBox(height: 6),
                  Text(otp, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 6, color: Colors.black87)),
                  const SizedBox(height: 4),
                  const Text('Share this code with destination facility staff upon arrival to complete delivery.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showVerifyDeliveryDialog(directive);
            },
            icon: const Icon(Icons.verified_rounded, size: 16),
            label: const Text('Enter OTP & Verify'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showVerifyDeliveryDialog(TransferDirective directive) {
    final otpController = TextEditingController(text: directive.handoverOtp ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: Colors.green, size: 22),
            SizedBox(width: 8),
            Text('Verify & Complete Delivery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Directive: ${directive.directiveNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
            const SizedBox(height: 4),
            Text('Delivering: ${directive.title}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            const Text('Enter 4-Digit Handover OTP:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Handover OTP Code',
                hintText: 'e.g. 8492',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              if (directive.id != null) {
                final res = await ApiService.verifyDelivery(transferId: directive.id!, otpCode: otpController.text.trim());
                if (res['success'] == true) {
                  setState(() {
                    directive.status = 'completed';
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Delivery completed! Stock inventory balances updated for ${directive.targetName.replaceAll("\n", " ")}.')),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
            label: const Text('Confirm Delivery & Update Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final userRole = AuthController().userRole.toLowerCase();
    final isDriver = userRole.contains('driver') || userRole.contains('fleet') || userRole.contains('transport');

    final assignedPending = _approvedDirectives.where((d) => d.status == 'approved').toList();
    final inTransit = _approvedDirectives.where((d) => d.status == 'in_transit').toList();
    final completedShipments = _approvedDirectives.where((d) => d.status == 'completed').toList();
    final activeShipments = _approvedDirectives.where((d) => d.status != 'completed').toList();

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
              Expanded(
                child: Column(
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
                            children: [
                              const Icon(Icons.circle, size: 5, color: Color(0xFF2563EB)),
                              const SizedBox(width: 5),
                              Text(
                                isDriver ? '🚚 FLEET LOGISTICS & COLD-CHAIN DISPATCH' : 'REGIONAL COLD-CHAIN DISPATCH',
                                style: const TextStyle(
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
                    Text(
                      isDriver ? 'My Assigned Fleet Deliveries' : 'Stock Redistribution',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDriver
                          ? '${assignedPending.length} New Assignment(s) • ${inTransit.length} In-Transit Shipment(s)'
                          : '${_directives.length} Directives Awaiting DMO Signature',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
                  children: [
                    Icon(isDriver ? Icons.thermostat_rounded : Icons.verified_user_outlined, size: 18, color: const Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDriver ? 'Fleet Telemetry' : 'Validated Logic',
                          style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                        ),
                        Text(
                          isDriver ? 'GPS & Cold (+4.2°C)' : 'Rule 14-B Triaged',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Search Bar ─────────────────────────────────────
          Container(
            height: 44,
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
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                _loadDirectivesFromApi(query: val.trim());
              },
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: isDriver
                    ? 'Search assigned deliveries by PHC, medicine, or OTP code...'
                    : 'Search logistics directives by PHC, medicine, ID or status...',
                hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _loadDirectivesFromApi(query: '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Horizontal Filter Sub-tabs (Clean pill tabs) ───────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: isDriver
                  ? [
                      _buildTab(0, '📥 New Assignments (${assignedPending.length})', hasRedDot: assignedPending.isNotEmpty),
                      const SizedBox(width: 8),
                      _buildTab(1, '🚚 Active In-Transit (${inTransit.length})', hasRedDot: inTransit.isNotEmpty),
                      const SizedBox(width: 8),
                      _buildTab(2, '✅ Completed History (${completedShipments.length})', hasRedDot: false),
                    ]
                  : [
                      _buildTab(0, '⏳ Pending Approvals (${_directives.length})', hasRedDot: _directives.isNotEmpty),
                      const SizedBox(width: 8),
                      _buildTab(1, '🚚 En-Route Logistics (${activeShipments.length})', hasRedDot: false),
                      const SizedBox(width: 8),
                      _buildTab(2, '✅ Delivered & Audited (${completedShipments.length + 1})', hasRedDot: false),
                    ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Tab Contents ─────────────────────────────────────────────────
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (isDriver) ...[
            if (_activeTab == 0) ...[
              if (assignedPending.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF2563EB)),
                      const SizedBox(height: 10),
                      const Text(
                        'No new delivery assignments from DMO',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'When a District Officer assigns a stock transfer to your fleet ID, it will appear here for your acceptance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _simulateNewDmoAssignment,
                        icon: const Icon(Icons.add_task_rounded, size: 16),
                        label: const Text('🧪 Dispatch Demo DMO Assignment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...assignedPending.map((dir) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildDirectiveCard(dir),
                    )),
            ] else if (_activeTab == 1) ...[
              if (inTransit.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 36, color: Color(0xFF2563EB)),
                      SizedBox(height: 8),
                      Text('No active shipments in-transit.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Accept a delivery assignment from the New Assignments tab to start your route.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                ...inTransit.map((dir) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildDirectiveCard(dir),
                    )),
            ] else ...[
              if (completedShipments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 36, color: Colors.green),
                      SizedBox(height: 8),
                      Text('No completed handovers recorded yet.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              else
                ...completedShipments.map((dir) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildDirectiveCard(dir),
                    )),
            ],
          ] else if (_activeTab == 0) ...[
            if (_directives.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.task_alt_rounded, size: 40, color: AppColors.greenDot),
                    SizedBox(height: 10),
                    Text(
                      'All transfer directives signed & dispatched!',
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
          ] else if (_activeTab == 1) ...[
            if (activeShipments.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 36, color: Color(0xFF2563EB)),
                    SizedBox(height: 8),
                    Text('No active en-route shipments right now.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Approve a directive from Pending tab to assign a driver & dispatch OTP.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              ...activeShipments.map((dir) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildDirectiveCard(dir),
                  )),
          ] else ...[
            _buildApprovedHistoryItem(
              'Directive #DR-9018',
              'Amoxicillin 500mg • 2,000 Units',
              'Central Depot -> PHC Gudur',
              'OTP Verified • Dispatched at 14:20 IST',
            ),
            ...completedShipments.map((dir) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildDirectiveCard(dir),
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
              children: [
                Icon(isDriver ? Icons.thermostat_rounded : Icons.edit_note_rounded, size: 22, color: const Color(0xFF2563EB)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isDriver
                        ? 'Real-time temperature monitoring active (+4.2°C). Present 4-digit handover OTP code to recipient PHC staff to complete delivery.'
                        : 'Digital signatures execute immediate dispatch notifications to regional logistics fleet and lock inventory in source ledgers.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isDriver ? 'Fleet Delivery SOP' : 'DMO SOP Guidelines',
                  style: const TextStyle(
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

          // Description (Omitted for clean mobile manager view)
          const SizedBox(height: 8),

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConfidenceGauge(percentage: directive.confidencePercent),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      directive.confidenceTitle,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '• ${directive.confidenceBadge}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
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
              final isDriver = userRole.contains('driver') || userRole.contains('fleet') || userRole.contains('transport');

              if (directive.status == 'completed') {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '✅ Delivery Completed & Inventory Ledger Updated (Driver: ${directive.driverName ?? "Assigned Fleet"})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (directive.status == 'in_transit') {
                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _showOtpDialog(directive),
                          icon: const Icon(Icons.vpn_key_rounded, size: 16, color: Colors.orange),
                          label: Text('🔐 Handover OTP: ${directive.handoverOtp ?? "8492"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orange, width: 1.5),
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
                          onPressed: () => _showVerifyDeliveryDialog(directive),
                          icon: const Icon(Icons.verified_rounded, size: 16),
                          label: const Text('Verify & Complete Delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (directive.isApproved) {
                if (isDriver) {
                  return Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () => _acceptDeliveryAssignment(directive),
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('✅ ACCEPT DELIVERY & START ROUTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
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
                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _showAssignDriverDialog(directive),
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 16, color: Color(0xFF2563EB)),
                          label: Text(directive.driverName != null ? '👤 ${directive.driverName}' : '👤 Assign Driver', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2563EB)),
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
                          onPressed: () => _pickupStockDriver(directive),
                          icon: const Icon(Icons.inventory_2_outlined, size: 16),
                          label: const Text('Confirm Pickup ➔ OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (isAdmin) {
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
                          label: const Text('Approve Directive', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                          label: const Text('Call District Hotline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
