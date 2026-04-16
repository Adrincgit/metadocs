import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/theme/theme.dart';

class ProcesamientoPage extends StatefulWidget {
  const ProcesamientoPage({super.key});

  @override
  State<ProcesamientoPage> createState() => _ProcesamientoPageState();
}

class _ProcesamientoPageState extends State<ProcesamientoPage> {
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

    var filtered = _filter == 'todos'
        ? todos
        : todos.where((r) => r.estatus == _filter).toList();

    // KPIs
    final exitosos = todos.where((r) => r.estatus == 'exitoso').length;
    final errores = todos.where((r) => r.estatus == 'error').length;
    final parciales = todos.where((r) => r.estatus == 'parcial').length;
    final reintentando = todos.where((r) => r.estatus == 'reintentando').length;
    final avgMs = todos.isEmpty ? 0 : (todos.fold(0, (s, r) => s + r.tiempoMs) ~/ todos.length);

    // Pie chart data
    final pieData = [
      PieChartSectionData(value: exitosos.toDouble(), color: t.success, radius: 52, title: '${exitosos}', titleStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: errores.toDouble(), color: t.error, radius: 52, title: '${errores}', titleStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: parciales.toDouble(), color: t.warning, radius: 52, title: '${parciales}', titleStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: reintentando.toDouble(), color: t.indigo, radius: 52, title: '${reintentando}', titleStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    ];

    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Procesamiento OCR', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text('Cola de procesamiento y resultados de extracción',
                      style: AppTheme.bodySmall(t)),
                ],
              )),
              OutlinedButton.icon(
                onPressed: () => _showSnack('Reprocesando errores…'),
                icon: Icon(Icons.autorenew, size: 15, color: t.warning),
                label: Text('Reintentar errores',
                    style: AppTheme.button(t).copyWith(color: t.warning)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: t.warning.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // KPI row + Pie chart
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPIs 2x2
                Expanded(
                  flex: 3,
                  child: Column(children: [
                    Row(children: [
                      _kpi('Exitosos', '$exitosos', Icons.check_circle_outline, t.success, t),
                      const SizedBox(width: 10),
                      _kpi('Errores', '$errores', Icons.error_outline, t.error, t),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      _kpi('Parciales', '$parciales', Icons.warning_amber_outlined, t.warning, t),
                      const SizedBox(width: 10),
                      _kpi('Tiempo prom.', '${avgMs} ms', Icons.timer_outlined, t.info, t),
                    ]),
                  ]),
                ),

                const SizedBox(width: 14),

                // Pie chart
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
                          centerSpaceRadius: 28,
                        )),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter tabs
            Row(children: [
              for (final f in ['todos', 'exitoso', 'error', 'parcial', 'reintentando'])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _filterChip(f, t),
                ),
              const Spacer(),
              Text('${filtered.length} registros', style: AppTheme.caption(t)),
            ]),
            const SizedBox(height: 12),

            // Tabla
            Expanded(
              child: Container(
                decoration: AppTheme.tableDecoration(t),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      Container(
                        color: t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF1F5FF),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(children: [
                          SizedBox(width: 110, child: Text('ID', style: AppTheme.tableHeader(t))),
                          Expanded(child: Text('Documento', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 120, child: Text('Motor OCR', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 100, child: Text('Tiempo (ms)', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 80, child: Text('Campos', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 110, child: Text('Estatus', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 100, child: Text('Acciones', style: AppTheme.tableHeader(t))),
                        ]),
                      ),
                      Divider(color: t.border, height: 1),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(color: t.border, height: 1),
                          itemBuilder: (_, i) {
                            final r = filtered[i];
                            final doc = docs.where((d) => d.id == r.documentoId).firstOrNull;
                            final isOdd = i.isOdd;
                            final estColor = _estatusColor(r.estatus, t);
                            return Container(
                              color: isOdd
                                  ? (t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF8FAFC))
                                  : t.surface,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(children: [
                                SizedBox(width: 110, child: Text(r.id, style: AppTheme.tableData(t).copyWith(fontSize: 11, color: t.textSecondary))),
                                Expanded(child: Text(doc?.nombre ?? r.documentoId, style: AppTheme.tableData(t), overflow: TextOverflow.ellipsis)),
                                SizedBox(width: 120, child: Text(r.motorOCR, style: AppTheme.tableData(t).copyWith(fontSize: 11), overflow: TextOverflow.ellipsis)),
                                SizedBox(width: 100, child: Text('${r.tiempoMs} ms', style: AppTheme.tableData(t).copyWith(color: t.info))),
                                SizedBox(width: 80, child: Text('${r.camposExtraidos}', style: AppTheme.tableData(t))),
                                SizedBox(
                                  width: 110,
                                  child: Row(children: [
                                    Icon(_estatusIcon(r.estatus), size: 14, color: estColor),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(r.estatus, style: AppTheme.tableData(t).copyWith(color: estColor, fontSize: 11))),
                                  ]),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    if (r.estatus == 'error' || r.estatus == 'parcial')
                                      _iconBtn(Icons.autorenew, t.warning,
                                          () => _showSnack('Reintentando: ${r.id}')),
                                    _iconBtn(Icons.info_outline, t.info,
                                        () => _showSnack('Detalle: ${r.id} — ${r.errores.isEmpty ? "Sin errores" : r.errores.first}')),
                                  ]),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color, AppThemeData t) {
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
          Expanded(child: Column(
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

  Widget _legend(String label, Color color, AppThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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