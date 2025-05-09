import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';

class AcademicsPage extends StatelessWidget {
  const AcademicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final programs = [
      {
        'title': 'Computer Science',
        'description':
            'Learn programming, algorithms, and software development.',
        'duration': '4 Years',
        'degree': 'Bachelor of Technology',
        'icon': Icons.computer,
      },
      {
        'title': 'Business Administration',
        'description': 'Study management, marketing, and business operations.',
        'duration': '3 Years',
        'degree': 'Bachelor of Business Administration',
        'icon': Icons.business,
      },
      {
        'title': 'Mechanical Engineering',
        'description':
            'Explore mechanical systems, thermodynamics, and design.',
        'duration': '4 Years',
        'degree': 'Bachelor of Technology',
        'icon': Icons.engineering,
      },
      {
        'title': 'Electrical Engineering',
        'description':
            'Study electrical systems, electronics, and power systems.',
        'duration': '4 Years',
        'degree': 'Bachelor of Technology',
        'icon': Icons.electric_bolt,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academics'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Academic Programs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Explore our diverse range of undergraduate and graduate programs designed to prepare you for a successful career.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ...programs.map(
              (program) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildProgramCard(context, program),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, Map<String, dynamic> program) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  program['icon'] as IconData,
                  color: AppTheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program['title'] as String,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        program['degree'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              program['description'] as String,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.timer, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${program['duration']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.surface,
              ),
              child: const Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }
}
