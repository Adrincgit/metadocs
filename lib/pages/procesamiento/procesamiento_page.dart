import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class ProcesamientoPage extends StatelessWidget {
  const ProcesamientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Procesamiento OCR / IA',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
