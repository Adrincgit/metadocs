import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

// --- Color token data class ----------------------------------------------------
class AppThemeData {
  const AppThemeData({
    required this.primary,
    required this.primaryHover,
    required this.primarySoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
    required this.info,
    required this.infoSoft,
    required this.indigo,
    required this.indigoSoft,
    required this.neutral,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.isDark,
  });

  final Color primary;
  final Color primaryHover;
  final Color primarySoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;
  final Color info;
  final Color infoSoft;
  final Color indigo;
  final Color indigoSoft;
  final Color neutral;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final bool isDark;
}

// --- AppTheme — acceso a paleta, texto y Material ThemeData -------------------
abstract class AppTheme {
  // -- SharedPreferences propia (sin depender de globals.dart) -----------------
  static SharedPreferences? _prefs;

  static void initPrefs(SharedPreferences p) => _prefs = p;

  // -- Persistencia del modo ----------------------------------------------------
  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);

    // Para MetaDocs conviene iniciar oscuro por defecto
    if (darkMode == null) return ThemeMode.dark;

    return darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  // -- Gradientes útiles para headers, banners, highlights ---------------------
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF22D3EE),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A0E27),
      Color(0xFF111833),
    ],
  );

  // -- Paleta modo claro --------------------------------------------------------
  static const AppThemeData light = AppThemeData(
    primary: Color(0xFF6366F1),
    primaryHover: Color(0xFF5558E8),
    primarySoft: Color(0xFFEEF2FF),
    success: Color(0xFF10B981),
    successSoft: Color(0xFFECFDF5),
    warning: Color(0xFFF59E0B),
    warningSoft: Color(0xFFFFFBEB),
    error: Color(0xFFEF4444),
    errorSoft: Color(0xFFFEF2F2),
    info: Color(0xFF38BDF8),
    infoSoft: Color(0xFFF0F9FF),
    indigo: Color(0xFF8B5CF6),
    indigoSoft: Color(0xFFF5F3FF),
    neutral: Color(0xFF64748B),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textDisabled: Color(0xFF94A3B8),
    isDark: false,
  );

  // -- Paleta modo oscuro -------------------------------------------------------
  static const AppThemeData dark = AppThemeData(
    // Acento principal del sistema
    primary: Color(0xFF6366F1),
    primaryHover: Color(0xFF7C7FF8),
    primarySoft: Color(0xFF162045),

    // Estados
    success: Color(0xFF10B981),
    successSoft: Color(0xFF083D31),

    warning: Color(0xFFF59E0B),
    warningSoft: Color(0xFF4A2E05),

    error: Color(0xFFEF4444),
    errorSoft: Color(0xFF4A1113),

    // Info / IA / búsqueda / semantic search
    info: Color(0xFF22D3EE),
    infoSoft: Color(0xFF0C364D),

    // Violeta ocasional para módulos AI o énfasis secundarios
    indigo: Color(0xFF8B5CF6),
    indigoSoft: Color(0xFF312E81),

    neutral: Color(0xFF94A3B8),

    // Superficies Midnight Intelligence
    background: Color(0xFF0A0E27),
    surface: Color(0xFF111833),
    border: Color(0xFF22304F),

    textPrimary: Color(0xFFE9EEF7),
    textSecondary: Color(0xFFA8B3C7),
    textDisabled: Color(0xFF5D6881),

    isDark: true,
  );

  // -- Selector de tema según contexto ------------------------------------------
  static AppThemeData of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  // -- Estilos de texto (Inter) -------------------------------------------------
  static TextStyle h1(AppThemeData t) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: t.textPrimary,
        height: 1.15,
      );

  static TextStyle h2(AppThemeData t) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: t.textPrimary,
        height: 1.2,
      );

  static TextStyle h3(AppThemeData t) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: t.textPrimary,
        height: 1.25,
      );

  static TextStyle body(AppThemeData t) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: t.textPrimary,
        height: 1.45,
      );

  static TextStyle bodySmall(AppThemeData t) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: t.textSecondary,
        height: 1.4,
      );

  static TextStyle label(AppThemeData t) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: t.textSecondary,
        letterSpacing: 0.4,
      );

  static TextStyle caption(AppThemeData t) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: t.textDisabled,
      );

  static TextStyle kpi(AppThemeData t) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: t.textPrimary,
        height: 1.1,
      );

  static TextStyle tableData(AppThemeData t) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: t.textPrimary,
      );

  static TextStyle tableHeader(AppThemeData t) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: t.textSecondary,
        letterSpacing: 0.35,
      );

  static TextStyle sidebarItem(AppThemeData t) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: t.textSecondary,
      );

  static TextStyle sidebarGroup(AppThemeData t) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: t.textDisabled,
        letterSpacing: 1.1,
      );

  static TextStyle button(AppThemeData t) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: t.textPrimary,
      );

  static TextStyle badgeText(Color color) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.25,
      );

  // -- MaterialApp ThemeData ----------------------------------------------------
  static ThemeData materialLight() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: light.background,
        fontFamily: GoogleFonts.inter().fontFamily,
        dividerColor: light.border,
        cardColor: light.surface,
        shadowColor: Colors.black,
        splashColor: const Color(0x146366F1),
        hoverColor: const Color(0x0F6366F1),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF22D3EE),
          error: Color(0xFFEF4444),
          surface: Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: light.surface,
          hintStyle: TextStyle(color: light.textDisabled),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: light.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: light.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6366F1)),
          ),
        ),
      );

  static ThemeData materialDark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: dark.background,
        fontFamily: GoogleFonts.inter().fontFamily,
        dividerColor: dark.border,
        cardColor: dark.surface,
        shadowColor: Colors.black,
        splashColor: const Color(0x146366F1),
        hoverColor: const Color(0x0F6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF22D3EE),
          error: Color(0xFFEF4444),
          surface: Color(0xFF111833),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFE9EEF7),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF111833),
          hintStyle: const TextStyle(color: Color(0xFF5D6881)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF22304F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF22304F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6366F1)),
          ),
        ),
      );

  // -- Compatibilidad legacy ----------------------------------------------------
  static AppThemeData get lightTheme => light;
  static AppThemeData get darkTheme => dark;

  // -- Decoración estándar para cards -------------------------------------------
  static BoxDecoration cardDecoration(AppThemeData t) => BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(t.isDark ? 0.24 : 0.06),
            blurRadius: t.isDark ? 18 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // -- Decoración estándar para PlutoGrid container -----------------------------
  static BoxDecoration tableDecoration(AppThemeData t) => BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(t.isDark ? 0.20 : 0.05),
            blurRadius: t.isDark ? 16 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      );
}
