import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/theme/theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ProcesamientoPage extends StatefulWidget {
  const ProcesamientoPage({super.key});

  @override
  State<ProcesamientoPage> createState() => _ProcesamientoPageState();
}

class _ProcesamientoPageState extends State<ProcesamientoPage> {
  PlutoGridStateManager? _sm;
  String _filter = 'todos';

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  Color _estatusColor(String estatus, AppThemeData t) => switch (estatus) {
        'exitoso' => t.success,
        'error' => t.error,
        'parcial' => t.warning,
        'reintentando' => t.indigo,
        _ => t.neutral,
      };

  IconData _estatusIcon(String estatus) => switch (estatus) {
        'exitoso' => Icons.check_circle_outline,
        'error' => Icons.error_outline,
        'parcial' => Icons.warning_amber_outlined,
        'reintentando' => Icons.autorenew,
        _ => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final docs = MetaDocsMockData.documentos;
    final todos = MetaDocsMockData.resultados;

    final filtered = _filter == 'todos'
        ? todos
        : todos.where((r) => r.estatus == _filter).toList();

    final exitosos = todos.where((r) => r.estatus == 'exitoso').length;
    final errores = todos.where((r) => r.estatus == 'error').length;
    final parciales = todos.where((r) => r.estatus == 'parcial').length;
    final reintentando = todos.where((r) => r.estatus == 'reintentando').length;
    final avgMs = todos.isEmpty
        ? 0
        : (todos.fold(0, (s, r) => s + r.tiempoMs) ~/ todos.length);

    final pieData = [
      PieChartSectionData(
          value: exitosos.toDouble(),
          color: t.success,
          radius: 52,
          title: '$exitosos',
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      PieChartSectionData(
          value: errores.toDouble(),
          color: t.error,
          radius: 52,
          title: '$errores',
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      PieChartSectionData(
          value: parciales.toDouble(),
          color: t.warning,
          radius: 52,
          title: '$parciales',
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      PieChartSectionData(
          value: reintentando.toDouble(),
          color: t.indigo,
          radius: 52,
          title: '$reintentando',
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    ];

    final isMobile = MediaQuery.sizeOf(context).width < mobileSize;

    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Procesamiento OCR', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text('Cola de procesamiento y resultados de extraccion',
                      style: AppTheme.bodySmall(t)),
                ],
              )),
              if (!isMobile)
                OutlinedButton.icon(
                  onPressed: () => _showSnack('Reprocesando errores...'),
                  icon: Icon(Icons.autorenew, size: 15, color: t.warning),
                  label: Text('Reintentar errores',
                      style: AppTheme.button(t).copyWith(color: t.warning)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: t.warning.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ]),
            const SizedBox(height: 16),

            // KPI row + Pie chart (ocultamos chart en mobile)
            isMobile
                ? Wrap(spacing: 8, runSpacing: 8, children: [
                    _kpiCompact('Exitosos', '$exitosos', t.success, t),
                    _kpiCompact('Errores', '$errores', t.error, t),
                    _kpiCompact('Parciales', '$parciales', t.warning, t),
                    _kpiCompact('Prom.', '${avgMs}ms', t.info, t),
                  ])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Column(children: [
                            Row(children: [
                              _kpi('Exitosos', '$exitosos',
                                  Icons.check_circle_outline, t.success, t),
                              const SizedBox(width: 10),
                              _kpi('Errores', '$errores', Icons.error_outline,
                                  t.error, t),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              _kpi('Parciales', '$parciales',
                                  Icons.warning_amber_outlined, t.warning, t),
                              const SizedBox(width: 10),
                              _kpi('Tiempo prom.', '${avgMs}ms',
                                  Icons.timer_outlined, t.info, t),
                            ]),
                          ])),
                      const SizedBox(width: 14),
                      Expanded(
                          flex: 2,
                          child: Container(
                            height: 160,
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.cardDecoration(t),
                            child: Row(children: [
                              SizedBox(
                                height: 130,
                                width: 130,
                                child: PieChart(PieChartData(
                                    sections: pieData,
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 28)),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _legend('Exitoso', t.success, t),
                                  _legend('Error', t.error, t),
                                  _legend('Parcial', t.warning, t),
                                  _legend('Reintentando', t.indigo, t),
                                ],
                              ),
                            ]),
                          )),
                    ],
                  ),
            const SizedBox(height: 16),

            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final f in [
                  'todos',
                  'exitoso',
                  'error',
                  'parcial',
                  'reintentando'
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _filterChip(f, t),
                  ),
                const SizedBox(width: 8),
                Text('${filtered.length} registros',
                    style: AppTheme.caption(t)),
              ]),
            ),
            const SizedBox(height: 12),

            // Tabla / Cards
            Expanded(
              child: isMobile
                  ? _buildMobileCards(filtered, docs, t)
                  : Container(
                      decoration: AppTheme.tableDecoration(t),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: PlutoGrid(
                          columns: _procCols(t),
                          rows: _procRows(filtered, t),
                          onLoaded: (e) => _sm = e.stateManager,
                          configuration: _procConfig(t),
                          createFooter: (sm) {
                            sm.setPageSize(25, notify: false);
                            return PlutoPagination(sm);
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // -- PLUTOGRID HELPERS -------------------------------------
  List<PlutoColumn> _procCols(AppThemeData t) => [
        PlutoColumn(
          title: 'ID',
          field: 'id',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t)
                  .copyWith(fontSize: 11, color: t.textSecondary)),
        ),
        PlutoColumn(
          title: 'Documento',
          field: 'documento',
          type: PlutoColumnType.text(),
          width: 240,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t), overflow: TextOverflow.ellipsis),
        ),
        PlutoColumn(
          title: 'Motor OCR',
          field: 'motor',
          type: PlutoColumnType.text(),
          width: 120,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t).copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis),
        ),
        PlutoColumn(
          title: 'Tiempo (ms)',
          field: 'tiempoMs',
          type: PlutoColumnType.number(),
          width: 100,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text('${ctx.cell.value} ms',
              style: AppTheme.tableData(t).copyWith(color: t.info)),
        ),
        PlutoColumn(
          title: 'Campos',
          field: 'campos',
          type: PlutoColumnType.number(),
          width: 80,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) =>
              Text('${ctx.cell.value}', style: AppTheme.tableData(t)),
        ),
        PlutoColumn(
          title: 'Estatus',
          field: 'estatus',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final est = ctx.cell.value as String;
            final color = _estatusColor(est, t);
            return Row(children: [
              Icon(_estatusIcon(est), size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(est,
                      style: AppTheme.tableData(t)
                          .copyWith(color: color, fontSize: 11))),
            ]);
          },
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'accId',
          type: PlutoColumnType.text(),
          width: 90,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final id = ctx.cell.value as String;
            final est = ctx.row.cells['estatus']?.value as String? ?? '';
            return Row(mainAxisSize: MainAxisSize.min, children: [
              if (est == 'error' || est == 'parcial')
                _iconBtn(Icons.autorenew, t.warning,
                    () => _showSnack('Reintentando: $id')),
              _iconBtn(
                  Icons.info_outline, t.info, () => _showSnack('Detalle: $id')),
            ]);
          },
        ),
      ];

  List<PlutoRow> _procRows(List filtered, AppThemeData t) {
    final docs = MetaDocsMockData.documentos;
    return filtered.map((r) {
      final doc = docs.where((d) => d.id == r.documentoId).firstOrNull;
      return PlutoRow(cells: {
        'id': PlutoCell(value: r.id as String),
        'documento': PlutoCell(value: doc?.nombre ?? r.documentoId as String),
        'motor': PlutoCell(value: r.motorOCR as String),
        'tiempoMs': PlutoCell(value: r.tiempoMs as int),
        'campos': PlutoCell(value: r.camposExtraidos as int),
        'estatus': PlutoCell(value: r.estatus as String),
        'accId': PlutoCell(value: r.id as String),
      });
    }).toList();
  }

  PlutoGridConfiguration _procConfig(AppThemeData t) => PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBackgroundColor: t.surface,
          rowColor: t.surface,
          oddRowColor:
              t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF8FAFC),
          activatedColor: t.primary.withOpacity(0.10),
          gridBorderColor: Colors.transparent,
          borderColor: t.border,
          activatedBorderColor: t.primary,
          inactivatedBorderColor: Colors.transparent,
          columnTextStyle: AppTheme.tableHeader(t),
          cellTextStyle: AppTheme.tableData(t),
          iconColor: t.textDisabled,
          menuBackgroundColor: t.surface,
          columnHeight: 44,
          rowHeight: 44,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
          resizeMode: PlutoResizeMode.normal,
        ),
      );

  Widget _buildMobileCards(List filtered, List docs, AppThemeData t) {
    if (filtered.isEmpty) {
      return Center(child: Text('Sin registros', style: AppTheme.body(t)));
    }
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = filtered[i];
        final doc = docs.where((d) => d.id == r.documentoId).firstOrNull;
        final estColor = _estatusColor(r.estatus, t);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.border),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(_estatusIcon(r.estatus), size: 14, color: estColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(doc?.nombre ?? r.documentoId,
                    style:
                        AppTheme.body(t).copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: estColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: estColor.withOpacity(0.35)),
                ),
                child: Text(r.estatus.toUpperCase(),
                    style: TextStyle(
                        color: estColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Text(r.motorOCR,
                  style: AppTheme.caption(t).copyWith(color: t.textSecondary)),
              const Spacer(),
              Icon(Icons.timer_outlined, size: 12, color: t.info),
              const SizedBox(width: 3),
              Text('${r.tiempoMs} ms',
                  style: AppTheme.caption(t).copyWith(color: t.info)),
              const SizedBox(width: 10),
              Text('${r.camposExtraidos} campos', style: AppTheme.caption(t)),
            ]),
            if (r.errores.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Error: ${r.errores.first}',
                  style: AppTheme.caption(t).copyWith(color: t.error),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ]),
        );
      },
    );
  }

  Widget _kpi(
      String label, String value, IconData icon, Color color, AppThemeData t) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(t),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTheme.h3(t).copyWith(fontSize: 16)),
              Text(label, style: AppTheme.caption(t)),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _kpiCompact(String label, String value, Color color, AppThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value, style: AppTheme.h3(t).copyWith(color: color, fontSize: 16)),
        Text(label, style: AppTheme.caption(t)),
      ]),
    );
  }

  Widget _legend(String label, Color color, AppThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.caption(t)),
      ]),
    );
  }

  Widget _filterChip(String f, AppThemeData t) {
    final isActive = _filter == f;
    return InkWell(
      onTap: () => setState(() => _filter = f),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? t.primary : t.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? t.primary : t.border),
        ),
        child: Text(f == 'todos' ? 'Todos' : f,
            style: AppTheme.bodySmall(t).copyWith(
              color: isActive ? Colors.white : t.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
