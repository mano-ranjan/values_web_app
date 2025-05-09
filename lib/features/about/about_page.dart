import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:values_web_app/features/about/bloc/about_bloc.dart';
import 'package:values_web_app/features/about/repositories/about_repository.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => AboutBloc(AboutRepositoryImpl())..add(LoadAboutData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About Us'),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.surface,
        ),
        body: BlocBuilder<AboutBloc, AboutState>(
          builder: (context, state) {
            if (state is AboutLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AboutLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      'Our Mission',
                      state.content.mission,
                      Icons.flag,
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      context,
                      'Our Vision',
                      state.content.vision,
                      Icons.visibility,
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      context,
                      'Our History',
                      state.content.history,
                      Icons.history,
                    ),
                    const SizedBox(height: 32),
                    _buildAchievementsSection(
                      context,
                      state.content.achievements,
                    ),
                  ],
                ),
              );
            } else if (state is AboutError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
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
                Icon(icon, color: AppTheme.primary, size: 32),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(content, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    List<String> achievements,
  ) {
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
                Icon(Icons.emoji_events, color: AppTheme.primary, size: 32),
                const SizedBox(width: 16),
                Text(
                  'Our Achievements',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...achievements.map(
              (achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        achievement,
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
    );
  }
}
