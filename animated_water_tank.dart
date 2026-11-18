import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AnimatedWaterTank extends StatefulWidget {
  final double level; // 0.0 - 1.0
  final TankState state;
  final bool isFilling;
  final bool isDraining;
  final bool isOffline;
  final double size;

  const AnimatedWaterTank({
    super.key,
    required this.level,
    this.state = TankState.normal,
    this.isFilling = false,
    this.isDraining = false,
    this.isOffline = false,
    this.size = 240,
  });

  @override
  State<AnimatedWaterTank> createState() => _AnimatedWaterTankState();
}

class _AnimatedWaterTankState extends State<AnimatedWaterTank>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level.clamp(0.0, 1.0);
    final width = widget.size * 0.72;
    final height = widget.size;
    final borderRadius = BorderRadius.circular(24);

    return SizedBox(
      width: widget.size + 20,
      height: widget.size + 44,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width + 54,
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ScaleLabel('100%'),
                      _ScaleLabel('75%'),
                      _ScaleLabel('50%'),
                      _ScaleLabel('25%'),
                      _ScaleLabel('0%'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF263238)
                          : const Color(0xFFE3F2FD),
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: widget.state.color.withValues(alpha: 0.85),
                        width: 3,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeInOut,
                          height: height * level,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.state.color.withValues(alpha: 0.55),
                                widget.state.color.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                        if (level > 0.02)
                          Positioned(
                            bottom: math.max(0, (height * level) - 12),
                            left: 0,
                            right: 0,
                            child: AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, _) => CustomPaint(
                                size: const Size(double.infinity, 20),
                                painter: _WavePainter(
                                  phase: _waveController.value * 2 * math.pi,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),
                        if (widget.isFilling)
                          ...List.generate(5, (i) {
                            final t = (_waveController.value + i * 0.18) % 1.0;
                            final bubbleBottom = (height * level * 0.1) +
                                (height * level * 0.8 * t);
                            return Positioned(
                              bottom: bubbleBottom.clamp(4.0, height - 12.0),
                              left: 14.0 + (i * 28) % (width - 24),
                              child: Opacity(
                                opacity: (1 - t) * 0.7,
                                child: Container(
                                  width: 6.0 + (i % 3) * 2,
                                  height: 6.0 + (i % 3) * 2,
                                  decoration: const BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(level * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: level > 0.45
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(level * TankCapacity.typical).toStringAsFixed(0)} L',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: level > 0.45
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.state.color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.state.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isOffline)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'OFFLINE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isFilling)
                const _StatusChip(
                    icon: Icons.arrow_upward,
                    label: 'Filling',
                    color: Colors.teal),
              if (widget.isDraining)
                const _StatusChip(
                    icon: Icons.arrow_downward,
                    label: 'Draining',
                    color: Colors.deepOrange),
              if (!widget.isFilling && !widget.isDraining)
                _StatusChip(
                    icon: Icons.water_drop,
                    label: 'Stable',
                    color: widget.state.color),
            ],
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final Color color;
  _WavePainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = 8 +
          4 * math.sin((x / size.width * 2 * math.pi) + phase) +
          2 * math.sin((x / size.width * 4 * math.pi) + phase * 1.3);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

class _ScaleLabel extends StatelessWidget {
  final String text;
  const _ScaleLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)));
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusChip(
      {required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ]),
      );
}
