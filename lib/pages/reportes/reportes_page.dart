import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(child: Text('Reportes', style: AppTheme.h2(t))),
    );
  }
}