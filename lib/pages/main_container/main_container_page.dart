import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/providers/visual_state_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/header/header_widget.dart';
import 'package:nethive_neo/widgets/navbar/navbar_widget.dart';
import 'package:nethive_neo/widgets/sidebar/sidebar_widget.dart';

class MainContainerPage extends StatefulWidget {
  final Widget child;
  const MainContainerPage({super.key, required this.child});

  @override
  State<MainContainerPage> createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sincroniza ruta activa con VisualStateProvider (URL directa, back/forward)
    final route = GoRouterState.of(context).uri.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VisualStateProvider>().setCurrentRoute(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width <= mobileSize;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: t.background,
      drawer: isMobile ? const NavbarDrawer() : null,
      body: isMobile
          ? _MobileLayout(scaffoldKey: _scaffoldKey, child: widget.child)
          : _DesktopLayout(child: widget.child),
    );
  }
}

// ─── Layout Desktop ───────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final Widget child;
  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SidebarWidget(),
        Expanded(
          child: Column(
            children: [
              const HeaderWidget(),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Layout Mobile ────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final Widget child;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _MobileLayout({required this.child, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderWidget(scaffoldKey: scaffoldKey),
        Expanded(child: child),
      ],
    );
  }
}
