import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import 'phc_globe_viewer.dart';

class PhcGlobeModal extends StatefulWidget {
  const PhcGlobeModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => const PhcGlobeModal(),
    );
  }

  @override
  State<PhcGlobeModal> createState() => _PhcGlobeModalState();
}

class _PhcGlobeModalState extends State<PhcGlobeModal> {
  String _selectedFilter = 'all'; // 'all', 'critical', 'active'

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    final modalWidth = isDesktop ? size.width * 0.85 : size.width * 0.96;
    final modalHeight = isDesktop ? size.height * 0.88 : size.height * 0.94;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: modalWidth,
        height: modalHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top Command Bar (OSM Clean White/Slate Header) ─────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Color(0xFF0284C7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'GLOBAL PHC GIS NETWORK',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.circle, size: 5, color: Color(0xFF059669)),
                                  SizedBox(width: 4),
                                  Text(
                                    'DMO LIVE TELEMETRY',
                                    style: TextStyle(
                                      color: Color(0xFF047857),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'OpenStreetMap Geodesic Telemetry • Central India & Telangana Jurisdiction',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Filter Chips (Desktop)
                  if (isDesktop) ...[
                    _buildFilterChip('All PHCs (24)', 'all', Icons.hub_outlined),
                    const SizedBox(width: 8),
                    _buildFilterChip('Critical Stock (4)', 'critical', Icons.warning_amber_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('Active Corridors (7)', 'active', Icons.alt_route_rounded),
                    const SizedBox(width: 16),
                  ],

                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF475569)),
                    tooltip: 'Close Map Command',
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // ── Mobile Filter Row (when mobile) ──────────────────────────
            if (!isDesktop)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  children: [
                    Expanded(child: _buildFilterChip('All PHCs (24)', 'all', Icons.hub_outlined)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildFilterChip('Critical', 'critical', Icons.warning_amber_rounded)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildFilterChip('Corridors', 'active', Icons.alt_route_rounded)),
                  ],
                ),
              ),

            // ── Interactive OpenStreetMap GIS Canvas Area ────────────────
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PhcGlobeViewer(
                      height: double.infinity,
                      filterStatus: _selectedFilter,
                    ),
                  ),

                  // Floating Legend Overlay (Bottom Left, Clean White OSM Card)
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'TELEMETRY LEGEND',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.circle, size: 8, color: Color(0xFF059669)),
                              SizedBox(width: 6),
                              Text('Normal Stock (90%+)', style: TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.w600)),
                              SizedBox(width: 14),
                              Icon(Icons.circle, size: 8, color: Color(0xFFD97706)),
                              SizedBox(width: 6),
                              Text('Warning (<75%)', style: TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.w600)),
                              SizedBox(width: 14),
                              Icon(Icons.circle, size: 8, color: Color(0xFFDC2626)),
                              SizedBox(width: 6),
                              Text('Critical Surge', style: TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Footer Helper Strip (Clean OSM Slate Style) ──────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined, size: 15, color: Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pan and zoom across OpenStreetMap • Tap any PHC node for real-time district cold-chain telemetry • Solid lines illustrate live inter-district and global supply reallocation routes',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.done_rounded, size: 14),
                    label: const Text('Dismiss', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
