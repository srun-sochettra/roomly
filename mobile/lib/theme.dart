import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Every colour the app uses, in a light and a dark version.
/// Screens read them with `context.colors`, so switching theme recolours everything,
/// and Flutter animates between the two using [lerp].
@immutable
class RoomlyColors extends ThemeExtension<RoomlyColors> {
  const RoomlyColors({
    required this.ink,
    required this.muted,
    required this.line,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.brand,
    required this.onBrand,
    required this.brandSoft,
    required this.brandStrong,
    required this.danger,
    required this.amberBg,
    required this.amberFg,
    required this.greenBg,
    required this.greenFg,
    required this.roseBg,
    required this.roseFg,
    required this.slateBg,
    required this.slateFg,
  });

  final Color ink, muted, line, background, surface, surfaceAlt;
  final Color brand, onBrand, brandSoft, brandStrong, danger;
  final Color amberBg, amberFg, greenBg, greenFg, roseBg, roseFg, slateBg, slateFg;

  static const light = RoomlyColors(
    ink: Color(0xFF0F172A),
    muted: Color(0xFF64748B),
    line: Color(0xFFE2E8F0),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F5F9),
    brand: Color(0xFF0F766E),
    onBrand: Color(0xFFFFFFFF),
    brandSoft: Color(0xFFCCFBF1),
    brandStrong: Color(0xFF134E4A),
    danger: Color(0xFFBE123C),
    amberBg: Color(0xFFFEF3C7),
    amberFg: Color(0xFF92400E),
    greenBg: Color(0xFFD1FAE5),
    greenFg: Color(0xFF065F46),
    roseBg: Color(0xFFFFE4E6),
    roseFg: Color(0xFF9F1239),
    slateBg: Color(0xFFF1F5F9),
    slateFg: Color(0xFF475569),
  );

  static const dark = RoomlyColors(
    ink: Color(0xFFE2E8F0),
    muted: Color(0xFF94A3B8),
    line: Color(0xFF263248),
    background: Color(0xFF0B1220),
    surface: Color(0xFF131C2E),
    surfaceAlt: Color(0xFF1C2740),
    brand: Color(0xFF2DD4BF),
    onBrand: Color(0xFF042F2E),
    brandSoft: Color(0xFF134E4A),
    brandStrong: Color(0xFF99F6E4),
    danger: Color(0xFFFB7185),
    amberBg: Color(0xFF3B2A0A),
    amberFg: Color(0xFFFCD34D),
    greenBg: Color(0xFF06382B),
    greenFg: Color(0xFF6EE7B7),
    roseBg: Color(0xFF3F0D1A),
    roseFg: Color(0xFFFDA4AF),
    slateBg: Color(0xFF1E293B),
    slateFg: Color(0xFF94A3B8),
  );

  @override
  RoomlyColors copyWith() => this;

  @override
  RoomlyColors lerp(ThemeExtension<RoomlyColors>? other, double t) {
    if (other is! RoomlyColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return RoomlyColors(
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      brand: l(brand, other.brand),
      onBrand: l(onBrand, other.onBrand),
      brandSoft: l(brandSoft, other.brandSoft),
      brandStrong: l(brandStrong, other.brandStrong),
      danger: l(danger, other.danger),
      amberBg: l(amberBg, other.amberBg),
      amberFg: l(amberFg, other.amberFg),
      greenBg: l(greenBg, other.greenBg),
      greenFg: l(greenFg, other.greenFg),
      roseBg: l(roseBg, other.roseBg),
      roseFg: l(roseFg, other.roseFg),
      slateBg: l(slateBg, other.slateBg),
      slateFg: l(slateFg, other.slateFg),
    );
  }
}

extension RoomlyColorsX on BuildContext {
  RoomlyColors get colors => Theme.of(this).extension<RoomlyColors>()!;
}

/// The teal gradient on the login header and profile card looks right in both themes.
const brandGradient = LinearGradient(
  colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? RoomlyColors.dark : RoomlyColors.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F766E),
    brightness: brightness,
    primary: c.brand,
    onPrimary: c.onBrand,
    surface: c.surface,
    onSurface: c.ink,
  );
  final base = ThemeData(useMaterial3: true, brightness: brightness, colorScheme: scheme, scaffoldBackgroundColor: c.background);
  // Buttons ignore textTheme, so give them the brand font explicitly.
  final buttonText = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  OutlineInputBorder border(Color color, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: color, width: w));

  return base.copyWith(
    extensions: [c],
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(bodyColor: c.ink, displayColor: c.ink),
    appBarTheme: AppBarTheme(backgroundColor: c.background, foregroundColor: c.ink, elevation: 0, scrolledUnderElevation: 0),
    iconTheme: IconThemeData(color: c.ink),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: c.muted),
      labelStyle: TextStyle(color: c.muted),
      prefixIconColor: c.muted,
      suffixIconColor: c.muted,
      border: border(c.line),
      enabledBorder: border(c.line),
      focusedBorder: border(c.brand, 1.6),
      errorBorder: border(c.danger),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: shape, textStyle: buttonText),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: shape, textStyle: buttonText, side: BorderSide(color: c.line)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: buttonText.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(46)),
        textStyle: WidgetStateProperty.all(buttonText.copyWith(fontSize: 14)),
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.ink : c.surface),
        foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.background : c.muted),
        iconColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.background : c.muted),
        side: WidgetStateProperty.all(BorderSide(color: c.line)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.brandSoft,
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.brandStrong : c.muted)),
      labelTextStyle: WidgetStateProperty.all(GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.ink)),
    ),
    dialogTheme: DialogThemeData(backgroundColor: c.surface),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.surface),
    dividerColor: c.line,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: GoogleFonts.plusJakartaSans(color: c.background, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
