import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:values_web_app/features/admissions/widgets/registration_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:values_web_app/features/visitor/widgets/visitor_form.dart';

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
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    items = widget.items;
    _controller = PageController();
    // Auto-rotate
    Future.delayed(const Duration(milliseconds: 500), _startAutoScroll);
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) break;
      int nextPage = (_currentPage + 1) % items.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
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
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    items[index]['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          items[index]['caption']!,
                          style: GoogleFonts.poppins(
                            color: AppTheme.surfaceColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          items[index]['description']!,
                          style: GoogleFonts.poppins(
                            color: AppTheme.surfaceColor.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
            barrierDismissible: false,
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
            _buildTeamSection(context),
            _buildAudienceLinks(context),
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
        color: AppTheme.deepNavy.withOpacity(0.95),
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
              SvgPicture.asset('assets/svgs/values_logo.svg', height: 40),
              const SizedBox(width: 16),
              Text(
                'Values Junior College',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.surfaceColor,
                ),
              ),
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
                  SvgPicture.asset(
                    'assets/svgs/values_logo.svg',
                    height: 40,
                    color: AppTheme.surfaceColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Values Junior College',
                    style: GoogleFonts.poppins(
                      color: AppTheme.surfaceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
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
          color: AppTheme.surfaceColor,
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
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Learn More',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.lavender, AppTheme.lavender.withOpacity(0.8)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 56),
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
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 280,
        height: 380,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Learn More',
                        style: GoogleFonts.poppins(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: accentColor, size: 20),
                    ],
                  ),
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
                          'Comprehensive preparation for IIT-JEE Advanced',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.engineering,
                          'JEE-Mains',
                          'Focused training for JEE Mains success',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.science,
                          'EAMCET',
                          'Expert guidance for EAMCET preparation',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.local_hospital,
                          'NEET',
                          'Specialized coaching for medical entrance',
                        ),
                        _buildProgramCard(
                          context,
                          Icons.menu_book,
                          'INTERMEDIATE (MPC/BiPC)',
                          'Strong foundation for future success',
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
                          'Specialized guidance program for NEET',
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
          height: 220,
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
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.deepNavy.withOpacity(0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                    Icon(Icons.arrow_forward, color: AppTheme.coral, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          colors: [AppTheme.deepNavy, AppTheme.deepNavy.withOpacity(0.9)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svgs/values_logo.svg',
            height: 40,
            color: AppTheme.surfaceColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Values Junior College',
            style: GoogleFonts.poppins(
              color: AppTheme.surfaceColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 24),
          if (isMobile) ...[
            _buildFooterContactItem(
              Icons.location_on,
              'Gundlabavi near Panthangi Toll plaza, National Highway No.9, Choutuppal, Nalgonda District',
              AppTheme.coral,
            ),
            const SizedBox(height: 16),
            _buildFooterContactItem(
              Icons.phone,
              'Mob: 98480 00267 / 98480 00289.',
              AppTheme.teal,
            ),
            const SizedBox(height: 16),
            _buildFooterContactItem(
              Icons.email,
              'e-mail: info@valuesacademy.in',
              AppTheme.lavender,
            ),
          ] else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFooterContactItem(
                  Icons.location_on,
                  'Gundlabavi near Panthangi Toll plaza, National Highway No.9, Choutuppal, Nalgonda District',
                  AppTheme.coral,
                ),
                const SizedBox(width: 24),
                _buildFooterContactItem(
                  Icons.phone,
                  'Mob: 98480 00267 / 98480 00289.',
                  AppTheme.teal,
                ),
                const SizedBox(width: 24),
                _buildFooterContactItem(
                  Icons.email,
                  'e-mail: info@valuesacademy.in',
                  AppTheme.lavender,
                ),
              ],
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.facebook, color: AppTheme.coral),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.alternate_email, color: AppTheme.teal),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: AppTheme.lavender),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.youtube_searched_for,
                  color: AppTheme.lightGreen,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 Values Junior College. All rights reserved.',
            style: GoogleFonts.poppins(
              color: AppTheme.surfaceColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterContactItem(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: AppTheme.surfaceColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
                ),
                _buildAdmissionsCard(
                  Icons.attach_money,
                  'Financial Aid',
                  'Explore scholarships, grants, and aid.',
                ),
                _buildAdmissionsCard(
                  Icons.event,
                  'Visit Campus',
                  'Schedule a tour or attend an info session.',
                ),
                _buildAdmissionsCard(
                  Icons.question_answer,
                  'FAQs',
                  'Find answers to common questions.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionsCard(IconData icon, String title, String desc) {
    return Card(
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
    );
  }

  // LEADERSHIP SECTION
  Widget _buildLeadershipSection(BuildContext context) {
    return Container(
      color: AppTheme.lavender,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Leadership',
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
              children: [
                _buildLeaderCard(
                  context,
                  'INDIRA GARIKAPATI',
                  'MBA (UK)\nManaging Director',
                  'Driven by dreams, guided by values\n\nIn today\'s competitive world of Education, parent and student aspirations are growing high. ... We value your aspirations with value based teaching-learning process.',
                  'assets/images/staff_indira.jpeg',
                ),
                _buildLeaderCard(
                  context,
                  'DURGA PRASAD KUNTA',
                  'B.Tech (IIT, AMIE), Dip. Gen. Medicine (USA), Dip. Child Psychology (USA), Dip. Educational Management (UK), BA Triple Maths, M.Sc. M.Phil.\nAcademic Director',
                  'Inspiring Passion to Take on Challenges\n\nValues is an initiative to provide an ideal platform for serious IIT-JEE/NEET/SAT aspirants. ... BE PART OF INNOVATION TO BECOME WORLD LEADERS',
                  'assets/images/staff_durga.jpeg',
                ),
              ],
            ),
          ],
        ),
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
              width: 600,
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
                      radius: 70,
                      backgroundImage: AssetImage(image),
                      backgroundColor: AppTheme.coral.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: AppTheme.deepNavy,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.coral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppTheme.coral,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.lavender.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.deepNavy.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
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
                      cursor: SystemMouseCursors.click,
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
                      cursor: SystemMouseCursors.click,
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
          Row(
            children: [
              Text(
                'Learn More',
                style: GoogleFonts.poppins(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: accentColor, size: 20),
            ],
          ),
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
                  'Our Expert Faculty',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppTheme.deepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Learn from the Best in the Industry',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppTheme.deepNavy.withOpacity(0.7),
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
        'image': 'assets/images/gallery_1.png',
        'caption': 'Spacious Campus Ground',
        'description':
            'Our expansive campus ground provides the perfect setting for sports, events, and outdoor activities',
      },
      {
        'image': 'assets/images/gallery_2.png',
        'caption': 'Indoor Sports & Recreation',
        'description':
            'Students enjoying various indoor games including carrom, chess, and table tennis in our recreation area',
      },
      {
        'image': 'assets/images/gallery_3.png',
        'caption': 'Comfortable Dormitories',
        'description':
            'Well-maintained dormitories providing a home-like environment for our residential students',
      },
      {
        'image': 'assets/images/gallery_4.jpeg',
        'caption': 'Student Learning Spaces',
        'description':
            'Dedicated areas for students to study, collaborate, and relax between classes',
      },
      {
        'image': 'assets/images/gallery_5.jpeg',
        'caption': 'Smart Classrooms',
        'description':
            'Modern classrooms equipped with smartboards and advanced teaching technology',
      },
      {
        'image': 'assets/images/gallery_6.jpeg',
        'caption': 'Campus Cafeteria',
        'description':
            'Spacious cafeteria serving nutritious meals in a comfortable dining environment',
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
}
