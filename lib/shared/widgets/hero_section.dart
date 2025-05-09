import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Container(
      height: isDesktop ? 600 : 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.05),
            AppTheme.accent.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: GridPatternPainter(
                lineColor: AppTheme.primary.withOpacity(0.05),
                gridSize: 40,
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 48,
              vertical: isMobile ? 32 : 48,
            ),
            child: Row(
              children: [
                // Left content
                Expanded(
                  flex: isDesktop ? 1 : 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎓 Admissions Open 2024-25',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Shape Your Future\nWith Excellence',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: isMobile ? 36 : 48,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Join Values Junior College and embark on a journey of academic excellence, personal growth, and endless possibilities.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: isMobile ? 16 : 18,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                            ),
                            child: const Text('Apply Now'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text('Watch Video'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          _buildStat('500+', 'Students'),
                          const SizedBox(width: 48),
                          _buildStat('50+', 'Faculty'),
                          const SizedBox(width: 48),
                          _buildStat('95%', 'Success Rate'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right content (image)
                if (isDesktop || isTablet) ...[
                  const SizedBox(width: 48),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/images/hero_image.png',
                            width: isDesktop ? 600 : 400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class GridPatternPainter extends CustomPainter {
  final Color lineColor;
  final double gridSize;

  GridPatternPainter({required this.lineColor, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
