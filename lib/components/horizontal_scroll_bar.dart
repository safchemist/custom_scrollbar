import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HorizontalCustomScrollbar extends SingleChildRenderObjectWidget {
  final ScrollController controller;
  final Widget child;
  final double? strokeWidth;
  final EdgeInsets? padding;
  final Color? trackColor;
  final Color? thumbColor;

  const HorizontalCustomScrollbar({
    Key? key,
    required this.controller,
    required this.child,
    this.strokeWidth,
    this.padding,
    this.trackColor,
    this.thumbColor,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHorizontalCustomScrollbar(
      controller: controller,
      strokeWidth: strokeWidth ?? 16,
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      trackColor: trackColor ?? Colors.purpleAccent.withOpacity(0.3),
      thumbColor: thumbColor ?? Colors.purpleAccent,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant RenderHorizontalCustomScrollbar renderObject) {
    if (strokeWidth != null) {
      renderObject.strokeWidth = strokeWidth!;
    }
    if (padding != null) {
      renderObject.padding = padding!;
    }
    if (trackColor != null) {
      renderObject.trackColor = trackColor!;
    }
    if (thumbColor != null) {
      renderObject.thumbColor = thumbColor!;
    }
  }
}

class RenderHorizontalCustomScrollbar extends RenderShiftedBox {
  final ScrollController controller;
  Offset _thumbPoint = Offset(0, 0);
  EdgeInsets padding;
  double strokeWidth;
  Color trackColor;
  Color thumbColor;

  RenderHorizontalCustomScrollbar({
    RenderBox? child,
    required this.padding,
    required this.controller,
    required this.strokeWidth,
    required this.trackColor,
    required this.thumbColor,
  }) : super(child) {
    controller.addListener(_updateThumbPoint);
  }

  void _updateThumbPoint() {
    _thumbPoint = Offset(_getThumbHorizontalOffset(), _getVerticalOffset());
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  double _getVerticalOffset() {
    return size.height + kToolbarHeight;
  }

  double _getThumbHorizontalOffset() {
    var scrollExtent = _getScrollExtent();
    var scrollPosition = controller.position;
    var scrollOffset =
        ((scrollPosition.pixels - scrollPosition.minScrollExtent) /
                scrollExtent)
            .clamp(0.0, 1.0);
    return (_getWidthWithPadding() - _getThumbWidth()) * scrollOffset;
  }

  double _getWidthWithPadding() {
    return size.width - 32;
  }

  double _getScrollExtent() {
    return controller.position.maxScrollExtent;
  }

  double _getThumbWidth() {
    var scrollExtent = _getScrollExtent();
    var width = _getWidthWithPadding();
    if (scrollExtent == 0) {
      return width;
    }
    return (width / (scrollExtent / width + 1));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.paintChild(child!, offset);
    _resetThumbStartPointIfNeeded();
    _trackPaint(context, offset);
    _thumbPaint(context, offset);
    _textPaint(context, offset);
  }

  void _resetThumbStartPointIfNeeded() {
    var scrollMaxExtent = _getScrollExtent();
    if (scrollMaxExtent == 0) {
      _thumbPoint = Offset(0, _getVerticalOffset());
    }
  }

  void _trackPaint(PaintingContext context, Offset offset) {
    var height = _getVerticalOffset();
    final trackPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = trackColor
      ..strokeWidth = strokeWidth;
    final startPoint = Offset(offset.dx + padding.top, height);
    final endPoint = Offset(startPoint.dx + _getWidthWithPadding(), height);
    context.canvas.drawLine(startPoint, endPoint, trackPaint);
  }

  void _thumbPaint(PaintingContext context, Offset offset) {
    var height = _getVerticalOffset();
    final paintThumb = Paint()
      ..strokeWidth = strokeWidth
      ..color = thumbColor
      ..strokeCap = StrokeCap.round;
    final startPoint =
        Offset((_thumbPoint.dx + offset.dx + padding.horizontal), height);
    final endPoint = Offset(startPoint.dx + _getThumbWidth(), height);
    context.canvas.drawLine(startPoint, endPoint, paintThumb);
  }

  void _textPaint(PaintingContext context, Offset offset) {
    var canvas = context.canvas;
    canvas.save();
    canvas.translate(_thumbPoint.dx + _getThumbWidth() * 0.45,
        _getVerticalOffset() - kToolbarHeight - padding.vertical);
    TextSpan span = TextSpan(
        text: _getPercent(),
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
    canvas.restore();
  }

  String _getPercent() {
    if (_getScrollExtent() == 0) {
      return '100 %';
    }
    return (controller.position.pixels / _getScrollExtent() * 100)
            .toStringAsFixed(0) +
        ' %';
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    if (child == null) return;
    child!.layout(constraints.copyWith(maxHeight: _getChildMaxHeight()),
        parentUsesSize: !constraints.isTight);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = Offset.zero;
  }

  double _getChildMaxHeight() {
    return constraints.maxHeight - padding.bottom - strokeWidth;
  }
}
