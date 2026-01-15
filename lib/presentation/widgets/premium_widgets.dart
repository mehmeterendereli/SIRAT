import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Widget Library for SIRAT
/// World-class UI components: Glassmorphism, Animations, Premium Effects
/// 
/// Dünyanın 1 numaralı ezan vakti uygulaması için tasarlandı.

// =============================================================================
// GLASSMORPHISM CARD
// =============================================================================

/// Premium glass card with blur effect and gradient border
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double blurAmount;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.glowColor,
    this.blurAmount = 10,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient ?? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.3),
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

// =============================================================================
// PULSING COUNTDOWN
// =============================================================================

/// Animated countdown with pulsing glow effect
class PulsingCountdown extends StatefulWidget {
  final String countdown;
  final Color color;
  final double fontSize;

  const PulsingCountdown({
    super.key,
    required this.countdown,
    this.color = const Color(0xFFD4AF37),
    this.fontSize = 24,
  });

  @override
  State<PulsingCountdown> createState() => _PulsingCountdownState();
}

class _PulsingCountdownState extends State<PulsingCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color,
                  widget.color.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              widget.countdown,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: widget.fontSize,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// SIMPLE COUNTDOWN (NO ANIMATION)
// =============================================================================

/// Simple countdown without animation - clean and classic style
class SimpleCountdown extends StatelessWidget {
  final String countdown;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const SimpleCountdown({
    super.key,
    required this.countdown,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF1B5E20),
    this.fontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        countdown,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          letterSpacing: 3,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// =============================================================================
// FLOATING BOTTOM NAV
// =============================================================================

/// Premium floating bottom navigation with blur effect
class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalMargin = isSmallScreen ? 12.0 : 24.0;
    final navHeight = isSmallScreen ? 60.0 : 70.0;
    
    return Container(
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, isSmallScreen ? 12 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: navHeight,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return Expanded(
                  child: _FloatingNavButton(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    selectedColor: item.activeColor ?? const Color(0xFF1B5E20),
                    onTap: () => onTap(index),
                    isSmallScreen: isSmallScreen,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingNavItem {
  final IconData icon;
  final String label;
  final Color? activeColor;

  const FloatingNavItem({
    required this.icon,
    required this.label,
    this.activeColor,
  });
}

class _FloatingNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _FloatingNavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 4 : 8,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? selectedColor
                  : (isDark ? Colors.white60 : Colors.grey),
              size: iconSize,
            ),
            // Always show label on small screens for better UX, but smaller
            if (isSelected || isSmallScreen) ...[
              SizedBox(height: isSmallScreen ? 2 : 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? selectedColor : (isDark ? Colors.white60 : Colors.grey),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSmallScreen ? 9 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ANIMATED GRADIENT BACKGROUND
// =============================================================================

/// Dynamic gradient background based on prayer time
class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final PrayerPeriod period;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradientForPeriod(period),
      ),
      child: child,
    );
  }

  LinearGradient _getGradientForPeriod(PrayerPeriod period) {
    switch (period) {
      case PrayerPeriod.fajr:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A237E), // Deep night blue
            Color(0xFF311B92), // Purple hint
            Color(0xFF4A148C), // Dawn purple
          ],
        );
      case PrayerPeriod.sunrise:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF6F00), // Warm orange
            Color(0xFFFFB300), // Golden
            Color(0xFFFFF176), // Soft yellow
          ],
        );
      case PrayerPeriod.dhuhr:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF00BCD4), // Bright cyan
            Color(0xFF4DD0E1), // Light cyan
            Color(0xFFE0F7FA), // Very light blue
          ],
        );
      case PrayerPeriod.asr:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B5E20), // Islamic green
            Color(0xFF2E7D32), // Emerald
            Color(0xFF81C784), // Light green
          ],
        );
      case PrayerPeriod.maghrib:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBF360C), // Deep orange
            Color(0xFFE65100), // Orange
            Color(0xFFFF8F00), // Amber
          ],
        );
      case PrayerPeriod.isha:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B2A), // Very dark blue
            Color(0xFF1B1B3A), // Dark purple-blue
            Color(0xFF1B5E20), // Hint of green at bottom
          ],
        );
    }
  }
}

enum PrayerPeriod { fajr, sunrise, dhuhr, asr, maghrib, isha }

// =============================================================================
// SHIMMER LOADING
// =============================================================================

/// Premium shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 16,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _controller.value, 0),
              end: Alignment(1.0 + 2 * _controller.value, 0),
              colors: isDark
                  ? [
                      const Color(0xFF2D2D2D),
                      const Color(0xFF3D3D3D),
                      const Color(0xFF2D2D2D),
                    ]
                  : [
                      const Color(0xFFE0E0E0),
                      const Color(0xFFF5F5F5),
                      const Color(0xFFE0E0E0),
                    ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// GLOW ICON BUTTON
// =============================================================================

/// Icon button with animated glow effect
class GlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const GlowIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFF1B5E20),
    this.size = 24,
  });

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PRAYER TIME CHIP
// =============================================================================

/// Premium prayer time chip with gradient
class PrayerTimeChip extends StatelessWidget {
  final String label;
  final String time;
  final bool isActive;
  final Color activeColor;

  const PrayerTimeChip({
    super.key,
    required this.label,
    required this.time,
    this.isActive = false,
    this.activeColor = const Color(0xFF1B5E20),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  activeColor,
                  activeColor.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: isActive ? null : theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.9)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
