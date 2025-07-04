import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final double width;
  final TextStyle? style;
  final bool enableMarquee;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.width,
    this.style,
    this.enableMarquee = true,
    this.scrollDuration = const Duration(seconds: 3),
    this.pauseDuration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late bool _shouldScroll;
  late double _textWidth;
  bool _measured = false;
  static const double _gap = 10; // 间隔宽度

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureText());
  }

  void _measureText() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    _textWidth = textPainter.width;
    _shouldScroll = _textWidth > widget.width;
    setState(() {
      _measured = true;
    });
    if (widget.enableMarquee && _shouldScroll) {
      _startScroll();
    }
  }

  void _startScroll() async {
    while (mounted && widget.enableMarquee && _shouldScroll) {
      await Future.delayed(widget.pauseDuration);
      if (!mounted) break;
      final double maxScroll = _textWidth + _gap - widget.width;
      await _scrollController.animateTo(
        maxScroll,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );
      await Future.delayed(widget.pauseDuration);
      if (!mounted) break;
      await _scrollController.animateTo(
        0,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height =
        widget.style?.fontSize != null ? widget.style!.fontSize! * 1.3 : 20;
    if (!_measured) {
      // 直接渲染静态文本，避免闪烁
      return SizedBox(
        width: widget.width,
        height: height,
        child: Text(
          widget.text,
          style: widget.style,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }
    if (!widget.enableMarquee || !_shouldScroll) {
      return SizedBox(
        width: widget.width,
        height: height,
        child: Text(
          widget.text,
          style: widget.style,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }
    // 修复：渲染两份文本+间隔，保证末尾完整显示
    return SizedBox(
      width: widget.width,
      height: height,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
            ),
          ),
          SizedBox(width: widget.width),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
