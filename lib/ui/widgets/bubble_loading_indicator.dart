import 'package:flutter/material.dart';

class BubbleLoadingIndicator extends StatefulWidget {
  final bool isLoading;
  final double size;
  final Color color;
  final Color backgroundColor;
  final Duration duration;
  final int bubbleCount;
  final String? loadingText;
  final TextStyle? textStyle;
  final Widget? trailingWidget;
  final MainAxisAlignment alignment;

  const BubbleLoadingIndicator({
    super.key,
    required this.isLoading,
    this.size = 60.0,
    this.color = Colors.blueAccent,
    this.backgroundColor = Colors.transparent,
    this.duration = const Duration(milliseconds: 1200),
    this.bubbleCount = 3,
    this.loadingText,
    this.textStyle,
    this.trailingWidget,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  State<BubbleLoadingIndicator> createState() => _BubbleLoadingIndicatorState();
}

class _BubbleLoadingIndicatorState extends State<BubbleLoadingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _jumpAnimations;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.isLoading) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.bubbleCount,
      (index) => AnimationController(
        vsync: this,
        duration: widget.duration,
      ),
    );

    _jumpAnimations = List.generate(
      widget.bubbleCount,
      (index) => Tween<double>(
        begin: 0.0,
        end: -20.0,
      ).animate(CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeInOutCubic,
      )),
    );

    _scaleAnimations = List.generate(
      widget.bubbleCount,
      (index) => Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeInOutCubic,
      )),
    );

    _opacityAnimations = List.generate(
      widget.bubbleCount,
      (index) => Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeInOutCubic,
      )),
    );
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (final controller in _controllers) {
      controller.stop();
    }
  }

  @override
  void didUpdateWidget(BubbleLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controllers.any((controller) => controller.isAnimating)) {
      _startAnimations();
    } else if (!widget.isLoading && _controllers.any((controller) => controller.isAnimating)) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();

    final defaultTextStyle = Theme.of(context).textTheme.titleMedium;
    final bubbleSize = widget.size / (widget.bubbleCount + 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bubbles container
        SizedBox(
          width: widget.size,
          height: widget.size * 0.6,
          child: Stack(
            children: List.generate(widget.bubbleCount, (index) {
              return Positioned(
                left: (widget.size / (widget.bubbleCount + 1)) * (index + 1),
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _controllers[index],
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, _jumpAnimations[index].value),
                      child: Transform.scale(
                        scale: _scaleAnimations[index].value,
                        child: Opacity(
                          opacity: _opacityAnimations[index].value,
                          child: Container(
                            width: bubbleSize,
                            height: bubbleSize,
                            decoration: BoxDecoration(
                              color: widget.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
        
        // Text and optional trailing widget
        if (widget.loadingText != null || widget.trailingWidget != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.alignment,
              children: [
                if (widget.loadingText != null)
                  Text(
                    widget.loadingText!,
                    style: widget.textStyle ?? defaultTextStyle,
                  ),
                if (widget.loadingText != null && widget.trailingWidget != null)
                  const SizedBox(width: 8),
                if (widget.trailingWidget != null)
                  widget.trailingWidget!,
              ],
            ),
          ),
      ],
    );
  }
}
