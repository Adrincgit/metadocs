import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class AuditoriaPage extends StatelessWidget {
  const AuditoriaPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(child: Text('Auditoria del Sistema', style: AppTheme.h2(t))),
    );
  }
}