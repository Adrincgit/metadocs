// lib/widgets/sidebar/sidebar_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/providers/visual_state_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

// ─── Modelos de datos internos ───────────────────────────────────────────────

class _MenuEntry {
  final String label;
  final IconData icon;
  final String route;
  const _MenuEntry(this.label, this.icon, this.route);
}

class _MenuGroup {
  final String label;
  final Color Function(AppThemeData) accentFn;
  final List<_MenuEntry> entries;
  const _MenuGroup(this.label, this.accentFn, this.entries);
}

// ─── Definición del menú ─────────────────────────────────────────────────────

final List<_MenuGroup> _groups = [
  _MenuGroup('OVERVIEW', (t) => t.primary, [
    _MenuEntry('Dashboard', Icons.dashboard_outlined, '/'),
  ]),
  _MenuGroup('DOCUMENTS', (t) => t.indigo, [
    _MenuEntry('Biblioteca', Icons.folder_open_outlined, '/biblioteca'),
    _MenuEntry('Ingesta / Carga', Icons.upload_file_outlined, '/ingesta'),
    _MenuEntry(
        'Procesamiento OCR', Icons.document_scanner_outlined, '/procesamiento'),
  ]),
  _MenuGroup('DATA', (t) => t.info, [
    _MenuEntry('Explorador', Icons.manage_search_outlined, '/explorador'),
    _MenuEntry('Esquemas', Icons.schema_outlined, '/esquemas'),
  ]),
  _MenuGroup('AI', (t) => t.indigo, [
    _MenuEntry('Análisis con IA', Icons.auto_awesome_outlined, '/analisis-ia'),
    _MenuEntry('Consultas', Icons.chat_outlined, '/consultas'),
  ]),
  _MenuGroup('INSIGHTS', (t) => t.success, [
    _MenuEntry('Reportes', Icons.bar_chart_outlined, '/reportes'),
  ]),
  _MenuGroup('ADMIN', (t) => t.neutral, [
    _MenuEntry('Integraciones', Icons.cable_outlined, '/integraciones'),
    _MenuEntry('Configuración', Icons.settings_outlined, '/configuracion'),
    _MenuEntry('Usuarios y Roles', Icons.manage_accounts_outlined, '/usuarios'),
    _MenuEntry('Auditoría', Icons.history_edu_outlined, '/auditoria'),
  ]),
];

// ─── Widget principal ─────────────────────────────────────────────────────────

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final currentRoute =
        context.select<VisualStateProvider, String>((p) => p.currentRoute);

    final bgColor = t.isDark ? t.surface : const Color(0xFF15202E);

    return Container(
      width: 240,
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──────────────────────────────────────────────────────────
          const _SidebarLogo(),

          // ── Grupos de módulos ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _groups.map((group) {
                  final accent = group.accentFn(t);
                  return _GroupSection(
                    group: group,
                    accent: accent,
                    currentRoute: currentRoute,
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Botón salir ───────────────────────────────────────────────────
          const _ExitButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Logo ─────────────────────────────────────────────────────────────────────

class _SidebarLogo extends StatelessWidget {
  const _SidebarLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(40),
        border: Border(
          bottom: BorderSide(color: Colors.white.withAlpha(20)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withAlpha(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/favicon.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MetaDocs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'AI Document Intelligence',
                  style: TextStyle(
                    color: Colors.white.withAlpha(130),
                    fontSize: 9.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sección de grupo ─────────────────────────────────────────────────────────

class _GroupSection extends StatelessWidget {
  final _MenuGroup group;
  final Color accent;
  final String currentRoute;

  const _GroupSection({
    required this.group,
    required this.accent,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 11,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                group.label,
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        ...group.entries.map((entry) => _SidebarMenuItem(
              entry: entry,
              accent: accent,
              isActive: currentRoute == entry.route,
            )),
      ],
    );
  }
}

// ─── Ítem de menú ─────────────────────────────────────────────────────────────

class _SidebarMenuItem extends StatefulWidget {
  final _MenuEntry entry;
  final Color accent;
  final bool isActive;

  const _SidebarMenuItem({
    required this.entry,
    required this.accent,
    required this.isActive,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final accent = widget.accent;

    final bgColor = isActive
        ? accent.withAlpha(45)
        : _hovered
            ? Colors.white.withAlpha(12)
            : Colors.transparent;

    final textColor = isActive
        ? Colors.white
        : _hovered
            ? Colors.white.withAlpha(220)
            : Colors.white.withAlpha(160);

    final iconColor = isActive ? accent : textColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          context
              .read<VisualStateProvider>()
              .setCurrentRoute(widget.entry.route);
          context.go(widget.entry.route);
          // Cierra drawer si está abierto (mobile)
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border(left: BorderSide(color: accent, width: 2.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.entry.icon, size: 17, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.entry.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Botón Salir ──────────────────────────────────────────────────────────────

class _ExitButton extends StatefulWidget {
  const _ExitButton();

  @override
  State<_ExitButton> createState() => _ExitButtonState();
}

class _ExitButtonState extends State<_ExitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () async {
            final uri = Uri.parse(exitUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, webOnlyWindowName: '_self');
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _hovered
                  ? const Color(0xFF8B1A1A).withAlpha(80)
                  : Colors.white.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered
                    ? const Color(0xFFEF5350).withAlpha(160)
                    : Colors.white.withAlpha(65),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: _hovered
                      ? const Color(0xFFEF9A9A)
                      : Colors.white.withAlpha(190),
                ),
                const SizedBox(width: 10),
                Text(
                  'Salir de la Demo',
                  style: TextStyle(
                    color: _hovered
                        ? const Color(0xFFEF9A9A)
                        : Colors.white.withAlpha(190),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
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
