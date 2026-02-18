//core
import 'package:flutter/material.dart';
//services
import 'package:foretale_application/core/services/cognito/cognito_activities.dart';
//utils
import 'package:foretale_application/core/utils/quick_widgets/empty_state.dart';
import 'package:foretale_application/core/utils/quick_widgets/loading_state.dart';
//widgets
import 'package:foretale_application/ui/widgets/copyright_footer.dart';
import 'package:foretale_application/ui/widgets/app_actions/enhanced_floating_action_button.dart';
import 'package:foretale_application/ui/widgets/app_actions/expandable_actions_button.dart';

class CustomPageWrapper extends StatefulWidget {
  final Size size;
  final Widget child;
  final List<ActionItem>? additionalActions;
  final VoidCallback? onHomePressed;
  final VoidCallback? onBackPressed;
  final VoidCallback? onReady;
  final bool workloadTheme;
  final bool enableGradient;
  final bool showBackButton;
  final bool showHomeButton;

  const CustomPageWrapper({
    super.key, 
    required this.child, 
    required this.size, 
    this.additionalActions, 
    this.onHomePressed,
    this.onBackPressed,
    this.onReady,
    this.workloadTheme = false,
    this.enableGradient = true,
    this.showBackButton = true,
    this.showHomeButton = true,
  });

  @override
  State<CustomPageWrapper> createState() => _CustomPageWrapperState();
}

class _CustomPageWrapperState extends State<CustomPageWrapper> {
  bool _hasCalledOnReady = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Check if floating action button should be shown
    final bool showFloatingActionButton = widget.additionalActions?.isNotEmpty == true || widget.onHomePressed != null || widget.onBackPressed != null;

    return Scaffold(
      bottomNavigationBar: const CopyrightFooter(),
      body: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Stack(
          children: [
            FutureBuilder<void>(
              future: getUserSignInDetails(context).then((value) {
                if (mounted && widget.onReady != null && !_hasCalledOnReady) {
                  _hasCalledOnReady = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onReady!();
                  });
                }
              }),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildLoadingState(context);
                } else if (snapshot.hasError) {
                  return _buildErrorContent(snapshot.error.toString());
                } else {
                  return _buildBodyContentWithoutScrolling();
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: showFloatingActionButton 
          ? EnhancedFloatingActionButton(
                additionalActions: widget.additionalActions ?? [],
                onHomePressed: widget.onHomePressed,
                onBackPressed: widget.onBackPressed,
                showBackButton: widget.showBackButton,
                showHomeButton: widget.showHomeButton,
              )
          : null,
      floatingActionButtonLocation: showFloatingActionButton 
          ? FloatingActionButtonLocation.endTop
          : null,
    );
  }

  Widget _buildErrorContent(String errorMessage) {
    return EmptyState(
      title: 'Something went wrong!',
      subtitle: 'Under the hood: $errorMessage',
      icon: Icons.error,
    );
  }

  Widget _buildBodyContentWithoutScrolling() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(widget.size.width * 0.01),
        child: widget.child
      ),
    ); 
  }
}