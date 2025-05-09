import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';

class VisionMissionSection extends StatelessWidget {
  const VisionMissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 80,
      ),
      child: Column(
        children: [
          // Section Title
          Text(
            'Our Vision & Mission',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Guiding principles that shape our educational journey',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isMobile ? 16 : 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          // Vision & Mission Cards
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildCard(
                context,
                title: 'Our Vision',
                icon: Icons.visibility_outlined,
                gradient: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.secondary.withOpacity(0.1),
                ],
                content:
                    'To be a leading educational institution that nurtures future leaders through holistic development, academic excellence, and character building.',
                points: [
                  'Academic Excellence',
                  'Character Development',
                  'Innovation in Learning',
                  'Global Perspective',
                ],
              ),
              _buildCard(
                context,
                title: 'Our Mission',
                icon: Icons.rocket_launch_outlined,
                gradient: [
                  AppTheme.accent.withOpacity(0.1),
                  AppTheme.highlight.withOpacity(0.1),
                ],
                content:
                    'To provide quality education that empowers students with knowledge, skills, and values necessary for success in a rapidly evolving world.',
                points: [
                  'Quality Education',
                  'Skill Development',
                  'Value-based Learning',
                  'Personal Growth',
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required String content,
    required List<String> points,
  }) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final width =
        isMobile
            ? double.infinity
            : isTablet
            ? 360.0
            : 480.0;

    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: AppTheme.primary),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Text(
            content,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // Points
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(Icons.check, size: 16, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    point,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
