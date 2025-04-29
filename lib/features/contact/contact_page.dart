import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contactInfo = {
      'address': '123 College Street, City, State 12345',
      'phone': '(123) 456-7890',
      'email': 'info@college.edu',
      'hours': 'Monday - Friday: 9:00 AM - 5:00 PM',
    };

    final departments = [
      {
        'name': 'Admissions Office',
        'phone': '(123) 456-7891',
        'email': 'admissions@college.edu',
      },
      {
        'name': 'Student Services',
        'phone': '(123) 456-7892',
        'email': 'studentservices@college.edu',
      },
      {
        'name': 'Financial Aid',
        'phone': '(123) 456-7893',
        'email': 'financialaid@college.edu',
      },
      {
        'name': 'Academic Affairs',
        'phone': '(123) 456-7894',
        'email': 'academics@college.edu',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: AppTheme.teal,
        foregroundColor: AppTheme.surfaceColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re here to help! Contact us with any questions or concerns.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
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
                    _buildContactItem(
                      context,
                      Icons.location_on,
                      'Address',
                      contactInfo['address']!,
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      context,
                      Icons.phone,
                      'Phone',
                      contactInfo['phone']!,
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      context,
                      Icons.email,
                      'Email',
                      contactInfo['email']!,
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      context,
                      Icons.access_time,
                      'Office Hours',
                      contactInfo['hours']!,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Department Contacts',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Contact specific departments for specialized assistance:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ...departments.map(
              (dept) => Padding(
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
                          dept['name']!,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: AppTheme.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: AppTheme.teal, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              dept['phone']!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email, color: AppTheme.teal, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              dept['email']!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
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
                  backgroundColor: AppTheme.teal,
                  foregroundColor: AppTheme.surfaceColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String content,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.teal, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(content, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
