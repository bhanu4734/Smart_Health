class TransferDirective {
  final String directiveNumber;
  final String statusBadge;
  final bool isCriticalStatus;
  final String riskInfo;
  final String title;
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
  bool isApproved;

  TransferDirective({
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
    this.isApproved = false,
  });

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
      ),
    ];
  }
}
