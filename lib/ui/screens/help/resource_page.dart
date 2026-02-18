import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foretale_application/core/utils/image_display_util.dart';
import 'package:foretale_application/core/utils/responsive.dart';
import 'package:foretale_application/ui/widgets/custom_page_wrapper.dart';
import 'package:foretale_application/ui/widgets/custom_resource_card.dart';
import 'package:foretale_application/core/services/cognito/cognito_activities.dart';

// Simple provider for resource page selection
class ResourcePageProvider extends ChangeNotifier {
  String _selectedOption = 'Resources';
  
  String get selectedOption => _selectedOption;
  
  void selectOption(String option) {
    if (_selectedOption != option) {
      _selectedOption = option;
      notifyListeners();
    }
  }
}

class ResourcePage extends StatelessWidget {
  const ResourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return ChangeNotifierProvider(
      create: (_) => ResourcePageProvider(),
      child: CustomPageWrapper(
        size: size,
        onBackPressed: () => Navigator.pop(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            const _TopSection(),
            const Spacer(),
            Flexible(
              child: _CenterContentLayout(size: size),
            ),
            const Spacer(),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

// Top section widget - stable, doesn't rebuild
class _TopSection extends StatelessWidget {
  const _TopSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ImageDisplayUtil.companyLogo(),
            SizedBox(width: context.spacing(size: SpacingSize.medium)),
            _LogoText(),
          ],
        ),
      ],
    );
  }
}

class _LogoText extends StatelessWidget {
  const _LogoText();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final logoFontSize = context.responsiveFontSize(32);
    final subtitleFontSize = context.responsiveFontSize(10);
    final spacing = context.spacing(size: SpacingSize.small);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'foretale.ai',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: logoFontSize,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: spacing / 4),
        Text(
          'B Y    H E X A N G O',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: subtitleFontSize,
            letterSpacing: 2.0,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// Center content layout - structure is stable
class _CenterContentLayout extends StatelessWidget {
  final Size size;

  const _CenterContentLayout({required this.size});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > 800
          ? _WideLayout()
          : _NarrowLayout();
      },
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.large);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: _NavigationSection(isWideScreen: true),
        ),
        SizedBox(width: spacing * 1.2),
        Container(
          width: 1,
          color: Colors.grey.shade300,
        ),
        SizedBox(width: spacing * 1.2),
        Flexible(
          flex: 3,
          child: _ContentSection(),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.large);
    
    return Column(
      children: [
        const _NavigationSection(isWideScreen: false),
        SizedBox(height: spacing * 0.8),
        const Divider(),
        SizedBox(height: spacing * 0.8),
        Flexible(
          child: _ContentSection(),
        ),
      ],
    );
  }
}

class _NavigationSection extends StatelessWidget {
  final bool isWideScreen;
  
  static const Map<String, IconData> _navigationOptions = {
    'Resources': Icons.library_books,
    'Contact Us': Icons.contact_support,
    'Legal': Icons.gavel,
    'Settings': Icons.settings,
    'Log Out': Icons.logout,
  };

