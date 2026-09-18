enum NodeStatusType { critical, warning, surplus }

class CommandNode {
  final String id;
  final String name;
  final String distanceSector;
  final String badgeText;
  final NodeStatusType statusType;
  bool isExpanded;
  final String? depletedSupplies;
  final String? recommendedDonor;
  final String? coldChain;
  final String? occupancy;
  final String? transitEta;
  final String? medicalOfficer;

  CommandNode({
    required this.id,
    required this.name,
    required this.distanceSector,
    required this.badgeText,
    required this.statusType,
    this.isExpanded = false,
    this.depletedSupplies,
    this.recommendedDonor,
    this.coldChain,
    this.occupancy,
    this.transitEta,
    this.medicalOfficer,
  });

  factory CommandNode.fromJson(Map<String, dynamic> json) {
    final statusColor = json['status_color'] ?? 'green';
    NodeStatusType statusType = NodeStatusType.surplus;
    if (statusColor == 'red') {
      statusType = NodeStatusType.critical;
    } else if (statusColor == 'yellow') {
      statusType = NodeStatusType.warning;
    }

    final details = json['details'] ?? {};
    final occBeds = details['occupied_beds'] ?? 4;
    final totalBeds = details['bed_capacity'] ?? 10;
    final occPct = totalBeds > 0 ? ((occBeds / totalBeds) * 100).round() : 50;

    final lowStock = (json['low_stock_count'] as num?)?.toInt() ?? 0;

    return CommandNode(
      id: json['id'] ?? '',
      name: json['name'] ?? 'PHC Unit',
      distanceSector: '${json['mandal_name'] ?? 'Sector'}, ${json['district_name'] ?? ''} • Pin: ${json['pincode'] ?? ''}',
      badgeText: statusType == NodeStatusType.critical ? '$lowStock Stockouts' : (statusType == NodeStatusType.warning ? 'Warning Stock' : 'Surplus Reserve'),
      statusType: statusType,
      isExpanded: statusType == NodeStatusType.critical,
      depletedSupplies: lowStock > 0 ? 'Essential Stock Threshold Reached' : null,
      recommendedDonor: 'Regional District Depot Hub',
      coldChain: '4.0°C (Verified)',
      occupancy: '$occPct% ($occBeds/$totalBeds beds)',
      transitEta: '25 mins',
      medicalOfficer: 'Dr. On-Duty (${details['doctors_present'] ?? 2} Doctors, ${details['nurses_present'] ?? 4} Nurses)',
    );
  }

  static List<CommandNode> getInitialMockData() {
    return [
      CommandNode(
        id: 'GUDUR',
        name: 'PHC Gudur',
        distanceSector: '38km south-east • Sector Alpha-4',
        badgeText: '3 Stockouts',
        statusType: NodeStatusType.critical,
        isExpanded: true,
        depletedSupplies:
            'Oxytocin Injection (0 vials left) • Amoxicillin 250mg • Ringer\'s Lactate',
        recommendedDonor:
            'CHC Narsampet (Buffer stock available: +450 units)',
        coldChain: '3.8°C (Optimal)',
        occupancy: '92%',
        transitEta: '42 mins',
        medicalOfficer: 'Dr. S. Rao',
      ),
      CommandNode(
        id: 'CHENNARAOPET',
        name: 'PHC Chennaraopet',
        distanceSector: '24km east • Sector Delta-1',
        badgeText: '71% Stock Health',
        statusType: NodeStatusType.warning,
        isExpanded: false,
        depletedSupplies: 'Paracetamol 500mg (15 strips left)',
        recommendedDonor: 'Regional Depot Hub',
        coldChain: '4.2°C (Optimal)',
        occupancy: '68%',
        transitEta: '28 mins',
        medicalOfficer: 'Dr. M. Varma',
      ),
      CommandNode(
        id: 'NARSAMPET',
        name: 'CHC Narsampet',
        distanceSector: '19km east • Regional Hub Node',
        badgeText: '96% Surplus Hub',
        statusType: NodeStatusType.surplus,
        isExpanded: false,
        coldChain: '3.5°C (Optimal)',
        occupancy: '54%',
        transitEta: '18 mins',
        medicalOfficer: 'Dr. K. Srinivas',
      ),
    ];
  }
}
