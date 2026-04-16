import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class EsquemasPage extends StatelessWidget {
  const EsquemasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Esquemas de Extracción',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
