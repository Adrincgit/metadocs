// lib/widgets/header/header_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/providers/visual_state_provider.dart';
import 'package:metadocs/theme/theme.dart';

// ─── Mapa ruta → título ───────────────────────────────────────────────────────

const Map<String, String> _routeTitles = {
  '/': 'Dashboard',
  '/biblioteca': 'Biblioteca de Documentos',
  '/ingesta': 'Ingesta / Carga',
  '/procesamiento': 'Procesamiento OCR',
  '/explorador': 'Explorador de Metadatos',
  '/esquemas': 'Esquemas de Extracción',
  '/analisis-ia': 'Análisis con IA',
  '/consultas': 'Consultas en Lenguaje Natural',
  '/reportes': 'Reportes',
  '/integraciones': 'Integraciones y Conectores',
  '/configuracion': 'Configuración',
  '/usuarios': 'Usuarios y Roles',
  '/auditoria': 'Auditoría del Sistema',
};

const Map<String, String> _routeModules = {
  '/': 'Overview',
  '/biblioteca': 'Documents',
  '/ingesta': 'Documents',
  '/procesamiento': 'Documents',
  '/explorador': 'Data',
  '/esquemas': 'Data',
  '/analisis-ia': 'AI',
  '/consultas': 'AI',
  '/reportes': 'Insights',
  '/integraciones': 'Admin',
  '/configuracion': 'Admin',
  '/usuarios': 'Admin',
  '/auditoria': 'Admin',
};

// ─── Widget ───────────────────────────────────────────────────────────────────

class HeaderWidget extends StatelessWidget {
  /// Pasar el [scaffoldKey] cuando se use el drawer (mobile)
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HeaderWidget({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final provider = context.watch<VisualStateProvider>();
    final currentRoute = provider.currentRoute;
    final isDark = provider.isDark;

    final pageTitle = _routeTitles[currentRoute] ?? 'MetaDocs';
    final moduleLabel = _routeModules[currentRoute] ?? '';

    // Fecha en español
    final now = DateTime.now();
    final dateStr = DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(now);

    // En mobile (drawer activo) ocultamos la fecha para evitar overflow
    final isMobile = MediaQuery.sizeOf(context).width <= mobileSize;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(
          bottom: BorderSide(color: t.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Hamburger (solo mobile — si se pasa scaffoldKey)
          if (scaffoldKey != null) ...[
            IconButton(
              icon: Icon(Icons.menu, color: t.textPrimary),
              onPressed: () => scaffoldKey!.currentState?.openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 8),
          ],

          // ── Título ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pageTitle,
                  style: AppTheme.h2(t).copyWith(fontSize: isMobile ? 14 : 16),
                  overflow: TextOverflow.ellipsis,
                ),
                if (moduleLabel.isNotEmpty)
                  Text(
                    moduleLabel,
                    style: AppTheme.caption(t),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // ── Fecha (solo desktop) ─────────────────────────────────────────
          if (!isMobile) ...[
            Text(
              dateStr,
              style: AppTheme.caption(t).copyWith(
                color: t.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 20),
          ],

          // ── Toggle tema ──────────────────────────────────────────────────
          _ThemeToggle(isDark: isDark, onToggle: provider.toggleTheme),
          const SizedBox(width: 16),

          // ── Avatar de usuario simulado ───────────────────────────────────
          const _UserAvatar(),
        ],
      ),
    );
  }
}

// ─── Theme Toggle ─────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Tooltip(
      message: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 72,
          height: 34,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? t.primary : t.border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                size: 16,
                color: isDark ? t.primary : t.warning,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar de usuario ────────────────────────────────────────────────────────

class _UserAvatar extends StatefulWidget {
  const _UserAvatar();

  @override
  State<_UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<_UserAvatar> {
  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/avatares/Carlos.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'VR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carlos Mendoza',
              style: AppTheme.label(t).copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              'Administrador',
              style: AppTheme.caption(t),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Icon(Icons.expand_more, size: 16, color: t.textSecondary),
      ],
    );
  }
}
