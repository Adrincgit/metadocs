import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class IntegracionesPage extends StatelessWidget {
  const IntegracionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Integraciones y Conectores',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
