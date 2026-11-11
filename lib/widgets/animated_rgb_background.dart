import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Background Animasi RGB Halus & Elegan (Persis Efek Gradien Bergerak di Web)
class AnimatedRgbBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const AnimatedRgbBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<AnimatedRgbBackground> createState() => _AnimatedRgbBackgroundState();
}

class _AnimatedRgbBackgroundState extends State<AnimatedRgbBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final isDark = widget.isDark;

        // Koordinat Alignment yang bergerak perlahan memutar halus
        final beginX = -1.0 + 0.6 * math.sin(t * 2 * math.pi);
        final beginY = -1.0 + 0.4 * math.cos(t * 2 * math.pi);
        final endX = 1.0 - 0.5 * math.sin(t * 2 * math.pi);
        final endY = 1.0 - 0.4 * math.cos(t * 2 * math.pi);

        final lightColors = [
          Color.lerp(const Color(0xFFE0F2FE), const Color(0xFFEDE9FE), t)!, // Cyan <-> Violet
          Color.lerp(const Color(0xFFEEF2FF), const Color(0xFFFCE7F3), t)!, // Indigo <-> Pink
          Color.lerp(const Color(0xFFFDF2F8), const Color(0xFFE0F2FE), t)!, // Soft Pink <-> Sky
          Color.lerp(const Color(0xFFECFDF5), const Color(0xFFEDE9FE), t)!, // Mint <-> Violet
        ];

        final darkColors = [
          Color.lerp(const Color(0xFF0F172A), const Color(0xFF1E1B4B), t)!, // Slate <-> Deep Indigo
          Color.lerp(const Color(0xFF1E293B), const Color(0xFF2E1065), t)!, // Slate 800 <-> Deep Violet
          Color.lerp(const Color(0xFF0D2538), const Color(0xFF0F172A), t)!, // Deep Teal <-> Slate
          Color.lerp(const Color(0xFF17153B), const Color(0xFF064E3B), t)!, // Indigo <-> Emerald
        ];

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(beginX, beginY),
              end: Alignment(endX, endY),
              colors: isDark ? darkColors : lightColors,
            ),
          ),
          child: Stack(
            children: [
              // Orb Cahaya 1 (Cyan / Blue Neon yang mengambang lembut)
              Positioned(
                top: -60 + 40 * math.sin(t * math.pi),
                left: -40 + 50 * math.cos(t * math.pi),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF0284C7).withAlpha(45)
                        : const Color(0xFF38BDF8).withAlpha(60),
                  ),
                ),
              ),

              // Orb Cahaya 2 (Purple / Magenta Glow yang bergerak di sudut bawah)
              Positioned(
                bottom: -60 + 50 * math.cos(t * math.pi),
                right: -40 + 40 * math.sin(t * math.pi),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF7C3AED).withAlpha(40)
                        : const Color(0xFFA855F7).withAlpha(50),
                  ),
                ),
              ),

              // Konten Halaman Utama
              widget.child,
            ],
          ),
        );
      },
    );
  }
}
