// lib/helpers/globals.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:nethive_neo/theme/theme.dart';

// ─── Keys globales ───────────────────────────────────────────────────────────
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

late final SharedPreferences prefs;

Future<void> initGlobals() async {
  prefs = await SharedPreferences.getInstance();
}

// ─── PlutoGrid configs enterprise ───────────────────────────────────────────

PlutoGridScrollbarConfig plutoGridScrollbarConfig(BuildContext context) {
  final t = AppTheme.of(context);
  return PlutoGridScrollbarConfig(
    isAlwaysShown: true,
    scrollbarThickness: 5,
    hoverWidth: 20,
    scrollBarColor: t.primary.withAlpha(120),
  );
}

PlutoGridStyleConfig plutoGridStyleConfig(BuildContext context,
    {double rowHeight = 50}) {
  final t = AppTheme.of(context);
  final cellStyle = AppTheme.tableData(t);
  final headerStyle = AppTheme.tableHeader(t);

  return t.isDark
      ? PlutoGridStyleConfig.dark(
          gridPopupBorderRadius: BorderRadius.circular(12),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: headerStyle,
          cellTextStyle: cellStyle,
          iconColor: t.textSecondary,
          rowColor: Colors.transparent,
          borderColor: t.border,
          rowHeight: rowHeight,
          checkedColor: t.primary.withAlpha(40),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: t.primary.withAlpha(30),
          activatedBorderColor: t.primary,
          menuBackgroundColor: t.surface,
        )
      : PlutoGridStyleConfig(
          gridPopupBorderRadius: BorderRadius.circular(12),
          enableColumnBorderVertical: false,
          enableColumnBorderHorizontal: false,
          enableCellBorderVertical: false,
          enableCellBorderHorizontal: true,
          columnTextStyle: headerStyle,
          cellTextStyle: cellStyle,
          iconColor: t.textSecondary,
          rowColor: Colors.transparent,
          borderColor: t.border,
          rowHeight: rowHeight,
          checkedColor: t.primary.withAlpha(30),
          enableRowColorAnimation: true,
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
          activatedColor: t.primarySoft.withAlpha(80),
          activatedBorderColor: t.primary,
          menuBackgroundColor: t.surface,
        );
}
