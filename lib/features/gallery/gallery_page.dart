import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Campus',
      'Events',
      'Students',
      'Faculty',
      'Sports',
    ];

    final images = [
      {
        'url': 'assets/images/campus1.jpg',
        'category': 'Campus',
        'title': 'Main Building',
      },
      {
        'url': 'assets/images/campus2.jpg',
        'category': 'Campus',
        'title': 'Library',
      },
      {
        'url': 'assets/images/event1.jpg',
        'category': 'Events',
        'title': 'Annual Day',
      },
      {
        'url': 'assets/images/event2.jpg',
        'category': 'Events',
        'title': 'Cultural Festival',
      },
      {
        'url': 'assets/images/student1.jpg',
        'category': 'Students',
        'title': 'Student Life',
      },
      {
        'url': 'assets/images/student2.jpg',
        'category': 'Students',
        'title': 'Study Group',
      },
      {
        'url': 'assets/images/faculty1.jpg',
        'category': 'Faculty',
        'title': 'Faculty Meeting',
      },
      {
        'url': 'assets/images/faculty2.jpg',
        'category': 'Faculty',
        'title': 'Research Lab',
      },
      {
        'url': 'assets/images/sports1.jpg',
        'category': 'Sports',
        'title': 'Basketball Team',
      },
      {
        'url': 'assets/images/sports2.jpg',
        'category': 'Sports',
        'title': 'Football Match',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: AppTheme.teal,
        foregroundColor: AppTheme.surfaceColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: AppTheme.surfaceColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children:
                    categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: category == 'All',
                          onSelected: (bool selected) {
                            // TODO: Implement filtering
                          },
                          backgroundColor: AppTheme.surfaceColor,
                          selectedColor: AppTheme.teal,
                          checkmarkColor: AppTheme.surfaceColor,
                          labelStyle: TextStyle(
                            color:
                                category == 'All'
                                    ? AppTheme.surfaceColor
                                    : AppTheme.teal,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return _buildImageCard(context, image);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, Map<String, String> image) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // TODO: Implement image preview
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  image['url']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.mistyBlue,
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: AppTheme.teal.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image['title']!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image['category']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTextColor,
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
}
