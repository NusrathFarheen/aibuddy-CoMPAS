import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism card widget — the signature CoM-PAS visual style.
/// Frosted glass effect with blur, gradient border, and subtle glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? glowColor;
  final double borderRadius;
  final double? width;
  final double? height;
  final Color color;
  final double opacity;
  final double blur;
  final BoxDecoration? decoration;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.glowColor,
    this.borderRadius = 20,
    this.width,
    this.height,
    this.color = const Color(0xFF1A1F3A),
    this.opacity = 0.6,
    this.blur = 15,
    this.decoration,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? const Color(0xFF6C63FF).withValues(alpha: 0.05);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: decoration ?? BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: color.withValues(alpha: opacity),
              border: border ?? Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Gradient text helper
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

/// Animated progress indicator with glass effect
class GlassProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final double height;

  const GlassProgressBar({
    super.key,
    required this.progress,
    this.color = const Color(0xFF6C63FF),
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.6)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final bool isActive;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 20,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: GlassCard(
        padding: const EdgeInsets.all(10),
        margin: EdgeInsets.all(4),
        borderRadius: 30,
        color: isActive ? (color ?? const Color(0xFF6C63FF)) : const Color(0xFF1A1F3A),
        opacity: isActive ? 0.4 : 0.6,
        glowColor: color?.withValues(alpha: isActive ? 0.3 : 0.05),
        child: Icon(icon, color: color ?? (isActive ? Colors.white : Colors.white70), size: size),
      ),
    );
  }
}
