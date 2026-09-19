import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../app/app_theme.dart';

class GlobePhcNode {
  final String id;
  final String name;
  final String district;
  final double latDeg;
  final double lonDeg;
  final String status; // 'normal', 'warning', 'critical'
  final int beds;
  final int staff;
  final double bufferPct;
  final bool isGlobalHub;

  const GlobePhcNode({
    required this.id,
    required this.name,
    required this.district,
    required this.latDeg,
    required this.lonDeg,
    required this.status,
    required this.beds,
    required this.staff,
    required this.bufferPct,
    this.isGlobalHub = false,
  });

  double get latRad => latDeg * math.pi / 180.0;
  double get lonRad => lonDeg * math.pi / 180.0;
  LatLng get latLng => LatLng(latDeg, lonDeg);
}

class GlobeTransitArc {
  final GlobePhcNode source;
  final GlobePhcNode target;
  final String label;
  final Color color;

  const GlobeTransitArc({
    required this.source,
    required this.target,
    required this.label,
    required this.color,
  });
}

class PhcGlobeViewer extends StatefulWidget {
  final double height;
  final bool autoRotate;
  final String filterStatus; // 'all', 'critical', 'active'
  final ValueChanged<GlobePhcNode?>? onNodeSelected;

  const PhcGlobeViewer({
    super.key,
    this.height = 520,
    this.autoRotate = true,
    this.filterStatus = 'all',
    this.onNodeSelected,
  });

  @override
  State<PhcGlobeViewer> createState() => _PhcGlobeViewerState();
}

class _PhcGlobeViewerState extends State<PhcGlobeViewer> {
  late final MapController _mapController;

  // Exact coordinates from user OpenStreetMap reference: https://www.openstreetmap.org/#map=5/24.54/77.65
  static const LatLng _indiaCenter = LatLng(24.54, 77.65);
  static const double _indiaZoom = 5.0;

  // Telangana State Jurisdiction center
  static const LatLng _telanganaCenter = LatLng(17.80, 79.20);
  static const double _telanganaZoom = 7.6;

  GlobePhcNode? _selectedNode;

