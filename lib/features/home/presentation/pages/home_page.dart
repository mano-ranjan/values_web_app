import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:values_web_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:values_web_app/shared/widgets/responsive_app_bar.dart';
import 'package:values_web_app/shared/widgets/hero_section.dart';
import 'package:values_web_app/shared/widgets/vision_mission_section.dart';
import 'package:values_web_app/shared/widgets/faculty_card.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:values_web_app/shared/widgets/news_card.dart';
import 'package:values_web_app/shared/widgets/contact_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedMenuItem = 'Home';
  final List<String> _menuItems = [
    'Home',
    'About',
    'Academics',
    'Admissions',
    'Faculty',
    'Contact',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      appBar: ResponsiveAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        menuItems: _menuItems,
        selectedItem: _selectedMenuItem,
        onMenuItemTap: (item) => setState(() => _selectedMenuItem = item),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeroSection(),
            const VisionMissionSection(),
            _buildFacultySection(),
            _buildNewsSection(),
            _buildContactSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Values Junior College',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ..._menuItems.map(
            (item) => ListTile(
              title: Text(item),
              selected: item == _selectedMenuItem,
              selectedColor: AppTheme.primary,
              selectedTileColor: AppTheme.primary.withOpacity(0.1),
              onTap: () {
                setState(() => _selectedMenuItem = item);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultySection() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Meet Our Faculty',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Learn from experienced educators dedicated to your success',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isMobile ? 16 : 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              FacultyCard(
                name: 'Dr. Sarah Johnson',
                role: 'Principal, Physics Professor',
                imageUrl: 'assets/images/faculty/sarah.jpg',
                experience: '25',
                qualification: 'Ph.D. in Physics',
                description:
                    'Dr. Johnson brings 25 years of academic excellence and leadership to our institution.',
                onTap: () {},
              ),
              FacultyCard(
                name: 'Prof. Michael Chen',
                role: 'Mathematics Department Head',
                imageUrl: 'assets/images/faculty/michael.jpg',
                experience: '18',
                qualification: 'M.Sc. in Mathematics',
                description:
                    'An expert in advanced mathematics with a passion for making complex concepts simple.',
                onTap: () {},
              ),
              FacultyCard(
                name: 'Dr. Emily Brown',
                role: 'Chemistry Professor',
                imageUrl: 'assets/images/faculty/emily.jpg',
                experience: '20',
                qualification: 'Ph.D. in Chemistry',
                description:
                    'Specializes in organic chemistry and has published numerous research papers.',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () {},
            child: const Text('View All Faculty'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 80,
      ),
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.02)),
      child: Column(
        children: [
          Text(
            'Latest News',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Stay updated with the latest happenings at Values Junior College',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isMobile ? 16 : 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              NewsCard(
                title: 'Outstanding Results in IIT-JEE 2024',
                description:
                    'Our students have achieved remarkable success in IIT-JEE 2024, with 85% securing ranks under 10,000. Special mention to Arjun Kumar for securing AIR 45.',
                imageUrl: 'assets/images/news/iit_results.jpg',
                date: 'March 15, 2024',
                category: 'Academic Excellence',
                onTap: () {},
              ),
              NewsCard(
                title: 'New Science Lab Inauguration',
                description:
                    'State-of-the-art Physics and Chemistry laboratories inaugurated, featuring advanced equipment and modern facilities to enhance practical learning experience.',
                imageUrl: 'assets/images/news/new_lab.jpg',
                date: 'March 10, 2024',
                category: 'Infrastructure',
                onTap: () {},
              ),
              NewsCard(
                title: 'National Science Day Celebration',
                description:
                    'Students showcased innovative projects at our National Science Day celebration, with special guest lectures from renowned scientists.',
                imageUrl: 'assets/images/news/science_day.jpg',
                date: 'February 28, 2024',
                category: 'Events',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 48),
          OutlinedButton(onPressed: () {}, child: const Text('View All News')),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Get in Touch',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Have questions? We\'re here to help!',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: isMobile ? 16 : 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile) ...[
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactInfo(
                        icon: Icons.location_on_outlined,
                        title: 'Visit Us',
                        content:
                            'Gundlabavi near Panthangi Toll plaza,\nNational Highway No.9,\nChoutuppal, Nalgonda District',
                      ),
                      const SizedBox(height: 32),
                      _buildContactInfo(
                        icon: Icons.phone_outlined,
                        title: 'Call Us',
                        content: '+91 98480 00267\n+91 98480 00289',
                      ),
                      const SizedBox(height: 32),
                      _buildContactInfo(
                        icon: Icons.email_outlined,
                        title: 'Email Us',
                        content:
                            'info@valuesacademy.in\nadmissions@valuesacademy.in',
                      ),
                      const SizedBox(height: 32),
                      _buildContactInfo(
                        icon: Icons.access_time,
                        title: 'Office Hours',
                        content: 'Monday - Saturday\n9:00 AM - 5:00 PM',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
              ],
              Expanded(flex: 3, child: const ContactForm()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      color: AppTheme.primary,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 40,
                color: Colors.white,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.facebook, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.alternate_email,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.business_center,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} Values Junior College. All rights reserved.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
