enum StockStatusType { safe, warning, critical }

class MedicineItem {
  final String id;
  final String category;
  final String name;
  final String formDescription;
  int availableUnits;
  final String unitLabel;
  final String statusBadgeText;
  final StockStatusType statusType;
  final String footerText;
  final bool hasRedBorder;
  final String? batchNumber;
  final String? expiryDate;
  final String? storage;
  final String priority;

  MedicineItem({
    required this.id,
    required this.category,
    required this.name,
    required this.formDescription,
    required this.availableUnits,
    this.unitLabel = 'units',
    required this.statusBadgeText,
    required this.statusType,
    required this.footerText,
    this.hasRedBorder = false,
    this.batchNumber,
    this.expiryDate,
    this.storage,
    this.priority = 'Standard',
  });

  MedicineItem copyWith({
    String? id,
    String? category,
    String? name,
    String? formDescription,
    int? availableUnits,
    String? unitLabel,
    String? statusBadgeText,
    StockStatusType? statusType,
    String? footerText,
    bool? hasRedBorder,
    String? batchNumber,
    String? expiryDate,
    String? storage,
    String? priority,
  }) {
    return MedicineItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      formDescription: formDescription ?? this.formDescription,
      availableUnits: availableUnits ?? this.availableUnits,
      unitLabel: unitLabel ?? this.unitLabel,
      statusBadgeText: statusBadgeText ?? this.statusBadgeText,
      statusType: statusType ?? this.statusType,
      footerText: footerText ?? this.footerText,
      hasRedBorder: hasRedBorder ?? this.hasRedBorder,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      storage: storage ?? this.storage,
      priority: priority ?? this.priority,
    );
  }

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    final riskStr = (json['risk_level'] ?? 'SAFE').toString().toUpperCase();
    StockStatusType statusType = StockStatusType.safe;
    if (riskStr == 'CRITICAL') {
      statusType = StockStatusType.critical;
    } else if (riskStr == 'WARNING') {
      statusType = StockStatusType.warning;
    }

    final daysBadge = json['days_cover_badge'] ?? '${json['days_remaining'] ?? 0}d cover';
    final isEmergency = (json['category'] ?? '').toString().toUpperCase().contains('EMERGENCY') ||
        (json['medicine_name'] ?? '').toString().toUpperCase().contains('RABIES') ||
        statusType == StockStatusType.critical;

    return MedicineItem(
      id: json['medicine_id'] ?? '',
      category: (json['category'] ?? 'GENERAL').toString().toUpperCase(),
      name: json['medicine_name'] ?? json['brand_name'] ?? '',
      formDescription: '${json['generic_name'] ?? json['medicine_name']} • ${json['unit'] ?? 'units'}',
      availableUnits: (json['current_stock'] as num?)?.toInt() ?? 0,
      unitLabel: json['unit'] ?? 'units',
      statusBadgeText: '${statusType == StockStatusType.critical ? 'Critical' : (statusType == StockStatusType.warning ? 'Warning' : 'Safe')} ($daysBadge)',
      statusType: statusType,
      footerText: isEmergency ? 'Requires Patient Case ID' : 'Ready for dispense',
      hasRedBorder: isEmergency,
      batchNumber: json['batch_number'] ?? 'BATCH-${json['medicine_id']}',
      expiryDate: json['expiry_date'] ?? '12/2027',
      storage: (json['category'] ?? '').toString().toLowerCase().contains('vaccine') || (json['category'] ?? '').toString().toLowerCase().contains('rabies') ? 'Cold chain 2-8°C required' : 'Store in cool dry place',
      priority: statusType == StockStatusType.critical ? 'Triage' : 'Standard',
    );
  }

  static List<MedicineItem> getInitialMockData() {
    return [
      MedicineItem(
        id: 'MED-8821',
        category: 'ANTIBIOTIC',
        name: 'Amoxicillin 500mg',
        formDescription: 'Oral Capsule • Standard Anti-infective',
        availableUnits: 342,
        unitLabel: 'units',
        statusBadgeText: 'Safe (14d cover)',
        statusType: StockStatusType.safe,
        footerText: 'Ready for dispense',
        batchNumber: 'AMX-2026-B8',
        expiryDate: '11/2027',
        storage: 'Store below 25°C in dry place',
        priority: 'Standard',
      ),
      MedicineItem(
        id: 'MED-3042',
        category: 'REHYDRATION',
        name: 'ORS Sachets (Oral Rehydration)',
        formDescription: 'WHO Formula • Powder Packet for 1L Water',
        availableUnits: 42,
        unitLabel: 'units',
        statusBadgeText: 'Warning (3d cover)',
        statusType: StockStatusType.warning,
        footerText: 'Threshold trigger active',
        batchNumber: 'ORS-993-A1',
        expiryDate: '04/2028',
        storage: 'Store in cool ambient room',
        priority: 'Standard',
      ),
      MedicineItem(
        id: 'BIO-1109',
        category: 'EMERGENCY BIOLOGIC',
        name: 'Rabies Anti-Serum 1000IU',
        formDescription: 'Injectable Vial • Equine Origin • Cold Chain 2-8°C',
        availableUnits: 4,
        unitLabel: 'vials',
        statusBadgeText: 'Critical (<24h cover)',
        statusType: StockStatusType.critical,
        footerText: 'Requires Patient Case ID',
        hasRedBorder: true,
        batchNumber: 'RAS-440-X1',
        expiryDate: '08/2026',
        storage: 'Cold chain 2-8°C required',
        priority: 'Triage',
      ),
    ];
  }
}