  // Real Telangana PHC nodes from resilience.db + Global partner depots
  static const List<GlobePhcNode> _nodes = [
    // ── Warangal District Cluster
    GlobePhcNode(
      id: 'PHC-WAR-01',
      name: 'Warangal Central Hub',
      district: 'Warangal District Command',
      latDeg: 18.0744,
      lonDeg: 79.6731,
      status: 'normal',
      beds: 32,
      staff: 18,
      bufferPct: 94.5,
    ),
    GlobePhcNode(
      id: 'PHC-WAR-02',
      name: 'PHC Rampur',
      district: 'Warangal District',
      latDeg: 18.0541,
      lonDeg: 79.4465,
      status: 'normal',
      beds: 20,
      staff: 12,
      bufferPct: 91.0,
    ),
    GlobePhcNode(
      id: 'PHC-WAR-03',
      name: 'Parvathagiri PHC',
      district: 'Warangal District',
      latDeg: 17.9125,
      lonDeg: 79.6953,
      status: 'warning',
      beds: 14,
      staff: 8,
      bufferPct: 68.5,
    ),
    GlobePhcNode(
      id: 'PHC-WAR-04',
      name: 'PHC Gudur',
      district: 'Warangal District',
      latDeg: 17.9358,
      lonDeg: 79.5085,
      status: 'critical',
      beds: 12,
      staff: 6,
      bufferPct: 24.0,
    ),

    // ── Nalgonda District Cluster
    GlobePhcNode(
      id: 'PHC-D01-01',
      name: 'Nalgonda Area PHC #1',
      district: 'Nalgonda District',
      latDeg: 16.9383,
      lonDeg: 79.2977,
      status: 'normal',
      beds: 18,
      staff: 10,
      bufferPct: 88.0,
    ),
    GlobePhcNode(
      id: 'PHC-D01-02',
      name: 'Nalgonda Area PHC #2',
      district: 'Nalgonda District',
      latDeg: 16.9711,
      lonDeg: 79.3204,
      status: 'normal',
      beds: 16,
      staff: 9,
      bufferPct: 85.5,
    ),
    GlobePhcNode(
      id: 'PHC-D01-03',
      name: 'Nalgonda Area PHC #3',
      district: 'Nalgonda District',
      latDeg: 17.1234,
      lonDeg: 79.2097,
      status: 'warning',
      beds: 14,
      staff: 8,
      bufferPct: 71.0,
    ),
    GlobePhcNode(
      id: 'PHC-D01-04',
      name: 'Nalgonda Area PHC #4',
      district: 'Nalgonda District',
      latDeg: 17.0213,
      lonDeg: 79.1522,
      status: 'normal',
      beds: 15,
      staff: 8,
      bufferPct: 89.0,
    ),

    // ── Khammam District Cluster
    GlobePhcNode(
      id: 'PHC-D02-01',
      name: 'Khammam Area PHC #1',
      district: 'Khammam District',
      latDeg: 17.1560,
      lonDeg: 80.2423,
      status: 'normal',
      beds: 22,
      staff: 11,
      bufferPct: 92.0,
    ),
    GlobePhcNode(
      id: 'PHC-D02-02',
      name: 'Khammam Area PHC #2',
      district: 'Khammam District',
      latDeg: 17.2060,
      lonDeg: 80.0969,
      status: 'normal',
      beds: 18,
      staff: 10,
      bufferPct: 86.5,
    ),
    GlobePhcNode(
      id: 'PHC-D02-03',
      name: 'Khammam Area PHC #3',
      district: 'Khammam District',
      latDeg: 17.2500,
      lonDeg: 80.1582,
      status: 'critical',
      beds: 12,
      staff: 6,
      bufferPct: 28.5,
    ),
    GlobePhcNode(
      id: 'PHC-D02-04',
      name: 'Khammam Area PHC #4',
      district: 'Khammam District',
      latDeg: 17.2953,
      lonDeg: 80.1540,
      status: 'normal',
      beds: 16,
      staff: 9,
      bufferPct: 84.0,
    ),

    // ── Mahabubnagar District Cluster
    GlobePhcNode(
      id: 'PHC-D03-01',
      name: 'Mahabubnagar Area PHC #1',
      district: 'Mahabubnagar District',
      latDeg: 16.8283,
      lonDeg: 78.1103,
      status: 'normal',
      beds: 20,
      staff: 11,
      bufferPct: 90.0,
    ),
    GlobePhcNode(
      id: 'PHC-D03-02',
      name: 'Mahabubnagar Area PHC #2',
      district: 'Mahabubnagar District',
      latDeg: 16.8950,
      lonDeg: 78.1443,
      status: 'warning',
      beds: 15,
      staff: 8,
      bufferPct: 64.0,
    ),
    GlobePhcNode(
      id: 'PHC-D03-03',
      name: 'Mahabubnagar Area PHC #3',
      district: 'Mahabubnagar District',
      latDeg: 16.7000,
      lonDeg: 78.0970,
      status: 'normal',
      beds: 14,
      staff: 7,
      bufferPct: 87.0,
    ),
    GlobePhcNode(
      id: 'PHC-D03-04',
      name: 'Mahabubnagar Area PHC #4',
      district: 'Mahabubnagar District',
      latDeg: 16.7564,
      lonDeg: 77.9980,
      status: 'normal',
      beds: 12,
      staff: 7,
      bufferPct: 93.0,
    ),

    // ── Karimnagar District Cluster
    GlobePhcNode(
      id: 'PHC-D04-01',
      name: 'Karimnagar Area PHC #1',
      district: 'Karimnagar District',
      latDeg: 18.3414,
      lonDeg: 79.1214,
      status: 'normal',
      beds: 24,
      staff: 14,
      bufferPct: 95.0,
    ),
    GlobePhcNode(
      id: 'PHC-D04-02',
      name: 'Karimnagar Area PHC #2',
      district: 'Karimnagar District',
      latDeg: 18.4397,
      lonDeg: 79.0189,
      status: 'normal',
      beds: 16,
      staff: 9,
      bufferPct: 88.0,
    ),
    GlobePhcNode(
      id: 'PHC-D04-03',
      name: 'Karimnagar Area PHC #3',
      district: 'Karimnagar District',
      latDeg: 18.3048,
      lonDeg: 79.1384,
      status: 'critical',
      beds: 10,
      staff: 5,
      bufferPct: 19.5,
    ),
    GlobePhcNode(
      id: 'PHC-D04-04',
      name: 'Karimnagar Area PHC #4',
      district: 'Karimnagar District',
      latDeg: 18.3752,
      lonDeg: 79.2000,
      status: 'normal',
      beds: 18,
      staff: 10,
      bufferPct: 91.5,
    ),

    // ── Hyderabad State Command Center
    GlobePhcNode(
      id: 'HYD-CMD-01',
      name: 'Hyderabad State Command Hub',
      district: 'Telangana State Headquarters',
      latDeg: 17.3850,
      lonDeg: 78.4867,
      status: 'normal',
      beds: 120,
      staff: 65,
      bufferPct: 99.0,
    ),

    // ── Global Strategic Supply Partners
    GlobePhcNode(
      id: 'GLO-WHO-01',
      name: 'Geneva Global Health Terminal',
      district: 'WHO Central Supply, Switzerland',
      latDeg: 46.2044,
      lonDeg: 6.1432,
      status: 'normal',
      beds: 450,
      staff: 210,
      bufferPct: 99.9,
      isGlobalHub: true,
    ),
    GlobePhcNode(
      id: 'GLO-LON-02',
      name: 'London Imperial Cold Depot',
      district: 'UK Strategic Medical Reserve',
      latDeg: 51.5074,
      lonDeg: -0.1278,
      status: 'normal',
      beds: 380,
      staff: 160,
      bufferPct: 97.4,
      isGlobalHub: true,
    ),
    GlobePhcNode(
      id: 'GLO-SIN-03',
      name: 'Singapore APAC Vaccine Hub',
      district: 'ASEAN Cold-Chain Logistics',
      latDeg: 1.3521,
      lonDeg: 103.8198,
      status: 'normal',
      beds: 300,
      staff: 125,
      bufferPct: 98.2,
      isGlobalHub: true,
    ),
  ];

