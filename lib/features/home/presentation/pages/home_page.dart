import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:values_web_app/features/admissions/widgets/registration_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:values_web_app/features/visitor/widgets/visitor_form.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class _GallerySlider extends StatefulWidget {
  final List<Map<String, String>> items;
  const _GallerySlider({required this.items});

  @override
  State<_GallerySlider> createState() => _GallerySliderState();
}

class _GallerySliderState extends State<_GallerySlider> {
  int _currentPage = 0;
  late final PageController _controller;
  late final List<Map<String, String>> items;

  @override
  void initState() {
    super.initState();
    items = widget.items;
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: items.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildImageSlide(item['image']!);
          },
        ),
        // Left Arrow
        Positioned(
          left: 16,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (_currentPage > 0) {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppTheme.surfaceColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        // Right Arrow
        Positioned(
          right: 16,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (_currentPage < items.length - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.surfaceColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        // Page Indicator
        Positioned(
          bottom: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index
                          ? AppTheme.coral
                          : AppTheme.surfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSlide(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imagePath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: AppTheme.lavender.withOpacity(0.3),
                highlightColor: AppTheme.lavender.withOpacity(0.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lavender.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppTheme.deepNavy.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.deepNavy.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.lavender.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.coral,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load image',
                        style: GoogleFonts.poppins(
                          color: AppTheme.deepNavy,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Gradient overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _academicsKey = GlobalKey();
  final GlobalKey _admissionsKey = GlobalKey();
  final GlobalKey _campusLifeKey = GlobalKey();
  final GlobalKey _newsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkVisitorStatus();
  }

  Future<void> _checkVisitorStatus() async {
    try {
      final supabase = Supabase.instance.client;
      // Try to get the visitor submission status
      await supabase.storage
          .from('visitor_preferences')
          .download('visitor_submitted.txt');
      // If we get here, the file exists, so visitor has already submitted
    } catch (e) {
      // If file doesn't exist, show the visitor form
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => const VisitorForm(),
          );
        });
      }
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildAppBar(context),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(context),
            _buildLeadershipSection(context),
            _buildVisionMissionSection(context),
            _buildAudienceLinks(context),
            _buildTeamSection(context),

            _buildStatsSection(context),
            _buildSectionWithKey(
              _academicsKey,
              _buildAcademicsSection(context),
            ),
            _buildSectionWithKey(
              _admissionsKey,
              _buildAdmissionsSection(context),
            ),
            _buildSectionWithKey(
              _campusLifeKey,
              _buildCampusLifeSection(context),
            ),
            _buildSectionWithKey(_galleryKey, _buildGallerySection(context)),
            _buildSectionWithKey(_contactKey, _buildFooter(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithKey(GlobalKey key, Widget child) {
    return Container(key: key, child: child);
  }

  // 1. Modern Sticky AppBar
  Widget _buildAppBar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              if (isMobile)
                Builder(
                  builder:
                      (context) => IconButton(
                        icon: Icon(Icons.menu, color: AppTheme.surfaceColor),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                ),
              Image.asset('assets/images/values_logo.png', height: 40),
              const SizedBox(width: 16),
              // Text(
              //   'Values Junior College',
              //   style: GoogleFonts.poppins(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 20,
              //     color: AppTheme.surfaceColor,
              //   ),
              // ),
              if (!isMobile) ...[
                const Spacer(),
                _buildNavButton(
                  context,
                  'Academics',
                  () => _scrollToSection(_academicsKey),
                ),
                _buildNavButton(
                  context,
                  'Admissions',
                  () => _scrollToSection(_admissionsKey),
                ),
                _buildNavButton(
                  context,
                  'Campus Life',
                  () => _scrollToSection(_campusLifeKey),
                ),
                _buildNavButton(
                  context,
                  'Gallery',
                  () => _scrollToSection(_galleryKey),
                ),
                _buildNavButton(
                  context,
                  'Contact',
                  () => _scrollToSection(_contactKey),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const RegistrationForm(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.coral,
                    foregroundColor: AppTheme.surfaceColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Apply Now',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppTheme.deepNavy,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.deepNavy,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.coral.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/values_logo.png', height: 40),
                  const SizedBox(height: 16),
                  // Text(
                  //   'Values Junior College',
                  //   style: GoogleFonts.poppins(
                  //     color: AppTheme.surfaceColor,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 20,
                  //   ),
                  // ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              'Academics',
              Icons.school,
              () => _scrollToSection(_academicsKey),
            ),
            _buildDrawerItem(
              context,
              'Admissions',
              Icons.how_to_reg,
              () => _scrollToSection(_admissionsKey),
            ),
            _buildDrawerItem(
              context,
              'Campus Life',
              Icons.people,
              () => _scrollToSection(_campusLifeKey),
            ),
            _buildDrawerItem(
              context,
              'Gallery',
              Icons.photo_library,
              () => _scrollToSection(_galleryKey),
            ),
            _buildDrawerItem(
              context,
              'Contact',
              Icons.contact_mail,
              () => _scrollToSection(_contactKey),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const RegistrationForm(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.coral,
                  foregroundColor: AppTheme.surfaceColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Apply Now',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.surfaceColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: AppTheme.surfaceColor, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppTheme.deepNavy,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  // 2. Hero Section
  Widget _buildHeroSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      height: isMobile ? 900 : 600,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.deepNavy, AppTheme.deepNavy.withOpacity(0.9)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/college.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child:
                  isMobile
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeroContent(context),
                          const SizedBox(height: 40),
                          _buildHeroImage(context),
                        ],
                      )
                      : Row(
                        children: [
                          Expanded(child: _buildHeroContent(context)),
                          const SizedBox(width: 60),
                          Expanded(child: _buildHeroImage(context)),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.coral.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Welcome to Values',
            style: GoogleFonts.poppins(
              color: AppTheme.coral,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Shaping Tomorrow\'s\nLeaders Today',
          style: GoogleFonts.poppins(
            color: AppTheme.surfaceColor,
            fontSize: 56,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Join our community of learners and discover your potential with our comprehensive educational programs.',
          style: GoogleFonts.poppins(
            color: AppTheme.surfaceColor.withOpacity(0.8),
            fontSize: 18,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const RegistrationForm(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.coral,
                foregroundColor: AppTheme.surfaceColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Apply Now',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 24),
            // TextButton(
            //   onPressed: () {},
            //   style: TextButton.styleFrom(
            //     foregroundColor: AppTheme.surfaceColor,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 32,
            //       vertical: 16,
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Text(
            //         'Learn More',
            //         style: GoogleFonts.poppins(
            //           fontWeight: FontWeight.w600,
            //           fontSize: 18,
            //         ),
            //       ),
            //       const SizedBox(width: 8),
            //       const Icon(Icons.arrow_forward, size: 20),
            //     ],
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        height: isMobile ? 300 : 500,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            'https://d20x1nptavktw0.cloudfront.net/wordpress_media/2022/04/Blog-Imagge.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  // 3. Audience Quick Links
  Widget _buildAudienceLinks(BuildContext context) {
    final List<Map<String, dynamic>> audiences = [
      {
        'label': 'Prospective Students',
        'icon': Icons.school,
        'description':
            'Discover our innovative programs and learning environment',
        'color': AppTheme.coral,
      },
      {
        'label': 'Parents',
        'icon': Icons.family_restroom,
        'description':
            'Learn about our values, facilities, and admission process',
        'color': AppTheme.deepNavy,
      },
      {
        'label': 'Faculty',
        'icon': Icons.badge,
        'description': 'Meet our experienced teaching professionals',
        'color': AppTheme.teal,
      },
    ];
    return Container(
      height: 700,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.lavender, AppTheme.lavender.withOpacity(0.8)],
        ),
      ),
      // padding: const EdgeInsets.symmetric(vertical: 56),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.network(
              'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/sam-mgrdichian-wrfj-SRaB1Q-unsplash.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.deepNavy.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Explore Values',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 32,
                    runSpacing: 32,
                    children:
                        audiences
                            .map(
                              (aud) => _buildAudienceCard(
                                context,
                                aud['label'] as String,
                                aud['icon'] as IconData,
                                aud['description'] as String,
                                aud['color'] as Color,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceCard(
    BuildContext context,
    String label,
    IconData icon,
    String description,
    Color accentColor,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 280,
        height: 340,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.deepNavy,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppTheme.deepNavy.withOpacity(0.7),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'Learn More',
                  //       style: GoogleFonts.poppins(
                  //         color: accentColor,
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Icon(Icons.arrow_forward, color: accentColor, size: 20),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Stats & Highlights
  Widget _buildStatsSection(BuildContext context) {
    final stats = [
      {
        'icon': Icons.workspace_premium,
        'label': 'Expert Faculty',
        'subtitle': '30+ Years Experience',
      },
      {
        'icon': Icons.science,
        'label': 'Modern Labs',
        'subtitle': 'State-of-the-art Facilities',
      },
      {
        'icon': Icons.menu_book,
        'label': 'Comprehensive Programs',
        'subtitle': 'IIT-JEE, NEET & More',
      },
      {
        'icon': Icons.architecture,
        'label': 'Innovative Learning',
        'subtitle': 'Future-Ready Education',
      },
    ];
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 40,
          runSpacing: 24,
          children:
              stats
                  .map(
                    (stat) => _buildStatCard(
                      context,
                      stat['icon'] as IconData,
                      stat['label'] as String,
                      stat['subtitle'] as String,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
  ) {
    return Card(
      color: AppTheme.lightGreen.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.deepNavy, size: 36),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.deepNavy.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Academics & Programs
  Widget _buildAcademicsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            AppTheme.deepNavy.withOpacity(1),
            AppTheme.deepNavy.withOpacity(0.1),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.coral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Explore Our Programs',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Comprehensive Education for Future Success',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppTheme.deepNavy.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'VALUES Junior College',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppTheme.coral,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 32,
                      runSpacing: 32,
                      children: [
                        _buildProgramCard(
                          context,
                          Icons.engineering,
                          'IIT-JEE',
                          'Crack IIT-JEE with in-depth concept clarity, smart strategies, and consistent test practice from our top mentors.',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.engineering,
                          'JEE-Mains',
                          'Get JEE-Mains ready with our dedicated modules, mock tests, and guidance to boost your rank and confidence.',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.science,
                          'EAMCET',
                          'Score high in EAMCET with targeted preparation, comprehensive study plans, and personalized attention.',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.local_hospital,
                          'NEET',
                          'Ace your medical entrance with expert faculty, daily practice, and doubt sessions tailored for NEET success.',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.menu_book,
                          'INTERMEDIATE (MPC/BiPC)',
                          'Build a strong foundation in Maths, Physics & Chemistry with our MPC program focused on both academics and competitive exams.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'VALUES NEET Academy',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppTheme.coral,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 32,
                      runSpacing: 32,
                      children: [
                        _buildProgramCard(
                          context,
                          Icons.school,
                          'Long Term Regular',
                          'Comprehensive NEET preparation program',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.school,
                          'Long Term SGP',
                          'Exclusive NEET batch with limited seats, advanced academics, strict eligibility, and holistic care. Seat Guarantee for top performers.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProgramDetails(
    BuildContext context,
    String label,
    String description,
    IconData icon,
  ) {
    if (label == 'Long Term SGP') {
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.coral.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: AppTheme.coral, size: 48),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppTheme.deepNavy,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Information'),
                      _buildBulletList([
                        'Only for NEET aspirants (separate batch for boys & girls, 25 students each)',
                        'Printed & digital content provided; digital content accessible in computer labs',
                        'Every third Sunday is an outing day',
                        'No major holidays except for major festivals (1-2 days)',
                      ]),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Academics'),
                      _buildBulletList([
                        'Physics & Chemistry taught to JEE Mains level for better NEET scores',
                        '36 MAT classes/year for analytical skills & speed',
                        '1.5 hrs teaching + 1.5 hrs supervised self-study per subject',
                        'Daily 1 hr "What You Need" session',
                        'High-end tech classrooms, expert faculty, audio-visual support',
                        'Seminar lectures by students (random selection)',
                      ]),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Eligibility'),
                      _buildBulletList([
                        'NEET: 350(OC), 300(BC), 250(SC/ST) in recent exam',
                        'OR 98%+ in CBSE/+2 or 100% in Intermediate theory',
                        'OR Diagnostic test: 175(OC), 150(BC), 125(SC/ST) at Values NEET Academy',
                      ]),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Rules & Regulations'),
                      _buildBulletList([
                        'No health issues that hamper work; medical issues move student to regular batch',
                        'Strict adherence to rules; 3 warnings = move to regular batch',
                        'Max 6 days absence/year (beyond with principal & faculty permission)',
                        'All tests & assignments mandatory; 5 missed assignments = move to regular batch',
                      ]),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Health Care'),
                      _buildBulletList([
                        '20 min meditation (5:40–6:00 AM)',
                        'Standard diet, healthy food, limited oil',
                        '30 min daily physical activity',
                      ]),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.coral,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.coral.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppTheme.coral, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppTheme.deepNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.lavender.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.deepNavy.withOpacity(0.8),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.coral,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildProgramCard(
    BuildContext context,
    IconData icon,
    String label,
    String description,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        color: AppTheme.lavender.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 280,
          height: 240,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.coral.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.coral, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppTheme.deepNavy,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 28),
              GestureDetector(
                onTap:
                    () =>
                        _showProgramDetails(context, label, description, icon),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.coral.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learn More',
                        style: GoogleFonts.poppins(
                          color: AppTheme.coral,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        color: AppTheme.coral,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppTheme.coral,
        ),
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: AppTheme.deepNavy.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  // 6. Student Stories / Testimonials
  Widget _buildStudentStoriesSection(BuildContext context) {
    final stories = [
      {
        'name': 'Ava Patel',
        'quote':
            'The faculty and community here helped me grow beyond my expectations.',
        'image': 'assets/images/student1.jpg',
      },
      {
        'name': 'Liam Chen',
        'quote': 'I found my passion and lifelong friends at CollegeName.',
        'image': 'assets/images/student2.jpg',
      },
      {
        'name': 'Sophia Garcia',
        'quote': 'The opportunities for research and leadership are unmatched.',
        'image': 'assets/images/student3.jpg',
      },
    ];
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Student Stories',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 32,
              children:
                  stories
                      .map(
                        (story) => _buildStoryCard(
                          context,
                          story['name'] as String,
                          story['quote'] as String,
                          story['image'] as String,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(
    BuildContext context,
    String name,
    String quote,
    String imagePath,
  ) {
    return Card(
      color: AppTheme.lightGreen.withOpacity(0.7),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(backgroundImage: AssetImage(imagePath), radius: 36),
            const SizedBox(height: 16),
            Text(
              '“$quote”',
              style: GoogleFonts.poppins(
                fontStyle: FontStyle.italic,
                color: AppTheme.deepNavy,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '- $name',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. Campus Life
  Widget _buildCampusLifeSection(BuildContext context) {
    final campusLife = [
      {'icon': Icons.sports_basketball, 'label': 'Sports & Fitness'},
      {'icon': Icons.music_note, 'label': 'Arts & Culture'},
      {'icon': Icons.volunteer_activism, 'label': 'Clubs & Volunteering'},
      {'icon': Icons.nature_people, 'label': 'Outdoor Activities'},
    ];
    return Container(
      color: AppTheme.lavender,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Campus Life',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 32,
              children:
                  campusLife
                      .map(
                        (item) => _buildCampusLifeCard(
                          context,
                          item['icon'] as IconData,
                          item['label'] as String,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusLifeCard(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.coral, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.deepNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 8. News & Events
  Widget _buildNewsSection(BuildContext context) {
    final news = [
      {
        'title': 'New Research Center Opens',
        'desc':
            'Our new research center is now open, featuring advanced labs for AI and biotech.',
        'image': 'assets/images/news1.jpg',
      },
      {
        'title': 'Student Wins National Award',
        'desc':
            'Congratulations to our student for winning a national innovation award!',
        'image': 'assets/images/news2.jpg',
      },
      {
        'title': 'Sustainability Initiative',
        'desc':
            'Campus-wide sustainability program launched with solar power and green buildings.',
        'image': 'assets/images/news3.jpg',
      },
    ];
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'News & Events',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 32,
              children:
                  news
                      .map(
                        (item) => _buildNewsCard(
                          context,
                          item['title'] as String,
                          item['desc'] as String,
                          item['image'] as String,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(
    BuildContext context,
    String title,
    String desc,
    String imagePath,
  ) {
    return SizedBox(
      width: 320,
      height: 221,
      child: Card(
        color: AppTheme.lavender,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  color: AppTheme.deepNavy.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: AppTheme.coral),
                child: const Text('Read More'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 9. Big CTA Section
  Widget _buildBigCTASection(BuildContext context) {
    return Container(
      color: AppTheme.coral,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Ready to Start Your Journey?',
              style: GoogleFonts.poppins(
                color: AppTheme.surfaceColor,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const RegistrationForm(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                foregroundColor: AppTheme.coral,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Start Your Application',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 10. Footer
  Widget _buildFooter(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.deepNavy, AppTheme.deepNavy.withOpacity(0.95)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/images/values_logo.png',
                  height: 48,
                  color: AppTheme.surfaceColor,
                ),
              ),
              const SizedBox(height: 40),
              if (isMobile)
                _buildCombinedContactBox([
                  {
                    'icon': Icons.location_on,
                    'text':
                        'Gundlabavi near Panthangi Toll plaza, National Highway No.9, Choutuppal, Nalgonda District',
                    'color': AppTheme.coral,
                  },
                  {
                    'icon': Icons.phone,
                    'text': 'Mob: 98480 00267 / 98480 00289',
                    'color': AppTheme.teal,
                  },
                  {
                    'icon': Icons.email,
                    'text': 'e-mail: info@valuesacademy.in',
                    'color': AppTheme.lavender,
                  },
                ])
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.deepNavy.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.surfaceColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: _buildCombinedContactBox([
                    {
                      'icon': Icons.location_on,
                      'text':
                          'Gundlabavi near Panthangi Toll plaza, National Highway No.9, Choutuppal, Nalgonda District',
                      'color': AppTheme.coral,
                    },
                    {
                      'icon': Icons.phone,
                      'text': 'Mob: 98480 00267 / 98480 00289',
                      'color': AppTheme.teal,
                    },
                    {
                      'icon': Icons.email,
                      'text': 'e-mail: info@valuesacademy.in',
                      'color': AppTheme.lavender,
                    },
                  ]),
                ),
              const SizedBox(height: 56),
              // Social Media Links
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.surfaceColor.withOpacity(0.1),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: AppTheme.surfaceColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialMediaButton(
                      context,
                      "assets/images/facebook.png",
                      'https://www.facebook.com/valuesacademyjrcollege',
                      AppTheme.coral,
                    ),
                    const SizedBox(width: 24),
                    _buildSocialMediaButton(
                      context,
                      "assets/images/instagram.png",
                      'https://www.instagram.com/academyvalues/',
                      AppTheme.teal,
                    ),
                    const SizedBox(width: 24),
                    _buildSocialMediaButton(
                      context,
                      "assets/images/youtube.png",
                      'https://www.youtube.com/@Valuesjuniorcollege',
                      AppTheme.lavender,
                    ),
                    const SizedBox(width: 24),
                    _buildSocialMediaButton(
                      context,
                      "assets/images/linkedin.png",
                      'https://www.linkedin.com/in/values-academy-aa122b365/',
                      AppTheme.deepNavy,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.surfaceColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copyright,
                      color: AppTheme.surfaceColor.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateTime.now().year} Values Junior College. All rights reserved.',
                      style: GoogleFonts.poppins(
                        color: AppTheme.surfaceColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedContactBox(List<Map<String, dynamic>> items) {
    return Column(
      children:
          items.map((item) {
            final isLast = items.last == item;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (item['color'] as Color).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SelectableText(
                          item['text'] as String,
                          style: GoogleFonts.poppins(
                            color: AppTheme.surfaceColor,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            );
          }).toList(),
    );
  }

  // Admissions Section (new)
  Widget _buildAdmissionsSection(BuildContext context) {
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Admissions',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Join a vibrant, diverse, and supportive community. Discover our admissions process, requirements, and financial aid options.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppTheme.deepNavy.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 32,
              children: [
                _buildAdmissionsCard(
                  Icons.assignment_turned_in,
                  'How to Apply',
                  'Step-by-step guide to your application.',
                  true,
                ),
                _buildAdmissionsCard(
                  Icons.attach_money,
                  'Financial Aid',
                  'Explore scholarships, grants, and aid.',
                  false,
                ),
                _buildAdmissionsCard(
                  Icons.event,
                  'Visit Campus',
                  'Schedule a tour or attend an info session.',
                  false,
                ),
                // _buildAdmissionsCard(
                //   Icons.question_answer,
                //   'FAQs',
                //   'Find answers to common questions.',
                //   false,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionsCard(
    IconData icon,
    String title,
    String desc,
    bool isTappable,
  ) {
    return GestureDetector(
      onTap:
          isTappable
              ? () => showDialog(
                context: context,
                builder: (context) => const RegistrationForm(),
              )
              : null,
      child: Card(
        color: AppTheme.lavender,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 260,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppTheme.coral, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.deepNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: AppTheme.deepNavy.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // LEADERSHIP SECTION
  Widget _buildLeadershipSection(BuildContext context) {
    return Container(
      height: 600,
      width: double.infinity,
      color: AppTheme.lavender,
      // padding: const EdgeInsets.symmetric(vertical: 56),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.network(
              'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/background/aswin-thomas-bony-SPO0ST4nVbY-unsplash.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.deepNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Leadership',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: AppTheme.deepNavy,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 32,
                  runSpacing: 32,
                  children: [
                    _buildLeaderCard(
                      context,
                      'INDIRA GARIKAPATI',
                      'MBA (UK)\nManaging Director',
                      '''Driven by dreams, guided by values
          
          
          In today's competitive world of Education, parent and student aspirations are growing high. Taking advantage of these aspirants, many educational institutions are exploiting the situation and running junior colleges with almost zero quality while charging high fee, low teaching standards in an atmosphere of congession.
          
          Moreover, students living away from bigger cities have to move to distant colleges and stay in hostels, completely unaware that they are risking their academic future and health. Most shockingly, most of them are not successful in getting desired seats and above all losing their health, mental peace, and confidence. I see there is no respect from those colleges towords the desires and aspirations of parents and students. After looking at these desperate situations, we have decided to give value and respect towards the academic goals and aspirations of parents and their children, along with giving them:
          
          • Good environment at hostel
          • Facilities for physical activities for strong health
          • Meditation for sound mind enabling them to achieve their goals
          
          We have established "VALUES Jr. College and NEET Academy" at Gundlabavi near Panthangi Toll plaza, National Higway No.9, Choutuppal, Nalgonda District in 5 acres of land with ultra modern facilities and students taught by india's top most faculty who have proven track record of result and meticulously planned academic program at affordable fee.
          
          I strongly belive every student can achieve their goals provided their inner talents are extracted in a serene atmosphere, academic performance, subjects to healthy mind and body. Happy minds are highly successful. A child with values is more deciplined, determined in achieving goals.
          
          
          "We value your aspirations with value based teaching- learning process"''',
                      'assets/images/staff_indira.jpeg',
                    ),
                    _buildLeaderCard(
                      context,
                      'DURGA PRASAD KUNTA',
                      'B.Tech (IIT, AMIE), Dip. Gen. Medicine (USA), Dip. Child Psychology (USA), Dip. Educational Management (UK), BA Triple Maths, M.Sc. M.Phil.\nAcademic Director',
                      '''Inspiring Passion to Take on Challenges
          
          
          Values is an initiative to provide an ideal platform for serious IIT-JEE/NEET/SAT aspirants. It has highly experienced academicians at the helm and a great pool of talented teachers and administrators supported by software experts and educationists.
          
          Our aim is to make the child learn with interest and without external pressure. We encourage child to have mental and physical growth for better understanding of subjects and performance. When the urge to learn and do well comes from within, it will be more productive.
          
          We strongly believe by providing:
          • Serene atmosphere
          • Unconditional support and encouragement
          • Continuous motivation while bringing out inner talent
          
          This enables the child to give their best and perform to their utmost potential.
          
          Every child is unique in their own way and should not be compared with others. They should create their targets and work for achieving them as this is continuous process of their life. It's tough for any human being to keep in continuous pace with the need of the hour, hence they need to be:
          • Observed
          • Guided
          • Supported
          • Directed
          • Motivated
          • Balanced in leading their life
          
          If we can understand the limitations of the child in identifying their abilities and guide them accordingly, he/she will show inherent talent and will exhibit them. They just need to be said "You are the best and we are there with you" - rest is all their time.
          
          
          Good News to student community and parents:
          
          It is made to strongly believe by few institutes and individuals that it needs lot of hardwork and spend tough time to achieve big scores and ranks in competitive examinations like IIT-JEE/NEET/AIIMS/AIPMT/AFMC/SAT etc. But our experience says otherwise:
          
          We have produced:
          • Many single digits ranks
          • Double digit ranks
          • Triple digit ranks
          • Seat getting ranks
          
          In all competitive examinations like IIT-JEE/NEET/AIIMS/AIPMT/AFMC/SAT etc., with smart work and entry into top 100 universities of the world. Few of our students have joined universities like MIT/Harvard/Pennsylvania with the best scores and with the scholarships which remained as a dream for many - all achieved with smart work while enjoying the basic needs of life and all the joyful moments of student life.
          
          
          "BE PART OF INNOVATION TO BECOME WORLD LEADERS"''',
                      'assets/images/staff_durga.jpeg',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderCard(
    BuildContext context,
    String name,
    String title,
    String message,
    String image,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showLeaderDetails(context, name, title, message, image),
        child: Card(
          color: AppTheme.surfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 400,
            height: 320,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.coral.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(image),
                      backgroundColor: AppTheme.coral.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppTheme.deepNavy,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.coral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppTheme.coral,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLeaderDetails(
    BuildContext context,
    String name,
    String title,
    String message,
    String image,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.coral.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(image),
                      backgroundColor: AppTheme.coral.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.deepNavy,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 24,
                  //     vertical: 12,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: AppTheme.coral.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(24),
                  //   ),
                  //   child: Text(
                  //     title,
                  //     style: GoogleFonts.poppins(
                  //       color: AppTheme.coral,
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  const SizedBox(height: 28),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 315,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.lavender.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        message,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.deepNavy,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.coral,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // VISION & MISSION SECTION
  Widget _buildVisionMissionSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightGreen.withOpacity(0.2),
            AppTheme.lightGreen.withOpacity(0.05),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.coral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Our Vision & Mission',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Shaping Tomorrow\'s Leaders Today',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppTheme.deepNavy.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 60),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.basic,
                      child: _buildVisionMissionCard(
                        context,
                        'Vision',
                        'To be a leading educational institution that nurtures future leaders and innovators through excellence in education and character building.',
                        Icons.visibility,
                        AppTheme.coral,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.basic,
                      child: _buildVisionMissionCard(
                        context,
                        'Mission',
                        'To provide world-class education that combines academic excellence with holistic development, preparing students for success in competitive exams and life.',
                        Icons.flag,
                        AppTheme.deepNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisionMissionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color accentColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.deepNavy.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // Row(
          //   children: [
          //     Text(
          //       'Learn More',
          //       style: GoogleFonts.poppins(
          //         color: accentColor,
          //         fontWeight: FontWeight.w600,
          //         fontSize: 16,
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     Icon(Icons.arrow_forward, color: accentColor, size: 20),
          //   ],
          // ),
        ],
      ),
    );
  }

  // HIGH RESULT ORIENTED TEAM SECTION
  Widget _buildTeamSection(BuildContext context) {
    final team = [
      {
        'name': 'DURGA PRASAD KUNTA',
        'role': 'Academic Director & Sr. Faculty in Math',
        'exp': '32+ Years experience',
        'achievements':
            'Produced AIR 1 in IIT-JEE (4 times), 5100 IIT selections, 2100 Medical selections, 168 NDA Cadets.',
        'image': 'assets/images/staff_durga.jpeg',
      },
      {
        'name': 'Dr. M. SATYAMURTHY',
        'role': 'Sr. Physics Faculty',
        'exp': '30 Years experience',
        'achievements':
            'Produced AIR IIT JEE -35 (Dushant), AIR NEET-7 (P.Praveen Kumar), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_satyamurthy.jpeg',
      },
      {
        'name': 'C. NARAYANA SHANKAR',
        'role': 'Sr. Physics Faculty',
        'exp': '30 Years experience',
        'achievements':
            'Produced AIR 5 in NEET 2024 (Avinash), AIR 1 in JEE 2024 (Mukund), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_narayana.jpeg',
      },
      {
        'name': 'SANTHOSH KUMAR JHA',
        'role': 'Sr. Botany Faculty',
        'exp': '28 Years experience',
        'achievements':
            'Produced AIR 4 in NEET (Sourabh kumar), AIR 9 in AIIMS (Kaustab Majumdar), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_santhosh.jpeg',
      },
      {
        'name': 'V. VENKATESWARA RAO',
        'role': 'Sr. Chemistry Faculty',
        'exp': '23 Years experience',
        'achievements':
            'Produced AIR 44 in IIT-JEE (Shravan Kumar), NEET 137 (Reshma), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_venkateswara.jpeg',
      },
      {
        'name': 'Ashish Kumar',
        'role': 'Sr. Chemistry Faculty',
        'exp': '20 Years experience',
        'achievements':
            'Produced AIR 1 in JEE (Sandeep Pathra), AIR 4 in NEET (Sourabh kumar), AIR 9 in AIIMS (Kaustab Majumdar), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_ashish.jpeg',
      },
      {
        'name': 'K. SATISH KUMAR',
        'role': 'Sr. Botany Faculty',
        'exp': '19 Years experience',
        'achievements':
            'Produced AIR 9 in NEET 2024 (N.H.Prasanna), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_satish.jpeg',
      },
      {
        'name': 'SANDULA MOHANA KRISHNA',
        'role': 'Sr. Zoology Faculty',
        'exp': '18 Years experience',
        'achievements':
            'Produced AIR 4 in NEET 2020 (Vineet Sharma), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_sandula.jpeg',
      },
      {
        'name': 'K. SWAROOPA',
        'role': 'Sr. Zoology Faculty',
        'exp': '18 Years experience',
        'achievements':
            'Produced AIR 9 in NEET 2024 (N.H.Prasanna), Many more ranks below AIR 100.',
        'image': 'assets/images/staff_swaroopa.jpeg',
      },
    ];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepNavy.withOpacity(1),
            AppTheme.lavender.withOpacity(0.1),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Our Expert Faculty',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppTheme.surfaceColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Learn from the Best in the Industry',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppTheme.surfaceColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 60),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                runSpacing: 32,
                children:
                    team
                        .map(
                          (member) => _buildTeamCard(
                            context,
                            member['name']!,
                            member['role']!,
                            member['exp']!,
                            member['achievements']!,
                            member['image']!,
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    String name,
    String role,
    String exp,
    String achievements,
    String image,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap:
            () => _showTeamMemberDetails(
              context,
              name,
              role,
              exp,
              achievements,
              image,
            ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 280,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: AppTheme.surfaceColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.coral.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              role,
                              style: GoogleFonts.poppins(
                                color: AppTheme.surfaceColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          color: AppTheme.coral,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Experience',
                          style: GoogleFonts.poppins(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exp,
                      style: GoogleFonts.poppins(
                        color: AppTheme.deepNavy.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: AppTheme.coral,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Achievements',
                          style: GoogleFonts.poppins(
                            color: AppTheme.deepNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievements,
                      style: GoogleFonts.poppins(
                        color: AppTheme.deepNavy.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeamMemberDetails(
    BuildContext context,
    String name,
    String role,
    String exp,
    String achievements,
    String image,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.coral.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(image),
                      backgroundColor: AppTheme.coral.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppTheme.deepNavy,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.coral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      role,
                      style: GoogleFonts.poppins(
                        color: AppTheme.coral,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.lavender.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 20,
                              color: AppTheme.deepNavy.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              exp,
                              style: GoogleFonts.poppins(
                                color: AppTheme.deepNavy.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 20,
                              color: AppTheme.deepNavy.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                achievements,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.deepNavy.withOpacity(0.7),
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.coral,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    final List<Map<String, String>> galleryItems = [
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/DSC_0078.JPG',
        'caption': 'Campus Life',
        'description':
            'Experience the vibrant campus life at Values Junior College',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/DSC_0079.JPG',
        'caption': 'Learning Environment',
        'description':
            'Modern classrooms designed for optimal learning experience',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/tra-nguyen-TVSRWmnW8Us-unsplash.jpg',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/WhatsApp%20Image%202025-05-21%20at%2011.12.55%20AM.jpeg',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/college.png',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/gallery_1.png',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/gallery_2.png',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/gallery_3.png',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/gallery_4.jpeg',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/gallery_5.jpeg',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
      {
        'type': 'image',
        'image':
            'https://vswnpmyjvwpidoxfneed.supabase.co/storage/v1/object/public/images/gallery/gallery_6.jpeg',
        'caption': 'Campus Facilities',
        'description': 'Explore our world-class infrastructure and amenities',
      },
    ];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lavender.withOpacity(0.3),
            AppTheme.lavender.withOpacity(0.1),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.coral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Campus Gallery',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Explore Our World-Class Facilities',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppTheme.deepNavy.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(height: 500, child: _GallerySlider(items: galleryItems)),
              const SizedBox(height: 40),
              // Wrap(
              //   alignment: WrapAlignment.center,
              //   spacing: 16,
              //   runSpacing: 16,
              //   children:
              //       galleryItems
              //           .map(
              //             (item) => _buildGalleryThumbnail(
              //               context,
              //               item['image']!,
              //               item['caption']!,
              //             ),
              //           )
              //           .toList(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryThumbnail(
    BuildContext context,
    String image,
    String caption,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  caption,
                  style: GoogleFonts.poppins(
                    color: AppTheme.surfaceColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchSocialMedia(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open the link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSocialMediaButton(
    BuildContext context,
    String icon,
    String url,
    Color color,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchSocialMedia(url),
        child: Image.asset(icon, width: 42, height: 42),
      ),
    );
  }
}
