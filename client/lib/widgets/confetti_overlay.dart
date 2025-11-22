import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool shouldPlay;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.shouldPlay,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ), // Long duration for continuous loop
    )..addListener(_updateParticles);
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay && !oldWidget.shouldPlay) {
      _startConfetti();
    } else if (!widget.shouldPlay && oldWidget.shouldPlay) {
      _stopConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    // Spawn initial burst
    for (int i = 0; i < 50; i++) {
      _particles.add(_createParticle());
    }
    _controller.repeat();
  }

  void _stopConfetti() {
    _controller.stop();
    _particles.clear();
    setState(() {}); // Clear canvas
  }

  _Particle _createParticle() {
    return _Particle(
      x: _rnd.nextDouble(), // 0.0 to 1.0 (screen width ratio)
      y: -0.1 - _rnd.nextDouble() * 0.5, // Start above screen
      size: 5 + _rnd.nextDouble() * 10,
      color: Colors.primaries[_rnd.nextInt(Colors.primaries.length)],
      speedY: 0.005 + _rnd.nextDouble() * 0.01,
      speedX: (_rnd.nextDouble() - 0.5) * 0.005,
      rotation: _rnd.nextDouble() * 2 * pi,
      rotationSpeed: (_rnd.nextDouble() - 0.5) * 0.1,
    );
  }

  void _updateParticles() {
    // Spawn new particles continuously while playing
    if (widget.shouldPlay &&
        _particles.length < 150 &&
        _rnd.nextDouble() < 0.1) {
      _particles.add(_createParticle());
    }

    for (var p in _particles) {
      p.y += p.speedY;
      p.x += p.speedX;
      p.rotation += p.rotationSpeed;

      // Sway effect
      p.x += sin(p.y * 10) * 0.002;
    }

    // Remove particles that fell off screen
    _particles.removeWhere((p) => p.y > 1.2);

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_particles.isNotEmpty)
          IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(_particles),
              size: Size.infinite,
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  Color color;
  double speedY;
  double speedX;
  double rotation;
  double rotationSpeed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color;

      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);

      // Draw a simple rectangle (confetti piece)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
