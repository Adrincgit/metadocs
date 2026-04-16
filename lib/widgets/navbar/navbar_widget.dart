// lib/widgets/navbar/navbar_widget.dart
// Drawer mobile que expone el mismo Sidebar dentro de un Drawer de Flutter

import 'package:flutter/material.dart';
import 'package:nethive_neo/widgets/sidebar/sidebar_widget.dart';
import 'package:nethive_neo/theme/theme.dart';

/// Drawer used on mobile (≤ 768 px).
/// Pásalo al parámetro `drawer` del Scaffold en MainContainerPage.
class NavbarDrawer extends StatelessWidget {
  const NavbarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Drawer(
      width: 240,
      backgroundColor: t.isDark ? t.surface : const Color(0xFF15202E),
      shape: const RoundedRectangleBorder(),
      child: const SidebarWidget(),
    );
  }
}
