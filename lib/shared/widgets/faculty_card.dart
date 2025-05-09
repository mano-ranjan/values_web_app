import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';

class FacultyCard extends StatefulWidget {
  final String name;
  final String role;
  final String imageUrl;
  final String experience;
  final String qualification;
  final String description;
  final VoidCallback onTap;

  const FacultyCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.experience,
    required this.qualification,
    required this.description,
    required this.onTap,
  });

  @override
  State<FacultyCard> createState() => _FacultyCardState();
}

class _FacultyCardState extends State<FacultyCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform:
            Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(isHovered ? 0.1 : 0.05),
              blurRadius: isHovered ? 20 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.asset(widget.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.role,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.school_outlined,
                        widget.qualification,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.timeline_outlined,
                        '${widget.experience} Years Experience',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: widget.onTap,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('View Profile'),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.email_outlined),
                            color: AppTheme.primary,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.phone_outlined),
                            color: AppTheme.primary,
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
