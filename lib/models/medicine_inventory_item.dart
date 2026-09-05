class MedicineInventoryItem {
  final String id;
  final String category;
  final String name;
  final String formDescription;
  int availableUnits;
  final String safetyStatus;
  final String priority; // 'Standard' or 'Triage'
  final String? batchNumber;
  final String? expiryDate;
  final String? storage;

  MedicineInventoryItem({
    required this.id,
    required this.category,
    required this.name,
    required this.formDescription,
    required this.availableUnits,
    required this.safetyStatus,
    required this.priority,
    this.batchNumber,
    this.expiryDate,
    this.storage,
  });

  MedicineInventoryItem copyWith({
    String? id,
    String? category,
    String? name,
    String? formDescription,
    int? availableUnits,
    String? safetyStatus,
    String? priority,
    String? batchNumber,
    String? expiryDate,
    String? storage,
  }) {
    return MedicineInventoryItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      formDescription: formDescription ?? this.formDescription,
      availableUnits: availableUnits ?? this.availableUnits,
      safetyStatus: safetyStatus ?? this.safetyStatus,
      priority: priority ?? this.priority,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      storage: storage ?? this.storage,
    );
  }

  static List<MedicineInventoryItem> getInitialMockData() {
    return [
      MedicineInventoryItem(
        id: 'MED-8821',
        category: 'ANTIBIOTIC',
        name: 'Amoxicillin 500mg',
        formDescription: 'Oral Capsule • Standard Anti-infective',
        availableUnits: 342,
        safetyStatus: 'Safe (14d cover)',
        priority: 'Standard',
        batchNumber: 'AMX-2026-B8',
        expiryDate: '11/2027',
        storage: 'Store below 25°C in dry place',
      ),
      MedicineInventoryItem(
        id: 'MED-3042',
        category: 'REHYDRATION',
        name: 'ORS Sachets (Oral Rehydration)',
        formDescription: 'WHO Formula • Powder Packet for 1L Water',
        availableUnits: 1250,
        safetyStatus: 'Safe (30d cover)',
        priority: 'Standard',
        batchNumber: 'ORS-993-A1',
        expiryDate: '04/2028',
        storage: 'Store in cool ambient room',
      ),
      MedicineInventoryItem(
        id: 'MED-1109',
        category: 'ANALGESIC',
        name: 'Paracetamol 650mg',
        formDescription: 'Oral Tablet • Antipyretic & Pain Relief',
        availableUnits: 820,
        safetyStatus: 'Safe (21d cover)',
        priority: 'Standard',
        batchNumber: 'PCM-650-D2',
        expiryDate: '08/2027',
        storage: 'Protect from direct light',
      ),
      MedicineInventoryItem(
        id: 'MED-4412',
        category: 'EMERGENCY',
        name: 'Atropine Sulfate 0.6mg/mL',
        formDescription: 'Injectable Solution • Resuscitation Kit',
        availableUnits: 18,
        safetyStatus: 'Triage Critical (3d cover)',
        priority: 'Triage',
        batchNumber: 'ATR-004-X9',
        expiryDate: '12/2026',
        storage: 'Emergency crash cart / 2-8°C',
      ),
      MedicineInventoryItem(
        id: 'MED-5520',
        category: 'ANTIHISTAMINE',
        name: 'Cetirizine 10mg',
        formDescription: 'Film-coated Tablet • Second-Gen H1 Blocker',
        availableUnits: 460,
        safetyStatus: 'Safe (18d cover)',
        priority: 'Standard',
        batchNumber: 'CTZ-101-C3',
        expiryDate: '01/2028',
        storage: 'Ambient dry storage',
      ),
    ];
  }
}