  static final List<GlobeTransitArc> _arcs = [
    GlobeTransitArc(
      source: _nodes[20], // Hyderabad State Command Hub
      target: _nodes[0],  // Warangal Central Hub
      label: 'Cold-Chain Insulin Reallocation (Route #TS-01)',
      color: const Color(0xFF0284C7),
    ),
    GlobeTransitArc(
      source: _nodes[0],  // Warangal Central
      target: _nodes[3],  // PHC Gudur (Critical)
      label: 'Emergency SciPy Restock Box #B2',
      color: const Color(0xFFDC2626),
    ),
    GlobeTransitArc(
      source: _nodes[20], // Hyderabad
      target: _nodes[4],  // Nalgonda
      label: 'Pediatric Vaccine Buffer replenishment',
      color: const Color(0xFF0284C7),
    ),
    GlobeTransitArc(
      source: _nodes[4],  // Nalgonda
      target: _nodes[10], // Khammam Critical
      label: 'Direct Mandal Transfer Directive',
      color: const Color(0xFFD97706),
    ),
    GlobeTransitArc(
      source: _nodes[20], // Hyderabad
      target: _nodes[16], // Karimnagar
      label: 'District Mesh Cross-Balancing',
      color: const Color(0xFF7C3AED),
    ),
    GlobeTransitArc(
      source: _nodes[20], // Hyderabad
      target: _nodes[21], // Geneva WHO
      label: 'Sovereign Federated Telemetry Link',
      color: const Color(0xFF0284C7),
    ),
    GlobeTransitArc(
      source: _nodes[20], // Hyderabad
      target: _nodes[23], // Singapore
      label: 'Global Cold-Chain Air Corridor',
      color: const Color(0xFF059669),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedNode = _nodes[0]; // Warangal Central Hub
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _flyToIndia() {
    _mapController.move(_indiaCenter, _indiaZoom);
  }

  void _flyToTelangana() {
    _mapController.move(_telanganaCenter, _telanganaZoom);
  }

  void _flyToGlobal() {
    _mapController.move(const LatLng(25.0, 45.0), 2.8);
  }

  List<GlobePhcNode> get _filteredNodes {
    if (widget.filterStatus == 'critical') {
      return _nodes.where((n) => n.status == 'critical' || n.status == 'warning').toList();
    }
    return _nodes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── MAIN OPENSTREETMAP LAYER ──────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _indiaCenter, // 24.54, 77.65
              initialZoom: _indiaZoom,
              minZoom: 2.0,
              maxZoom: 18.0,
            ),
            children: [
              // 1. Official OpenStreetMap Tile Layer (Matching openstreetmap.org)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smarthealth.resilience',
                maxZoom: 19,
              ),

              // 2. Cold-Chain Redistribution Corridors (Polyline Layer)
              PolylineLayer(
                polylines: _arcs.map((arc) {
                  return Polyline(
                    points: [arc.source.latLng, arc.target.latLng],
                    color: arc.color.withValues(alpha: 0.85),
                    strokeWidth: 3.0,
                  );
                }).toList(),
              ),

              // 3. Interactive PHC Nodes (Marker Layer)
              MarkerLayer(
                markers: _filteredNodes.map((node) {
                  final isSelected = (_selectedNode?.id == node.id);
                  final nodeColor = _getNodeColor(node.status);

                  return Marker(
                    point: node.latLng,
                    width: isSelected ? 52 : 42,
                    height: isSelected ? 52 : 42,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedNode = node);
                        widget.onNodeSelected?.call(node);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radar pulse ring
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: isSelected ? 46 : 34,
                            height: isSelected ? 46 : 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: nodeColor.withValues(alpha: 0.22),
                              border: Border.all(color: nodeColor.withValues(alpha: 0.8), width: 1.5),
                            ),
                          ),
                          // Inner solid pin
                          Container(
                            width: isSelected ? 20 : 15,
                            height: isSelected ? 20 : 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: nodeColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── TOP GIS JURISDICTION BAR (Styled in OpenStreetMap Colors) ────
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location Identity Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'OSM GEODESIC MESH • 24.54° N, 77.65° E',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: 0.4),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Text(
                          'TELANGANA HEALTH',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Camera Presets (India, Telangana, Global)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPresetBtn('🇮🇳 India (24.54, 77.65)', _flyToIndia),
                    const SizedBox(width: 6),
                    _buildPresetBtn('🏥 Telangana', _flyToTelangana),
                    const SizedBox(width: 6),
                    _buildPresetBtn('🌍 Global', _flyToGlobal),
                  ],
                ),
              ],
            ),
          ),

          // ── FLOATING ZOOM CONTROLS (Right Side, Clean OSM Style) ────────
          Positioned(
            top: 70,
            right: 14,
            child: Column(
              children: [
                _buildMapIconBtn(Icons.add_rounded, 'Zoom In', () {
                  final z = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, (z + 1).clamp(2.0, 18.0));
                }),
                const SizedBox(height: 6),
                _buildMapIconBtn(Icons.remove_rounded, 'Zoom Out', () {
                  final z = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, (z - 1).clamp(2.0, 18.0));
                }),
              ],
            ),
          ),

          // ── FLOATING TELEMETRY INSPECTION CARD (Bottom, Clean OSM Style) ─
          if (_selectedNode != null)
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: _getNodeColor(_selectedNode!.status).withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getNodeColor(_selectedNode!.status).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getNodeColor(_selectedNode!.status).withValues(alpha: 0.3)),
                          ),
                          child: Icon(
                            _selectedNode!.isGlobalHub ? Icons.flight_takeoff_rounded : Icons.local_hospital_rounded,
                            color: _getNodeColor(_selectedNode!.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedNode!.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getNodeColor(_selectedNode!.status),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _selectedNode!.status.toUpperCase(),
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_selectedNode!.district} • GPS (${_selectedNode!.latDeg.toStringAsFixed(4)}, ${_selectedNode!.lonDeg.toStringAsFixed(4)})',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildHudStat('Available Beds', '${_selectedNode!.beds}'),
                                  const SizedBox(width: 14),
                                  _buildHudStat('Staff on Duty', '${_selectedNode!.staff}'),
                                  const SizedBox(width: 14),
                                  _buildHudStat('Buffer Health', '${_selectedNode!.bufferPct}%'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => _selectedNode = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPresetBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildMapIconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF0F172A), size: 18),
        ),
      ),
    );
  }

  Widget _buildHudStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 1),
        Text(val, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
      ],
    );
  }

  Color _getNodeColor(String status) {
    switch (status) {
      case 'critical':
        return const Color(0xFFDC2626);
      case 'warning':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF059669);
    }
  }
}
