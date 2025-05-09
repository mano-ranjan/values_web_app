import 'package:flutter/material.dart';
import 'package:values_web_app/shared/theme/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final List<String> menuItems;
  final Function(String) onMenuItemTap;
  final String selectedItem;

  const ResponsiveAppBar({
    super.key,
    required this.onMenuTap,
    required this.menuItems,
    required this.onMenuItemTap,
    required this.selectedItem,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Logo
              _buildLogo(),
              const SizedBox(width: 48),
              // Menu Items
              if (isDesktop || isTablet) ...[
                Expanded(child: _buildMenuItems()),
                _buildActionButtons(),
              ] else ...[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.menu, size: 28),
                  onPressed: onMenuTap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Image.asset('assets/images/logo.png', height: 40),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Values',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            Text(
              'Junior College',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          menuItems.map((item) {
            final isSelected = item == selectedItem;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => onMenuItemTap(item),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.primary.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color:
                          isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        OutlinedButton(onPressed: () {}, child: const Text('Login')),
        const SizedBox(width: 12),
        ElevatedButton(onPressed: () {}, child: const Text('Apply Now')),
      ],
    );
  }
}
