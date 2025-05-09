import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';

class AdmissionsPage extends StatelessWidget {
  const AdmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requirements = [
      'Completed application form',
      'High school transcripts',
      'Standardized test scores (SAT/ACT)',
      'Letters of recommendation',
      'Personal statement',
      'Application fee',
    ];

    final deadlines = [
      {
        'term': 'Fall Semester',
        'date': 'March 1, 2024',
        'description': 'Early Decision Deadline',
      },
      {
        'term': 'Fall Semester',
        'date': 'May 1, 2024',
        'description': 'Regular Decision Deadline',
      },
      {
        'term': 'Spring Semester',
        'date': 'October 1, 2024',
        'description': 'Spring Admission Deadline',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admissions'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admission Requirements',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'To be considered for admission, applicants must meet the following requirements:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...requirements.map(
                      (requirement) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                requirement,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Application Deadlines',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Important dates to remember for your application:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ...deadlines.map(
              (deadline) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deadline['term'] as String,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          deadline['date'] as String,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          deadline['description'] as String,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
