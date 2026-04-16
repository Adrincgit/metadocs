import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class ConsultasPage extends StatelessWidget {
  const ConsultasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Consultas en Lenguaje Natural',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
