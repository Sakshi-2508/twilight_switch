import 'dart:math' as math;
import 'package:flutter/material.dart';

class TwilightSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Duration duration;
  final List<Color>? dayColors;
  final List<Color>? twilightColors;
  final List<Color>? nightColors;
  final bool enableDrag;

  const TwilightSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 132,
    this.height = 64,
    this.duration = const Duration(milliseconds: 850),
    this.dayColors,
    this.twilightColors,
    this.nightColors,
    this.enableDrag = true,
  });

  @override
  State<TwilightSwitch> createState() => _TwilightSwitchState();
}

class _TwilightSwitchState extends State<TwilightSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double? _dragProgress;

  double get _progress => _dragProgress ?? _controller.value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant TwilightSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.value != widget.value && _dragProgress == null) {
      _animateTo(widget.value ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() => widget.onChanged(!widget.value);

  void _animateTo(double target) {
    _controller.animateTo(
      target,
      curve: Curves.easeInOutCubic,
      duration: widget.duration,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag) return;

    final next =
        (_progress + details.primaryDelta! / (widget.width - widget.height))
            .clamp(0.0, 1.0)
            .toDouble();

    setState(() => _dragProgress = next);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enableDrag) return;

    final shouldBeNight = _progress >= 0.5;

    setState(() {
      _controller.value = _progress;
      _dragProgress = null;
    });

    widget.onChanged(shouldBeNight);
    _animateTo(shouldBeNight ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: widget.value,
      label: 'Twilight switch',
      child: GestureDetector(
        onTap: _toggle,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _progress;

            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.height),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.height),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TwilightSkyPainter(
                            progress: progress,
                            dayColors: widget.dayColors,
                            twilightColors: widget.twilightColors,
                            nightColors: widget.nightColors,
                          ),
                        ),
                      ),
                      _Thumb(
                        progress: progress,
                        height: widget.height,
                        width: widget.width,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.progress,
    required this.height,
    required this.width,
  });

  final double progress;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final margin = height * 0.1;
    final size = height - margin * 2;
    final left = margin + (width - height) * progress;

    final sunOpacity = (1 - progress * 1.4).clamp(0.0, 1.0).toDouble();
    final moonOpacity = ((progress - 0.25) / 0.75).clamp(0.0, 1.0).toDouble();

    return Positioned(
      left: left,
      top: margin,
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CelestialThumbPainter(
          progress: progress,
          sunOpacity: sunOpacity,
          moonOpacity: moonOpacity,
        ),
      ),
    );
  }
}

class _TwilightSkyPainter extends CustomPainter {
  _TwilightSkyPainter({
    required this.progress,
    this.dayColors,
    this.twilightColors,
    this.nightColors,
  });

  final double progress;
  final List<Color>? dayColors;
  final List<Color>? twilightColors;
  final List<Color>? nightColors;

  static const _defaultDay = [
    Color(0xFF86D9FF),
    Color(0xFF36AEEE),
  ];

  static const _defaultTwilight = [
    Color(0xFFFFA45B),
    Color(0xFF7B61FF),
  ];

  static const _defaultNight = [
    Color(0xFF101B3F),
    Color(0xFF271150),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final day = dayColors ?? _defaultDay;
    final twilight = twilightColors ?? _defaultTwilight;
    final night = nightColors ?? _defaultNight;

    final colors = progress < 0.5
        ? _lerpColors(day, twilight, progress * 2)
        : _lerpColors(twilight, night, (progress - 0.5) * 2);

    final rect = Offset.zero & size;

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(rect);

    canvas.drawRect(rect, skyPaint);

    _drawClouds(
      canvas,
      size,
      (1 - progress * 1.7).clamp(0.0, 1.0).toDouble(),
    );

    _drawStars(
      canvas,
      size,
      ((progress - 0.35) / 0.65).clamp(0.0, 1.0).toDouble(),
    );

    _drawHorizonGlow(
      canvas,
      size,
      (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0).toDouble(),
    );
  }

  List<Color> _lerpColors(List<Color> a, List<Color> b, double t) {
    return [
      Color.lerp(a[0], b[0], t)!,
      Color.lerp(a[1], b[1], t)!,
    ];
  }

