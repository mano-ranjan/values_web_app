import 'package:values_web_app/features/about/models/about_content.dart';

abstract class AboutRepository {
  Future<AboutContent> getAboutContent();
}

class AboutRepositoryImpl implements AboutRepository {
  @override
  Future<AboutContent> getAboutContent() async {
    // TODO: Implement actual data fetching from API or local storage
    // For now, return mock data
    return AboutContent(
      mission: 'To provide quality education and foster academic excellence.',
      vision: 'To be a leading institution in higher education and research.',
      history:
          'Established in 1990, our institution has been a center of excellence for over three decades.',
      achievements: [
        'Ranked #1 in the state for academic excellence',
        'Accredited by NAAC with A++ grade',
        'Multiple research grants and publications',
        'Strong industry-academia partnerships',
      ],
    );
  }
}
