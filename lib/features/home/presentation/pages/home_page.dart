import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:values_web_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:values_web_app/features/about/about_page.dart';
import 'package:values_web_app/features/academics/academics_page.dart';
import 'package:values_web_app/features/admissions/admissions_page.dart';
import 'package:values_web_app/features/contact/contact_page.dart';
import 'package:values_web_app/features/gallery/gallery_page.dart';

class Feature {
  final String title;
  final String description;
  final IconData icon;

  const Feature({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.surfaceColor.withOpacity(0.95),
            elevation: 4,
            flexibleSpace: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/values_logo.svg',
                    height: 50,
                    width: 50,
                  ),
                  Row(
                    children: [
                      _buildNavItem(context, 'Home', true),
                      _buildNavItem(context, 'About', false),
                      _buildNavItem(context, 'Academics', false),
                      _buildNavItem(context, 'Admissions', false),
                      _buildNavItem(context, 'Gallery', false),
                      _buildNavItem(context, 'Contact', false),
                    ],
                  ),
                ],
              ),
            ),
            toolbarHeight: 80,
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return SliverToBoxAdapter(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeroSection(context),
                      _buildFeaturesSection(context),
                      _buildNewsSection(context),
                      _buildFooter(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {
          if (title == 'Home') {
            // Already on home page, do nothing
          } else if (title == 'About') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            );
          } else if (title == 'Academics') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AcademicsPage()),
            );
          } else if (title == 'Admissions') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdmissionsPage()),
            );
          } else if (title == 'Contact') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactPage()),
            );
          } else if (title == 'Gallery') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GalleryPage()),
            );
          }
        },
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isActive ? AppTheme.teal : AppTheme.tan,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).smallerThan(TABLET);
    final isTablet = ResponsiveBreakpoints.of(context).between(TABLET, DESKTOP);

    return SizedBox(
      height: ResponsiveBreakpoints.of(context).largerThan(MOBILE) ? 900 : 700,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image with Parallax Effect
          Positioned.fill(
            child: Image.asset('assets/images/college.png', fit: BoxFit.cover),
          ),
          // Gradient Overlay with Animated Opacity
          Positioned.fill(
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.teal.withOpacity(0.8 * value),
                        AppTheme.beige.withOpacity(0.9 * value),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Content
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 32 : 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main Title with Staggered Animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Text(
                            'Welcome to Our College',
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
                              color: AppTheme.surfaceColor,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              fontSize: isMobile ? 32 : (isTablet ? 40 : 56),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  // Subtitle with Staggered Animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Text(
                            'Shaping Tomorrow\'s Leaders Today',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.surfaceColor.withOpacity(0.9),
                              height: 1.4,
                              fontSize: isMobile ? 20 : (isTablet ? 24 : 28),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 32 : 48),
                  // CTA Buttons with Staggered Animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: ResponsiveRowColumn(
                            rowMainAxisAlignment: MainAxisAlignment.center,
                            rowCrossAxisAlignment: CrossAxisAlignment.center,
                            columnMainAxisAlignment: MainAxisAlignment.center,
                            columnCrossAxisAlignment: CrossAxisAlignment.center,
                            layout:
                                isMobile
                                    ? ResponsiveRowColumnType.COLUMN
                                    : ResponsiveRowColumnType.ROW,
                            children: [
                              ResponsiveRowColumnItem(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: isMobile ? 16 : 0,
                                    right: isMobile ? 0 : 16,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.surfaceColor,
                                      foregroundColor: AppTheme.teal,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 24 : 32,
                                        vertical: isMobile ? 12 : 16,
                                      ),
                                    ),
                                    child: Text(
                                      'Learn More',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ResponsiveRowColumnItem(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.surfaceColor,
                                    side: const BorderSide(
                                      color: AppTheme.surfaceColor,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 24 : 32,
                                      vertical: isMobile ? 12 : 16,
                                    ),
                                  ),
                                  child: Text(
                                    'Contact Us',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 32 : 48),
                  // Scroll Indicator
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Column(
                          children: [
                            Text(
                              'Scroll to Explore',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.surfaceColor.withOpacity(0.8),
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppTheme.surfaceColor.withOpacity(0.8),
                              size: isMobile ? 24 : 32,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      const Feature(
        title: 'Excellence in Education',
        description:
            'Our commitment to academic excellence sets us apart with innovative teaching methods and rigorous curriculum.',
        icon: Icons.school,
      ),
      const Feature(
        title: 'World-Class Faculty',
        description:
            'Learn from experienced professors and industry experts who bring real-world knowledge to the classroom.',
        icon: Icons.people,
      ),
      const Feature(
        title: 'Modern Infrastructure',
        description:
            'State-of-the-art facilities including smart classrooms, research labs, and collaborative spaces.',
        icon: Icons.architecture,
      ),
      const Feature(
        title: 'Global Opportunities',
        description:
            'International exchange programs, study abroad options, and global industry partnerships.',
        icon: Icons.public,
      ),
      const Feature(
        title: 'Career Development',
        description:
            'Comprehensive career services, internship programs, and industry connections for student success.',
        icon: Icons.work,
      ),
      const Feature(
        title: 'Research Excellence',
        description:
            'Cutting-edge research facilities and opportunities to work on groundbreaking projects.',
        icon: Icons.science,
      ),
      const Feature(
        title: 'Student Life',
        description:
            'Vibrant campus life with diverse clubs, sports, and cultural activities for holistic development.',
        icon: Icons.emoji_events,
      ),
      const Feature(
        title: 'Innovation Hub',
        description:
            'Dedicated spaces for entrepreneurship, innovation, and creative problem-solving.',
        icon: Icons.lightbulb,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'Why Choose Us',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: FlutterCarousel(
              items:
                  features.map((feature) {
                    return TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: _buildFeatureCard(
                            context,
                            feature.title,
                            feature.description,
                            feature.icon,
                          ),
                        );
                      },
                    );
                  }).toList(),
              options: CarouselOptions(
                height: 400,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
                aspectRatio: 16 / 9,
                onPageChanged: (index, reason) {
                  // Handle page change if needed
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Icon(icon, size: 64, color: AppTheme.beige),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context) {
    final news = [
      {
        'title': 'New Research Center Inaugurated',
        'description':
            'Our new state-of-the-art research center is now open, featuring advanced laboratories for biotechnology, artificial intelligence, and sustainable energy research.',
        'date': 'March 15, 2024',
        'category': 'Campus',
        'image': 'assets/images/research_center.jpg',
      },
      {
        'title': 'International Conference Success',
        'description':
            'Over 500 researchers from 50 countries participated in our annual International Conference on Innovation and Technology, sharing groundbreaking discoveries.',
        'date': 'March 10, 2024',
        'category': 'Events',
        'image': 'assets/images/conference.jpg',
      },
      {
        'title': 'Student Achievement Awards',
        'description':
            "Celebrating our students' outstanding achievements across academics, research, and community service. Special recognition for breakthrough projects.",
        'date': 'March 5, 2024',
        'category': 'Students',
        'image': 'assets/images/awards.jpg',
      },
      {
        'title': 'New Partnership with Industry Leaders',
        'description':
            'Strategic partnerships formed with leading tech companies to provide internship opportunities and industry-relevant training for our students.',
        'date': 'March 1, 2024',
        'category': 'Partnerships',
        'image': 'assets/images/partnership.jpg',
      },
      {
        'title': 'Sustainability Initiative Launch',
        'description':
            'Campus-wide sustainability program launched with solar power installation, waste reduction measures, and green building certifications.',
        'date': 'February 28, 2024',
        'category': 'Campus',
        'image': 'assets/images/sustainability.jpg',
      },
      {
        'title': 'Alumni Success Story',
        'description':
            "Recent graduate launches successful tech startup, securing \$2M in seed funding. Read about their journey from classroom to entrepreneurship.",
        'date': 'February 25, 2024',
        'category': 'Alumni',
        'image': 'assets/images/alumni.jpg',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Column(
                    children: [
                      Text(
                        'Latest News',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stay updated with the latest happenings at our college',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
          SizedBox(
            height: 950,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
                  news
                      .map(
                        (news) => _buildNewsCard(
                          context,
                          news['title']!,
                          news['description']!,
                          news['date']!,
                          news['category']!,
                          news['image']!,
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teal,
              foregroundColor: AppTheme.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('View All News'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(
    BuildContext context,
    String title,
    String description,
    String date,
    String category,
    String imagePath,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 21 / 9,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Text('Read More'),
                  label: const Icon(Icons.arrow_forward, size: 16),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.teal,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: AppTheme.teal,
      child: ResponsiveRowColumn(
        rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
        rowCrossAxisAlignment: CrossAxisAlignment.start,
        columnMainAxisAlignment: MainAxisAlignment.center,
        columnCrossAxisAlignment: CrossAxisAlignment.center,
        layout:
            ResponsiveBreakpoints.of(context).largerThan(MOBILE)
                ? ResponsiveRowColumnType.ROW
                : ResponsiveRowColumnType.COLUMN,
        children: [
          ResponsiveRowColumnItem(
            rowFlex: 1,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(-50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/values_logo.svg',
                          height: 50,
                          width: 50,
                          colorFilter: ColorFilter.mode(
                            AppTheme.surfaceColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'College Name',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.surfaceColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Shaping Tomorrow\'s Leaders Today',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.surfaceColor.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ResponsiveRowColumnItem(
            rowFlex: 1,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Links',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: AppTheme.surfaceColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFooterLink(context, 'About Us', () {}),
                        _buildFooterLink(context, 'Academics', () {}),
                        _buildFooterLink(context, 'Admissions', () {}),
                        _buildFooterLink(context, 'Contact', () {}),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ResponsiveRowColumnItem(
            rowFlex: 1,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Us',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: AppTheme.surfaceColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContactInfo(
                          context,
                          Icons.location_on,
                          '123 College Street\nCity, State 12345',
                        ),
                        const SizedBox(height: 12),
                        _buildContactInfo(
                          context,
                          Icons.phone,
                          '(123) 456-7890',
                        ),
                        const SizedBox(height: 12),
                        _buildContactInfo(
                          context,
                          Icons.email,
                          'info@college.edu',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.surfaceColor.withOpacity(0.9),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.surfaceColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.surfaceColor.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      for (var j = 0.0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