  const _NavigationSection({required this.isWideScreen});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.large);
    
    return Consumer<ResourcePageProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isWideScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (!isWideScreen) ...[
                Text(
                  'RESOURCES',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: context.responsiveFontSize(20),
                  ),
                ),
                SizedBox(height: spacing * 0.8),
              ],
              ..._navigationOptions.entries.map((entry) => 
                _NavigationOption(
                  title: entry.key,
                  icon: entry.value,
                  isSelected: provider.selectedOption == entry.key,
                  isWideScreen: isWideScreen,
                  onTap: () => provider.selectOption(entry.key),
                )
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavigationOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isWideScreen;
  final VoidCallback onTap;

  const _NavigationOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isWideScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius;
    final cardPadding = context.cardPadding;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isWideScreen ? spacing * 0.75 : spacing * 0.8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(isWideScreen ? cardPadding * 0.6 : cardPadding * 0.5),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: isWideScreen
              ? Row(
                  children: [
                    Icon(
                      icon,
                      size: context.iconSize(size: IconSize.small),
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: spacing * 0.75),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: context.responsiveFontSize(16),
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: context.iconSize(size: IconSize.medium),
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(height: context.spacing(size: SpacingSize.small) * 0.6),
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: context.responsiveFontSize(14),
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourcePageProvider>(
      builder: (context, provider, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: SingleChildScrollView(
            key: ValueKey(provider.selectedOption),
            child: _buildContent(context, provider.selectedOption),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, String selectedOption) {
    switch (selectedOption) {
      case 'Resources':
        return const _ResourcesContent();
      case 'Contact Us':
        return const _ContactUsContent();
      case 'Log Out':
        return const _LogOutContent();
      case 'Legal':
        return const _ListContent(
          title: 'Legal',
          items: [
            ('Terms of Service', 'Read our terms and conditions', Icons.description),
            ('Privacy Policy', 'Learn about data protection', Icons.privacy_tip),
            ('Cookie Policy', 'Information about cookies', Icons.cookie),
            ('License Agreement', 'Software licensing terms', Icons.verified_user),
          ],
        );
      case 'Settings':
        return const _ListContent(
          title: 'Settings',
          items: [
            ('Account Settings', 'Manage your account preferences', Icons.account_circle),
            ('Notifications', 'Configure notification preferences', Icons.notifications),
            ('Security', 'Password and security settings', Icons.security),
            ('Appearance', 'Customize the app appearance', Icons.palette),
          ],
        );
      default:
        return const _ResourcesContent();
    }
  }
}

class _ResourcesContent extends StatelessWidget {
  const _ResourcesContent();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.medium);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Resources'),
        SizedBox(height: context.spacing(size: SpacingSize.small) * 0.5),
        Text(
          'Explore our resources to get started',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: context.responsiveFontSize(16),
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: spacing * 0.8),
        const ResourceCard(
          title: "Documentation",
          url: "https://foretale-revolutionizing-x5v0nb0.gamma.site/",
        ),
        SizedBox(height: spacing * 0.8),
        const ResourceCard(
          title: "Tutorials",
          url: "https://foretale-revolutionizing-x5v0nb0.gamma.site/",
        ),
        SizedBox(height: spacing * 0.8),
        const ResourceCard(
          title: "Support",
          url: "https://foretale-revolutionizing-x5v0nb0.gamma.site/",
        ),
      ],
    );
  }
}

class _ContactUsContent extends StatelessWidget {
  const _ContactUsContent();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.medium);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Contact Us'),
        SizedBox(height: spacing * 0.8),
        _InfoCard('Email Support', 'support@foretale.com', Icons.email),
        SizedBox(height: spacing * 0.8),
        _InfoCard('Phone Support', '+1 (555) 123-4567', Icons.phone),
        SizedBox(height: spacing * 0.8),
        _InfoCard('Live Chat', 'Available 24/7', Icons.chat),
      ],
    );
  }
}

class _ListContent extends StatelessWidget {
  final String title;
  final List<(String, String, IconData)> items;

  const _ListContent({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.medium);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        SizedBox(height: spacing * 0.8),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: spacing * 0.8),
          child: _InfoCard(item.$1, item.$2, item.$3, showArrow: true),
        )),
      ],
    );
  }
}

class _LogOutContent extends StatefulWidget {
  const _LogOutContent();

  @override
  State<_LogOutContent> createState() => _LogOutContentState();
}

class _LogOutContentState extends State<_LogOutContent> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logging out...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Sign out from Amplify and clear user details
      await signOut(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // The Authenticator widget will automatically redirect to login screen
      // No manual navigation needed
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius;
    final cardPadding = context.cardPadding;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Log Out'),
        SizedBox(height: spacing * 0.8),
        Container(
          padding: EdgeInsets.all(cardPadding * 1.2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                size: context.iconSize(size: IconSize.large) * 1.33,
                color: Colors.red.shade400,
              ),
              SizedBox(height: spacing * 0.8),
              Text(
                'Are you sure you want to log out?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: context.responsiveFontSize(18),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing * 0.8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing * 1.5,
                        vertical: spacing * 0.75,
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: _isLoggingOut
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Log Out',
                            style: TextStyle(fontSize: context.responsiveFontSize(14)),
                          ),
                  ),
                  SizedBox(width: spacing * 0.8),
                  TextButton(
                    onPressed: _isLoggingOut
                        ? null
                        : () {
                            context.read<ResourcePageProvider>().selectOption('Resources');
                          },
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: context.responsiveFontSize(14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: context.responsiveFontSize(24),
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool showArrow;

  const _InfoCard(this.title, this.subtitle, this.icon, {this.showArrow = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = context.spacing(size: SpacingSize.medium);
    final borderRadius = context.borderRadius;
    final cardPadding = context.cardPadding;
    
    return Container(
      padding: EdgeInsets.all(cardPadding * 0.9),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: context.iconSize(size: IconSize.medium),
            color: colorScheme.primary,
          ),
          SizedBox(width: spacing * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: context.responsiveFontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacing(size: SpacingSize.small) / 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: context.responsiveFontSize(14),
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: context.iconSize(size: IconSize.small) * 0.8,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
        ],
      ),
    );
  }
}