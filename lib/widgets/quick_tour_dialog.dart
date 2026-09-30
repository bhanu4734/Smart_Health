import 'package:flutter/material.dart';
import '../features/auth/controllers/auth_controller.dart';

class QuickTourDialog extends StatefulWidget {
  const QuickTourDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const QuickTourDialog(),
    );
  }

  @override
  State<QuickTourDialog> createState() => _QuickTourDialogState();
}

class _QuickTourDialogState extends State<QuickTourDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _tourSteps = [
    {
      'title': '🗺️ Multi-District Command Center',
      'subtitle': 'Real-time PHC & Bed Monitoring',
      'description': 'Monitor 73 PHCs across 33 Districts in real-time. Track bed capacity, doctor attendance, and instant stockout risk indicators.',
      'icon': 'dashboard',
    },
    {
      'title': '⚡ AI Stock Redistribution',
      'subtitle': 'Automated Peer-to-Peer Supply Mesh',
      'description': 'Our AI optimizer predicts medicine stockouts before they happen and routes surplus supplies between neighboring PHCs via OSRM spatial road routing.',
      'icon': 'local_shipping',
    },
    {
      'title': '🔒 Sovereign Federated Learning',
      'subtitle': 'Decentralized Privacy-Preserving AI',
      'description': 'Patient dispensing logs remain localized on edge PHC devices. Encrypted model weights are aggregated globally without compromising data sovereignty.',
      'icon': 'security',
    },
  ];

  void _nextPage() {
    if (_currentPage < _tourSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTour();
    }
  }

  void _finishTour() {
    AuthController().completeTour();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF0F172A),
      elevation: 16,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Step ${_currentPage + 1} of ${_tourSteps.length}',
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _finishTour,
                  child: const Text(
                    'Skip Tour',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Page View Content
            SizedBox(
              height: 230,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _tourSteps.length,
                itemBuilder: (context, index) {
                  final step = _tourSteps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                        ),
                        child: Icon(
                          index == 0
                              ? Icons.space_dashboard_rounded
                              : (index == 1 ? Icons.local_shipping_rounded : Icons.shield_rounded),
                          color: const Color(0xFF3B82F6),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['subtitle']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step['description']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Page Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _tourSteps.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentPage == i ? 22 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? const Color(0xFF3B82F6) : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Next / Get Started Action Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _nextPage,
                child: Text(
                  _currentPage == _tourSteps.length - 1 ? '🚀 Get Started' : 'Next Step →',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
