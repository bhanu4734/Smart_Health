class TransferDirective {
  final String directiveNumber;
  final String statusBadge;
  final bool isCriticalStatus;
  final String riskInfo;
  String title;
  final String description;
  final String originName;
  final String originSubtitle;
  final String targetName;
  final String targetSubtitle;
  final bool isTargetCritical;
  final String transitDetails;
  final String transitTypeLabel;
  final int confidencePercent;
  final String confidenceTitle;
  final String confidenceBadge;
  final String confidenceNote;
  final String? id;
  int quantity;
  bool isApproved;

  TransferDirective({
    this.id,
    required this.directiveNumber,
    required this.statusBadge,
    this.isCriticalStatus = false,
    required this.riskInfo,
    required this.title,
    required this.description,
    required this.originName,
    required this.originSubtitle,
    required this.targetName,
    required this.targetSubtitle,
    this.isTargetCritical = false,
    required this.transitDetails,
    this.transitTypeLabel = 'Transit Corridor',
    required this.confidencePercent,
    required this.confidenceTitle,
    required this.confidenceBadge,
    required this.confidenceNote,
    this.quantity = 500,
    this.isApproved = false,
  });

  factory TransferDirective.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? 'pending';
    final isApproved = status == 'approved';
    final distance = (json['distance_km'] as num?)?.toDouble() ?? 15.0;
    final eta = json['eta_mins'] ?? (distance * 1.8).round();
    final qty = (json['quantity'] as num?)?.toInt() ?? 500;
    final medName = json['medicine_name'] ?? json['medicine_id'] ?? 'Essential Medicine';
    final srcName = json['source_phc_name'] ?? json['source_phc_id'] ?? 'Source PHC';
    final tgtName = json['target_phc_name'] ?? json['target_phc_id'] ?? 'Target PHC';
    final conf = (json['ai_confidence_pct'] as num?)?.toInt() ?? 94;
    final idStr = json['id'] ?? 'TR-001';

    return TransferDirective(
      id: idStr,
      directiveNumber: 'Directive #$idStr',
      statusBadge: isApproved ? 'Approved & En Route' : 'Zero-Stock Imminent',
      isCriticalStatus: !isApproved,
      riskInfo: 'SciPy OR Optimization Directive',
      title: '$medName • $qty Units',
      description: json['reason'] ?? 'Automated operations research linear sum assignment optimization.',
      originName: srcName,
      originSubtitle: 'Surplus Reserve',
      targetName: tgtName,
      targetSubtitle: 'Critical Stockout Deficit',
      isTargetCritical: true,
      transitDetails: '$distance km • ETA: $eta mins • Cold-Chain Verified',
      transitTypeLabel: 'Transit Corridor',
      confidencePercent: conf,
      confidenceTitle: '$conf% AI Confidence',
      confidenceBadge: 'SciPy Optimization Engine',
      confidenceNote: json['reason'] ?? 'Redistribution balances stockout risk across district facilities.',
      quantity: qty,
      isApproved: isApproved,
    );
  }

  static List<TransferDirective> getInitialMockData() {
    return [
      TransferDirective(
        directiveNumber: 'Directive #DR-9022',
        statusBadge: 'Zero-Stock Imminent',
        isCriticalStatus: true,
        riskInfo: 'Expiry Risk: 6h Window',
        title: 'Anti-Rabies Serum (1000 IU) • 45 Vials',
        description:
            'Cold storage tolerance 2°C – 8°C. Rapid stockout projection at recipient center in under 4 hours.',
        originName: 'CHC\nNarsampet',
        originSubtitle: 'Surplus Reserve\n(+60)',
        targetName: 'PHC Gudur',
        targetSubtitle: 'Critical Deficit (0\nVials)',
        isTargetCritical: true,
        transitDetails: '18.4 km via SH-14 • ETA: 32 mins • Cold-Box #B2',
        transitTypeLabel: 'Transit Corridor',
        confidencePercent: 94,
        confidenceTitle: '94% AI Confidence',
        confidenceBadge: 'Epidemic Vector Validated',
        confidenceNote:
            'Algorithmic risk mitigation scores canine attack surge in Mandal Area 4.',
        quantity: 45,
      ),
      TransferDirective(
        directiveNumber: 'Directive #DR-9025',
        statusBadge: 'Preventative Buffer',
        isCriticalStatus: false,
        riskInfo: 'Seasonal Preparedness Cycle',
        title: 'ORS Sachets • 600 Packs',
        description:
            'Standard clinical rehydration salts. Preemptive relocation ahead of anticipated heatwave spike.',
        originName: 'Central\nDepot',
        originSubtitle: 'Hub Inventory\nBulk',
        targetName: 'PHC Rampur',
        targetSubtitle: 'Projected Deficit (5\nDays)',
        isTargetCritical: false,
        transitDetails:
            '42.0 km via NH-363 • Non-Refrigerated Dispatch',
        transitTypeLabel: 'Transport Channel',
        confidencePercent: 91,
        confidenceTitle: '91% Model Confidence',
        confidenceBadge: 'Climatic Historical Align',
        confidenceNote:
            'Cross-referenced against 5-year monsoon onset morbidity records.',
        quantity: 600,
      ),
    ];
  }
}