  void _drawHorizonGlow(Canvas canvas, Size size, double opacity) {
    if (opacity <= 0) return;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.28 * opacity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.52, size.height * 1.08),
          radius: size.width * 0.75,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 1.08),
      size.width * 0.75,
      paint,
    );
  }

  void _drawStars(Canvas canvas, Size size, double opacity) {
    if (opacity <= 0) return;

    final stars = <({double x, double y, double r, double delay})>[
      (x: .18, y: .26, r: 1.4, delay: .00),
      (x: .31, y: .56, r: 1.0, delay: .15),
      (x: .45, y: .24, r: 1.2, delay: .30),
      (x: .63, y: .42, r: 0.9, delay: .45),
      (x: .78, y: .22, r: 1.5, delay: .60),
    ];

    final paint = Paint()..color = Colors.white;

    for (final star in stars) {
      final localOpacity = ((opacity - star.delay) / (1 - star.delay))
          .clamp(0.0, 1.0)
          .toDouble();

      paint.color = Colors.white.withValues(alpha: localOpacity);

      canvas.drawCircle(
        Offset(size.width * star.x, size.height * star.y),
        star.r,
        paint,
      );

      canvas.drawCircle(
        Offset(size.width * star.x, size.height * star.y),
        star.r * 2.4,
        Paint()..color = Colors.white.withValues(alpha: localOpacity * 0.08),
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size, double opacity) {
    if (opacity <= 0) return;

    final drift = progress * size.width * .18;

    _drawCloud(
      canvas,
      Offset(size.width * .62 + drift, size.height * .34),
      size.height * .18,
      opacity,
    );

    _drawCloud(
      canvas,
      Offset(size.width * .22 + drift * .45, size.height * .62),
      size.height * .14,
      opacity * .65,
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, double opacity) {
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.05 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final paint = Paint()..color = Colors.white.withValues(alpha: 0.88 * opacity);

    final circles = [
      Offset(-1.3, .25),
      Offset(-.55, -.12),
      Offset(.22, -.32),
      Offset(.95, .16),
    ];

    for (final offset in circles) {
      final c = center + Offset(offset.dx * radius, offset.dy * radius);

      canvas.drawCircle(
        c + const Offset(1.5, 2),
        radius * (.72 - offset.dy.abs() * .12),
        shadow,
      );

      canvas.drawCircle(
        c,
        radius * (.72 - offset.dy.abs() * .12),
        paint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(0, radius * .28),
          width: radius * 3.25,
          height: radius * .92,
        ),
        Radius.circular(radius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TwilightSkyPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dayColors != dayColors ||
        oldDelegate.twilightColors != twilightColors ||
        oldDelegate.nightColors != nightColors;
  }
}

class _CelestialThumbPainter extends CustomPainter {
  _CelestialThumbPainter({
    required this.progress,
    required this.sunOpacity,
    required this.moonOpacity,
  });

  final double progress;
  final double sunOpacity;
  final double moonOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius * 1.22,
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD166),
          const Color(0xFFC7D2FE),
          progress,
        )!
            .withValues(alpha: 0.18),
    );

    canvas.drawCircle(
      center + const Offset(0, 2),
      radius * .94,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    if (sunOpacity > 0) {
      _drawSun(canvas, center, radius, sunOpacity);
    }

    if (moonOpacity > 0) {
      _drawMoon(canvas, center, radius, moonOpacity);
    }
  }

  void _drawSun(Canvas canvas, Offset center, double radius, double opacity) {
    final rayPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFD166).withValues(alpha: opacity * .8);

    for (var i = 0; i < 10; i++) {
      final angle = i * math.pi / 5;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * .54;
      final end =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * .78;

      canvas.drawLine(start, end, rayPaint);
    }

    canvas.drawCircle(
      center,
      radius * .58,
      Paint()..color = const Color(0xFFFFC857).withValues(alpha: opacity),
    );

    canvas.drawCircle(
      center - Offset(radius * .17, radius * .20),
      radius * .19,
      Paint()..color = Colors.white.withValues(alpha: opacity * .28),
    );
  }

  void _drawMoon(Canvas canvas, Offset center, double radius, double opacity) {
    final moonPaint = Paint()
      ..color = const Color(0xFFF8FAFC).withValues(alpha: opacity);

    canvas.drawCircle(center, radius * .62, moonPaint);

    canvas.drawCircle(
      center + Offset(radius * .24, -radius * .10),
      radius * .58,
      Paint()..color = const Color(0xFFBBC5E8).withValues(alpha: opacity),
    );

    final craterPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: opacity * .5);

    canvas.drawCircle(
      center + Offset(-radius * .18, -radius * .18),
      radius * .07,
      craterPaint,
    );

    canvas.drawCircle(
      center + Offset(-radius * .02, radius * .16),
      radius * .05,
      craterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CelestialThumbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.sunOpacity != sunOpacity ||
        oldDelegate.moonOpacity != moonOpacity;
  }
}
