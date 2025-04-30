import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';

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
                  borderRadius: BorderRadius.circular(16),
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
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      items[index]['caption']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          bottom: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index
                          ? AppTheme.coral
                          : AppTheme.lavender,
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

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey _academicsKey = GlobalKey();
  final GlobalKey _admissionsKey = GlobalKey();
  final GlobalKey _campusLifeKey = GlobalKey();
  final GlobalKey _newsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

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
            _buildSectionWithKey(_newsKey, _buildNewsSection(context)),
            _buildStudentStoriesSection(context),
            _buildBigCTASection(context),
            _buildFooter(context),
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
    return AppBar(
      backgroundColor: AppTheme.deepNavy.withOpacity(0.85),
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 56,
      title: Row(
        children: [
          const SizedBox(width: 16),
          SvgPicture.asset('assets/svgs/values_logo.svg', height: 32),
          const SizedBox(width: 12),
          Text(
            'Values Junior College',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.surfaceColor,
            ),
          ),
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
          _buildNavButton(context, 'News', () => _scrollToSection(_newsKey)),
          // _buildNavButton(
          //   context,
          //   'Contact',
          //   () => _scrollToSection(_contactKey),
          // ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.coral,
              foregroundColor: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Apply'),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.surfaceColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  // 2. Hero Section
  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 480,
          width: double.infinity,
          child: Image.asset('assets/images/college.png', fit: BoxFit.cover),
        ),
        Container(
          height: 480,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.deepNavy.withOpacity(0.7),
                AppTheme.deepNavy.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Driven by dreams, guided by values',
                  style: TextStyle(
                    color: AppTheme.surfaceColor,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  'We, the pioneers of academic excellence in education, strive to work towards the betterment of the society by igniting the young minds to realize their full potential and bestowing them with the qualities which transform them into global leaders of future generations.',
                  style: TextStyle(
                    color: AppTheme.surfaceColor.withOpacity(0.92),
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.coral,
                        foregroundColor: AppTheme.surfaceColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Apply Now'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.surfaceColor,
                        side: BorderSide(
                          color: AppTheme.surfaceColor,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Visit Campus'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Audience Quick Links
  Widget _buildAudienceLinks(BuildContext context) {
    final List<Map<String, dynamic>> audiences = [
      {'label': 'Prospective Students', 'icon': Icons.school},
      {'label': 'Current Students', 'icon': Icons.people},
      {'label': 'Alumni', 'icon': Icons.emoji_events},
      {'label': 'Parents', 'icon': Icons.family_restroom},
      {'label': 'Faculty & Staff', 'icon': Icons.badge},
    ];
    return Container(
      color: AppTheme.lavender,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 32,
          runSpacing: 24,
          children:
              audiences
                  .map(
                    (aud) => _buildAudienceCard(
                      context,
                      aud['label'] as String,
                      aud['icon'] as IconData,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildAudienceCard(BuildContext context, String label, IconData icon) {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.coral, size: 36),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.deepNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Stats & Highlights
  Widget _buildStatsSection(BuildContext context) {
    final stats = [
      {'icon': Icons.workspace_premium, 'label': '98% Job Placement'},
      {'icon': Icons.science, 'label': '#1 in Research'},
      {'icon': Icons.menu_book, 'label': '150+ Programs'},
      {'icon': Icons.public, 'label': 'Diverse Community'},
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
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label) {
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
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.deepNavy,
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
      color: AppTheme.lavender,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Explore Our Programs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'VALUES Junior College',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.coral,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 32,
              children: [
                _buildProgramCard(context, Icons.engineering, 'IIT-JEE'),
                _buildProgramCard(context, Icons.engineering, 'JEE-Mains'),
                _buildProgramCard(context, Icons.science, 'EAMCET'),
                _buildProgramCard(context, Icons.local_hospital, 'NEET'),
                _buildProgramCard(
                  context,
                  Icons.menu_book,
                  'INTERMEDIATE (MPC/BiPC)',
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'VALUES NEET Academy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.coral,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 32,
              children: [
                _buildProgramCard(context, Icons.school, 'Long Term Regular'),
                _buildProgramCard(context, Icons.school, 'Long Term SGP'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, IconData icon, String label) {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.coral, size: 36),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.coral,
                  side: BorderSide(color: AppTheme.coral, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Learn More'),
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
              style: TextStyle(
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
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppTheme.deepNavy,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '- $name',
              style: TextStyle(
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
              style: TextStyle(
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
              style: TextStyle(
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
              style: TextStyle(
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.8)),
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
              style: TextStyle(
                color: AppTheme.surfaceColor,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
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
              child: const Text(
                'Start Your Application',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 10. Footer
  Widget _buildFooter(BuildContext context) {
    return Container(
      color: AppTheme.deepNavy,
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
            style: TextStyle(
              color: AppTheme.surfaceColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          // Wrap(
          //   alignment: WrapAlignment.center,
          //   spacing: 32,
          //   children: [
          //     _buildFooterLink('About'),
          //     _buildFooterLink('Academics'),
          //     _buildFooterLink('Admissions'),
          //     _buildFooterLink('Campus Life'),
          //     _buildFooterLink('News'),
          //     _buildFooterLink('Contact'),
          //   ],
          // ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppTheme.surfaceColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Gundlabavi near Panthangi Toll plaza, National Highway No.9, Choutuppal, Nalgonda District',
                style: TextStyle(color: AppTheme.surfaceColor.withOpacity(0.8)),
              ),
              const SizedBox(width: 24),
              Icon(Icons.phone, color: AppTheme.surfaceColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mob: 98480 00267 / 98480 00289.',
                style: TextStyle(color: AppTheme.surfaceColor.withOpacity(0.8)),
              ),
              const SizedBox(width: 24),
              Icon(Icons.email, color: AppTheme.surfaceColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'e-mail: info@valuesacademy.in',
                style: TextStyle(color: AppTheme.surfaceColor.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.facebook, color: AppTheme.surfaceColor),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.alternate_email, color: AppTheme.surfaceColor),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: AppTheme.surfaceColor),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.youtube_searched_for,
                  color: AppTheme.surfaceColor,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 Values Junior College. All rights reserved.',
            style: TextStyle(color: AppTheme.surfaceColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return TextButton(
      onPressed: () {},
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.surfaceColor,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Join a vibrant, diverse, and supportive community. Discover our admissions process, requirements, and financial aid options.',
              style: TextStyle(
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.8)),
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
              style: TextStyle(
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
                ),
                _buildLeaderCard(
                  context,
                  'DURGA PRASAD KUNTA',
                  'B.Tech (IIT, AMIE), Dip. Gen. Medicine (USA), Dip. Child Psychology (USA), Dip. Educational Management (UK), BA Triple Maths, M.Sc. M.Phil.\nAcademic Director',
                  'Inspiring Passion to Take on Challenges\n\nValues is an initiative to provide an ideal platform for serious IIT-JEE/NEET/SAT aspirants. ... BE PART OF INNOVATION TO BECOME WORLD LEADERS',
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
  ) {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.coral.withOpacity(0.2),
                child: Icon(Icons.person, size: 40, color: AppTheme.coral),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.deepNavy.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: AppTheme.deepNavy, fontSize: 15),
                textAlign: TextAlign.left,
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
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Vision & Mission',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Vision',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.coral,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We, the pioneers of academic excellence in education, strive to work towards the betterment of the society by igniting the young minds to realize their full potential and bestowing them with the qualities which transform them into global leaders of future generations. The ambitions of parents and the dreams of students will be realized with well designed and scientific methods of "VALUES JUNIOR COLLEGE" through well trained and dedicated faculty.',
              style: TextStyle(fontSize: 16, color: AppTheme.deepNavy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Mission',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.coral,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We aim at providing education which enables learners to have great focus, excellent communication, true leadership qualities, parallel thinking, pro-active approach, positive attitude and ability to manage failure and stress. Communication skills are the most powerful tools to conquer the world and make human a world leader. Learning is to understand the concepts and not byhearting the sentences.',
              style: TextStyle(fontSize: 16, color: AppTheme.deepNavy),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      },
      {
        'name': 'Dr. M. SATYAMURTHY',
        'role': 'Sr. Physics Faculty',
        'exp': '30 Years experience',
        'achievements':
            'Produced AIR IIT JEE -35 (Dushant), AIR NEET-7 (P.Praveen Kumar), Many more ranks below AIR 100.',
      },
      {
        'name': 'C. NARAYANA SHANKAR',
        'role': 'Sr. Physics Faculty',
        'exp': '30 Years experience',
        'achievements':
            'Produced AIR 5 in NEET 2024 (Avinash), AIR 1 in JEE 2024 (Mukund), Many more ranks below AIR 100.',
      },
      {
        'name': 'Ashish Kumar',
        'role': 'Sr. Chemistry Faculty',
        'exp': '20 Years experience',
        'achievements':
            'Produced AIR 1 in JEE (Sandeep Pathra), AIR 4 in NEET (Sourabh kumar), AIR 9 in AIIMS (Kaustab Majumdar), Many more ranks below AIR 100.',
      },
      {
        'name': 'V. VENKATESWARA RAO',
        'role': 'Sr. Chemistry Faculty',
        'exp': '23 Years experience',
        'achievements':
            'Produced AIR 44 in IIT-JEE (Shravan Kumar), NEET 137 (Reshma), Many more ranks below AIR 100.',
      },
      {
        'name': 'SANTHOSH KUMAR JHA',
        'role': 'Sr. Botany Faculty',
        'exp': '28 Years experience',
        'achievements':
            'Produced AIR 4 in NEET (Sourabh kumar), AIR 9 in AIIMS (Kaustab Majumdar), Many more ranks below AIR 100.',
      },
      {
        'name': 'K. SATISH KUMAR',
        'role': 'Sr. Botany Faculty',
        'exp': '19 Years experience',
        'achievements':
            'Produced AIR 9 in NEET 2024 (N.H.Prasanna), Many more ranks below AIR 100.',
      },
      {
        'name': 'SANDULA MOHANA KRISHNA',
        'role': 'Sr. Zoology Faculty',
        'exp': '18 Years experience',
        'achievements':
            'Produced AIR 4 in NEET 2020 (Vineet Sharma), Many more ranks below AIR 100.',
      },
      {
        'name': 'K. SWAROOPA',
        'role': 'Sr. Zoology Faculty',
        'exp': '18 Years experience',
        'achievements':
            'Produced AIR 9 in NEET 2024 (N.H.Prasanna), Many more ranks below AIR 100.',
      },
    ];
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Our High Result Oriented Team',
              style: TextStyle(
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
                  team
                      .map(
                        (member) => _buildTeamCard(
                          context,
                          member['name']!,
                          member['role']!,
                          member['exp']!,
                          member['achievements']!,
                        ),
                      )
                      .toList(),
            ),
          ],
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
  ) {
    return Card(
      color: AppTheme.lavender,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role,
              style: TextStyle(
                color: AppTheme.deepNavy.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Experience: $exp',
              style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              'Achievements: $achievements',
              style: TextStyle(color: AppTheme.deepNavy.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    final List<Map<String, String>> galleryItems = [
      {
        'image': 'assets/images/gallery_1.png',
        'caption': 'Modern Classrooms & Learning Spaces',
      },
      {
        'image': 'assets/images/gallery_2.png',
        'caption': 'State-of-the-art Science Labs',
      },
      {
        'image': 'assets/images/gallery_3.png',
        'caption': 'Vibrant Student Life & Activities',
      },
      {
        'image': 'assets/images/gallery_4.jpeg',
        'caption': 'Serene Campus Environment',
      },
      {
        'image': 'assets/images/gallery_5.jpeg',
        'caption': 'Sports and Recreation Facilities',
      },
      {
        'image': 'assets/images/gallery_6.jpeg',
        'caption': 'Events and Celebrations',
      },
    ];
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Column(
          children: [
            Text(
              'Gallery',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 440,
              width: 900,
              child: _GallerySlider(items: galleryItems),
            ),
          ],
        ),
      ),
    );
  }
}
