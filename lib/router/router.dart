import 'package:go_router/go_router.dart';

import 'package:metadocs/pages/pages.dart';
import 'package:metadocs/services/navigation_service.dart';

/// Router MetaDocs — AI Document Intelligence Demo
/// Todas las rutas usan NoTransitionPage (sin animaciones de transición).
final GoRouter router = GoRouter(
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => const PageNotFoundPage(),
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainContainerPage(child: child),
      routes: [
        // OVERVIEW
        GoRoute(
          path: '/',
          pageBuilder: (c, s) => const NoTransitionPage(child: DashboardPage()),
        ),
        // DOCUMENTS
        GoRoute(
          path: '/biblioteca',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: BibliotecaPage()),
        ),
        GoRoute(
          path: '/ingesta',
          pageBuilder: (c, s) => const NoTransitionPage(child: IngestaPage()),
        ),
        GoRoute(
          path: '/procesamiento',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: ProcesamientoPage()),
        ),
        // DATA
        GoRoute(
          path: '/explorador',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: ExploradorPage()),
        ),
        GoRoute(
          path: '/esquemas',
          pageBuilder: (c, s) => const NoTransitionPage(child: EsquemasPage()),
        ),
        // AI
        GoRoute(
          path: '/analisis-ia',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: AnalisisIaPage()),
        ),
        GoRoute(
          path: '/consultas',
          pageBuilder: (c, s) => const NoTransitionPage(child: ConsultasPage()),
        ),
        // INSIGHTS
        GoRoute(
          path: '/reportes',
          pageBuilder: (c, s) => const NoTransitionPage(child: ReportesPage()),
        ),
        // ADMIN
        GoRoute(
          path: '/integraciones',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: IntegracionesPage()),
        ),
        GoRoute(
          path: '/configuracion',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: ConfiguracionPage()),
        ),
        GoRoute(
          path: '/usuarios',
          pageBuilder: (c, s) => const NoTransitionPage(child: UsuariosPage()),
        ),
        GoRoute(
          path: '/auditoria',
          pageBuilder: (c, s) => const NoTransitionPage(child: AuditoriaPage()),
        ),
      ],
    ),
  ],
);
