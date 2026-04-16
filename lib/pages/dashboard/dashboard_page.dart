import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(child: Text('Dashboard', style: AppTheme.h2(t))),
    );
  }
}
