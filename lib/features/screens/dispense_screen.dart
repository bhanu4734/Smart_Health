import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../shared/models/medicine_item.dart';
import '../../services/api_service.dart';
import '../auth/controllers/auth_controller.dart';

class DispenseScreen extends StatefulWidget {
  const DispenseScreen({super.key});

  @override
  State<DispenseScreen> createState() => _DispenseScreenState();
}

class _DispenseScreenState extends State<DispenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPriority = 'Standard';
  late List<MedicineItem> _items;
  int _activeTab = 0; // 0: Medicine Dispensing, 1: Facility Beds & Staff, 2: Stock Transfers
  bool _isLoading = true;
  String _currentPhcId = 'PHC-D01-01';
  final Map<String, bool> _expandedMap = {};

  // Capacity & Staff State
  int _bedCapacity = 10;
  int _occupiedBeds = 4;
  int _doctorsPresent = 2;
  int _nursesPresent = 4;
  bool _isSyncingCapacity = false;

  @override
  void initState() {
    super.initState();
    _currentPhcId = AuthController().phcId;
    _phcName = AuthController().phcName;
    _items = MedicineItem.getInitialMockData();
    _loadInventoryFromApi();
  }

  String _phcName = 'PHC Loddaputti';
  String _phcSub = 'Mandal Ichchapuram • Primary Care Supply Node';

  Future<void> _loadInventoryFromApi({String? search}) async {
    setState(() => _isLoading = true);
    
    // First verify available PHCs from backend
    final phcList = await ApiService.fetchPHCs();
    if (phcList.isNotEmpty) {
      final matchedPhc = phcList.firstWhere((p) => p['id'] == _currentPhcId, orElse: () => phcList.first);
      _currentPhcId = matchedPhc['id'];
      _phcName = matchedPhc['name'] ?? 'Primary Health Center';
      _phcSub = 'Mandal ${matchedPhc['mandal_name'] ?? 'Central'} • ${matchedPhc['district_name'] ?? 'District'} Supply Node';
      
      if (matchedPhc['bed_capacity'] != null) {
        _bedCapacity = matchedPhc['bed_capacity'];
        _occupiedBeds = matchedPhc['occupied_beds'] ?? 4;
        _doctorsPresent = matchedPhc['doctors_present'] ?? 2;
        _nursesPresent = matchedPhc['nurses_present'] ?? 4;
      }
    }

    final rawData = await ApiService.fetchInventoryLedger(_currentPhcId, search: search);
    if (rawData.isNotEmpty) {
      final loaded = rawData.map((j) => MedicineItem.fromJson(j)).toList();
      setState(() {
        _items = loaded;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncCapacityToCloud() async {
    setState(() => _isSyncingCapacity = true);
    final res = await ApiService.updateCapacityStatus(
      phcId: _currentPhcId,
      occupiedBeds: _occupiedBeds,
      doctorsPresent: _doctorsPresent,
      nursesPresent: _nursesPresent,
    );
    if (!mounted) return;
    setState(() => _isSyncingCapacity = false);

    final msg = res['message'] ?? 'Capacity & Attendance synced successfully';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.purpleAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleDispense(MedicineItem item, int count) {
    if (item.hasRedBorder) {
      _showPatientCaseIdModal(item, count);
      return;
    }
    _applyDispense(item, count);
  }

  Future<void> _applyDispense(MedicineItem item, int count) async {
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        final newUnits = (_items[index].availableUnits - count).clamp(0, 999999);
        _items[index] = _items[index].copyWith(availableUnits: newUnits);
      }
    });

    final res = await ApiService.dispenseMedicine(
      phcId: _currentPhcId,
      medicineId: item.id,
      quantity: count,
    );

    final msg = res['message'] ?? 'Dispensed $count ${item.unitLabel} of ${item.name}';

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPatientCaseIdModal(MedicineItem item, int count) {
    final caseIdController = TextEditingController(text: 'CAS-2026-0941');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.redText, size: 22),
            SizedBox(width: 8),
            Text(
              'Patient Case ID Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispensing emergency biologic ${item.name} requires recorded patient case identification for cold-chain audit trails.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: caseIdController,
              decoration: const InputDecoration(
                labelText: 'Patient Case ID / Token',
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _applyDispense(item, count);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify & Dispense'),
          ),
        ],
      ),
    );
  }

  void _showCustomDispenseDialog(MedicineItem item) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text(
          'Custom Dispense: ${item.name}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available stock: ${item.availableUnits} ${item.unitLabel}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter units to dispense',
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
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                Navigator.of(dialogCtx).pop();
                _handleDispense(item, val);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purpleAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  List<MedicineItem> get _filteredItems {
    return _items.where((i) {
      final matchesSearch = _searchQuery.isEmpty ||
          i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPriority = _selectedPriority.isEmpty ||
          i.priority.toLowerCase() == _selectedPriority.toLowerCase();
      return matchesSearch && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;
    final hPad = isDesktop ? 28.0 : 16.0;
    final vPad = isDesktop ? 20.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CLINICAL INVENTORY NODE / Active Session
          Row(
            children: const [
              Text(
                'CLINICAL INVENTORY NODE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 6),
              Text('/', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              SizedBox(width: 6),
              Text(
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
          const SizedBox(height: 4),

          // PHC Rampur
          Text(
            _phcName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),

          // Subtitle
          Text(
            _phcSub,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Executive Summary KPI Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.redDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Stock Alerts', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text('${_items.where((i) => i.hasRedBorder).length} Low', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.redText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.king_bed_outlined, size: 20, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Beds Available', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text('${(_bedCapacity - _occupiedBeds).clamp(0, 99)} / $_bedCapacity', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 20, color: AppColors.purpleAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Staff On Duty', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Text('${_doctorsPresent + _nursesPresent} Active', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Section Tabs Navigation
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? AppColors.purpleLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication_outlined, size: 16, color: _activeTab == 0 ? AppColors.purpleAccent : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('Dispense & Stock', style: TextStyle(fontSize: 12, fontWeight: _activeTab == 0 ? FontWeight.w700 : FontWeight.w500, color: _activeTab == 0 ? AppColors.purpleAccent : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? AppColors.purpleLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.king_bed_outlined, size: 16, color: _activeTab == 1 ? AppColors.purpleAccent : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('Facility Beds & Staff', style: TextStyle(fontSize: 12, fontWeight: _activeTab == 1 ? FontWeight.w700 : FontWeight.w500, color: _activeTab == 1 ? AppColors.purpleAccent : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // TAB CONTENT VIEWS
          if (_activeTab == 1)
            _buildFacilityCapacityTab()
          else ...[

          // Search Bar
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Search medicine or scan barcode',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulated barcode scan: MED-8821 detected'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    setState(() {
                      _searchController.text = 'MED-8821';
                      _searchQuery = 'MED-8821';
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dispensing Ledger & Priority toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dispensing Ledger',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Priority: ',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPriorityItem('Standard'),
                          Container(height: 1, color: AppColors.borderLight),
                          _buildPriorityItem('Triage'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Medicine Cards List
          ...filtered.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMedicineCard(item),
              )),

          const SizedBox(height: 12),

          // Bottom handle and sync note
          Center(
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'PHC Cold-Chain Ledger synced 42 seconds ago',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityItem(String priority) {
    final isSelected = _selectedPriority == priority;
    return InkWell(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        color: isSelected ? AppColors.purpleLight.withValues(alpha: 0.6) : Colors.transparent,
        child: Text(
          priority,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.purpleAccent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineItem item) {
    final isExpanded = _expandedMap[item.id] ?? false;

    Color catBg;
    Color catBorder;
    Color catText;

    switch (item.statusType) {
      case StockStatusType.safe:
        catBg = AppColors.primaryBlueLight;
        catBorder = AppColors.primaryBlueBorder;
        catText = AppColors.primaryBlue;
        break;
      case StockStatusType.warning:
        catBg = AppColors.amberBg;
        catBorder = AppColors.amberBorder;
        catText = AppColors.amberText;
        break;
      case StockStatusType.critical:
        catBg = AppColors.redBg;
        catBorder = AppColors.redBorder;
        catText = AppColors.redText;
        break;
    }

    Color statusBadgeBg;
    Color statusBadgeBorder;
    Color statusBadgeText;
    Color statusDotColor;

    switch (item.statusType) {
      case StockStatusType.safe:
        statusBadgeBg = AppColors.greenBg;
        statusBadgeBorder = AppColors.greenBorder;
        statusBadgeText = AppColors.greenText;
        statusDotColor = AppColors.greenDot;
        break;
      case StockStatusType.warning:
        statusBadgeBg = AppColors.amberBg;
        statusBadgeBorder = AppColors.amberBorder;
        statusBadgeText = AppColors.amberText;
        statusDotColor = AppColors.amberDot;
        break;
      case StockStatusType.critical:
        statusBadgeBg = AppColors.redBg;
        statusBadgeBorder = AppColors.redBorder;
        statusBadgeText = AppColors.redText;
        statusDotColor = AppColors.redDot;
        break;
    }

    return AppCard(
      leftAccentColor: item.hasRedBorder ? AppColors.redDark : null,
      leftAccentWidth: 4.0,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag & ID
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
                  item.category,
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

          // Name
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

          // Form description
          Text(
            item.formDescription,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Quantity & Safe/Warning/Critical badge
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
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: item.hasRedBorder ? AppColors.redDark : AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.unitLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusBadgeBorder, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.statusBadgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusBadgeText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Details v
          InkWell(
            onTap: () {
              setState(() {
                _expandedMap[item.id] = !isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Details',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Batch', item.batchNumber ?? 'AMX-2026'),
                  const SizedBox(height: 2),
                  _buildDetailRow('Expiry', item.expiryDate ?? '11/2027'),
                  const SizedBox(height: 2),
                  _buildDetailRow('Storage', item.storage ?? 'Room temperature below 25°C'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (item.hasRedBorder)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text(
                        '*',
                        style: TextStyle(color: AppColors.redText, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Text(
                    item.footerText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: item.hasRedBorder ? AppColors.redText : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: '-1',
                    variant: AppButtonVariant.compact,
                    onPressed: item.availableUnits >= 1 ? () => _handleDispense(item, 1) : null,
                  ),
                  const SizedBox(width: 6),
                  AppButton(
                    label: '-5',
                    variant: AppButtonVariant.compact,
                    onPressed: item.availableUnits >= 5 ? () => _handleDispense(item, 5) : null,
                  ),
                  const SizedBox(width: 6),
                  AppButton(
                    label: 'Custom',
                    variant: AppButtonVariant.compact,
                    onPressed: () => _showCustomDispenseDialog(item),
                  ),
                ],
              ),
            ],
          ),
          if (item.hasRedBorder || item.availableUnits < 200) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton.icon(
                onPressed: () => _handleEmergencyRequisition(item),
                icon: const Icon(Icons.send_rounded, size: 14, color: AppColors.redText),
                label: const Text(
                  '🚨 Notify District Portal Queue (Request Emergency Stock)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.redText),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.redDark, width: 1.2),
                  backgroundColor: AppColors.redDark.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleEmergencyRequisition(MedicineItem item) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 10),
            Text('Sending emergency requisition for ${item.name} to District Queue...'),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );

    final res = await ApiService.requestEmergencyStock(
      phcId: _currentPhcId,
      medicineId: item.id,
      requestedQuantity: 500,
      reason: '🚨 LOW STOCK ALERT at $_phcName: ${item.name} cover remaining critical (${item.statusBadgeText}).',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final msg = res['message'] ?? 'Requisition pushed to District Queue!';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: res['success'] == true ? AppColors.purpleAccent : Colors.redAccent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
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
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 10, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityCapacityTab() {
    final availableBeds = (_bedCapacity - _occupiedBeds).clamp(0, 99);
    final occupancyPct = (_occupiedBeds / (_bedCapacity <= 0 ? 1 : _bedCapacity)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bed Occupancy Section
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.king_bed_rounded, color: AppColors.primaryBlue, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Hospital Bed Occupancy',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: availableBeds > 2 ? AppColors.greenDot.withValues(alpha: 0.12) : AppColors.redDark.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$availableBeds Beds Available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: availableBeds > 2 ? AppColors.greenText : AppColors.redText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: occupancyPct,
                  backgroundColor: AppColors.background,
                  color: occupancyPct > 0.85 ? AppColors.redDark : AppColors.primaryBlue,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Occupied Beds: $_occupiedBeds / $_bedCapacity Total',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 24, color: AppColors.textSecondary),
                        onPressed: () {
                          if (_occupiedBeds > 0) setState(() => _occupiedBeds--);
                        },
                      ),
                      Text('$_occupiedBeds', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 24, color: AppColors.primaryBlue),
                        onPressed: () {
                          if (_occupiedBeds < _bedCapacity) setState(() => _occupiedBeds++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Staff Attendance Section
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.badge_outlined, color: AppColors.purpleAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'On-Duty Personnel Tracker',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Doctors Present
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Doctors Present on Duty:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.textSecondary),
                        onPressed: () {
                          if (_doctorsPresent > 0) setState(() => _doctorsPresent--);
                        },
                      ),
                      Text('$_doctorsPresent', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.purpleAccent),
                        onPressed: () {
                          setState(() => _doctorsPresent++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 14, color: AppColors.borderSubtle),

              // Nurses Present
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nurses Present on Duty:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.textSecondary),
                        onPressed: () {
                          if (_nursesPresent > 0) setState(() => _nursesPresent--);
                        },
                      ),
                      Text('$_nursesPresent', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.purpleAccent),
                        onPressed: () {
                          setState(() => _nursesPresent++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sync Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _isSyncingCapacity ? null : _syncCapacityToCloud,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text(_isSyncingCapacity ? 'Syncing Status...' : 'Sync Attendance & Capacity to Cloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
