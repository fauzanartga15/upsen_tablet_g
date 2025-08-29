import 'package:flutter/material.dart';

class AppTheme {
  // Upsen Brand Colors (Teal-based)
  static const Color upsenTeal = Color(0xFF26a69a); // Colors.teal[400]
  static const Color upsenTealLight = Color(0xFF4db6ac); // Colors.teal[300]
  static const Color upsenTealDark = Color(0xFF00695c); // Colors.teal[800]

  // Complementary colors
  static const Color accentCyan = Color(0xFF00bcd4);
  static const Color accentBlue = Color(0xFF0277bd);
  static const Color success = Color(0xFF4caf50);
  static const Color warning = Color(0xFFff9800);
  static const Color error = Color(0xFFf44336);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFbdbdbd);

  // Background colors - FIXED: Use Color instead of Gradient
  static const Color backgroundPrimary = Color(0xFFe0f2f1); // Light teal
  static const Color backgroundSecondary = Color(0xFFb2dfdb);
  static const Color surface = Colors.white;

  // Gradients
  static const LinearGradient upsenGradient = LinearGradient(
    colors: [upsenTeal, upsenTealLight, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFe0f2f1), Color(0xFFb2dfdb), Color(0xFF80cbc4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: upsenTeal.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: upsenTeal.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // Decorations
  static BoxDecoration get glassmorphismDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // Responsive helpers - FIXED: Proper BuildContext parameter
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 24; // Tablet
    if (width > 600) return 20; // Large phone
    return 16; // Small phone
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return baseSize * 1.2; // Tablet
    if (width > 600) return baseSize * 1.1; // Large phone
    return baseSize; // Small phone
  }

  static double getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 100; // Tablet
    if (width > 600) return 80; // Large phone
    return 60; // Small phone
  }

  // Text styles with responsive sizing
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headingSmall => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyLarge =>
      const TextStyle(fontSize: 16, color: textPrimary);

  static TextStyle get bodyMedium =>
      const TextStyle(fontSize: 14, color: textPrimary);

  static TextStyle get bodySmall =>
      const TextStyle(fontSize: 12, color: textSecondary);

  // Button helper - FIXED: Made it a static method
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isSecondary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSecondary
            ? LinearGradient(colors: [accentBlue, accentCyan])
            : upsenGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: glowShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
