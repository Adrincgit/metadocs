import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class AnalisisIaPage extends StatelessWidget {
  const AnalisisIaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Análisis con IA',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
