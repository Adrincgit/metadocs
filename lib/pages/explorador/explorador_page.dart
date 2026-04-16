import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class ExploradorPage extends StatelessWidget {
  const ExploradorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Explorador de Metadatos',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
