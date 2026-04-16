import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/theme/theme.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  int _period = 0; // 0=mes, 1=trimestre, 2=año

  void _showSnack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < mobileSize;
    final docs = MetaDocsMockData.documentos;
    final resultados = MetaDocsMockData.resultados;

    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final docsPerMonth = List.generate(12, (i) {
      final mes = i + 1;
      return docs.where((d) => d.fechaIngesta.month == mes).length.toDouble();
    });
    final exitoPerMonth = List.generate(12, (i) {
      final mes = i + 1;
      final docsDelMes = docs.where((d) => d.fechaIngesta.month == mes).toList();
      if (docsDelMes.isEmpty) return 0.0;
      final exitosos = docsDelMes
          .where((d) => d.estatus == 'revisado' || d.estatus == 'extraido')
          .length;
      return (exitosos / docsDelMes.length * 100).clamp(0.0, 100.0);
    });
    final tipoCount = <String, int>{};
    for (final d in docs) {
      tipoCount[d.tipoDocumental] = (tipoCount[d.tipoDocumental] ?? 0) + 1;
    }
    final tiposOrdenados = tipoCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final tiemposPorTipo = <String, List<int>>{};
    for (final r in resultados) {
      final doc = docs.where((d) => d.id == r.documentoId).firstOrNull;
      if (doc == null || r.tiempoMs == 0) continue;
      tiemposPorTipo.putIfAbsent(doc.tipoDocumental, () => []).add(r.tiempoMs);
    }

    return ColoredBox(
      color: t.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (isMobile) ...[
              Text('Reportes', style: AppTheme.h1(t)),
              const SizedBox(height: 4),
              Text('Analisis de rendimiento del sistema de gestion documental',
                  style: AppTheme.bodySmall(t)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _periodBtn('Mes', 0, t),
                  const SizedBox(width: 6),
                  _periodBtn('Trim.', 1, t),
                  const SizedBox(width: 6),
                  _periodBtn('Anno', 2, t),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showSnack('Exportando reporte PDF...'),
                    icon: Icon(Icons.picture_as_pdf_outlined, size: 15, color: t.error),
                    label: Text('PDF', style: AppTheme.button(t).copyWith(color: t.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.error.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: () => _showSnack('Exportando reporte Excel...'),
                    icon: Icon(Icons.table_chart_outlined, size: 15, color: t.success),
                    label: Text('Excel',
                        style: AppTheme.button(t).copyWith(color: t.success)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.success.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ]),
              ),
            ] else
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reportes', style: AppTheme.h1(t)),
                      const SizedBox(height: 4),
                      Text(
                          'Analisis de rendimiento del sistema de gestion documental',
                          style: AppTheme.bodySmall(t)),
                    ],
                  ),
                ),
                _periodBtn('Mes', 0, t),
                const SizedBox(width: 6),
                _periodBtn('Trim.', 1, t),
                const SizedBox(width: 6),
                _periodBtn('Anno', 2, t),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showSnack('Exportando reporte PDF...'),
                  icon: Icon(Icons.picture_as_pdf_outlined, size: 15, color: t.error),
                  label: Text('PDF', style: AppTheme.button(t).copyWith(color: t.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: t.error.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: () => _showSnack('Exportando reporte Excel...'),
                  icon: Icon(Icons.table_chart_outlined, size: 15, color: t.success),
                  label: Text('Excel',
                      style: AppTheme.button(t).copyWith(color: t.success)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: t.success.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
            const SizedBox(height: 20),

            // KPIs
            if (isMobile) ...[
              Row(children: [
                _kpi('Total documentos', '${docs.length}',
                    Icons.folder_copy_outlined, t.primary, t),
                const SizedBox(width: 10),
                _kpi(
                    'Procesados',
                    '${docs.where((d) => d.estatus == "revisado" || d.estatus == "extraido").length}',
                    Icons.check_circle_outline,
                    t.success,
                    t),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _kpi(
                    'Tasa de exito',
                    '${(docs.where((d) => d.estatus == "revisado" || d.estatus == "extraido").length / docs.length * 100).toStringAsFixed(1)} %',
                    Icons.percent,
                    t.indigo,
                    t),
                const SizedBox(width: 10),
                _kpi(
                    'Confianza prom.',
                    '${(docs.fold(0.0, (s, d) => s + d.confianzaIA) / docs.length * 100).toStringAsFixed(1)} %',
                    Icons.psychology_outlined,
                    t.info,
                    t),
              ]),
            ] else
              Row(children: [
                _kpi('Total documentos', '${docs.length}',
                    Icons.folder_copy_outlined, t.primary, t),
                const SizedBox(width: 12),
                _kpi(
                    'Procesados con exito',
                    '${docs.where((d) => d.estatus == "revisado" || d.estatus == "extraido").length}',
                    Icons.check_circle_outline,
                    t.success,
                    t),
                const SizedBox(width: 12),
                _kpi(
                    'Tasa de exito',
                    '${(docs.where((d) => d.estatus == "revisado" || d.estatus == "extraido").length / docs.length * 100).toStringAsFixed(1)} %',
                    Icons.percent,
                    t.indigo,
                    t),
                const SizedBox(width: 12),
                _kpi(
                    'Confianza promedio',
                    '${(docs.fold(0.0, (s, d) => s + d.confianzaIA) / docs.length * 100).toStringAsFixed(1)} %',
                    Icons.psychology_outlined,
                    t.info,
                    t),
              ]),
            const SizedBox(height: 16),

            // Charts: Volumen + Tipo
            if (isMobile) ...[
              _buildVolumeChartCard(t, docsPerMonth, meses),
              const SizedBox(height: 12),
              _buildTipoChartCard(t, tiposOrdenados),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 3,
                      child: _buildVolumeChartCard(t, docsPerMonth, meses)),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2, child: _buildTipoChartCard(t, tiposOrdenados)),
                ],
              ),
            const SizedBox(height: 12),

            // Charts: Exito + Tiempo
            if (isMobile) ...[
              _buildExitoChartCard(t, exitoPerMonth, meses),
              const SizedBox(height: 12),
              _buildTiempoCard(t, tiemposPorTipo),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 3,
                      child: _buildExitoChartCard(t, exitoPerMonth, meses)),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2, child: _buildTiempoCard(t, tiemposPorTipo)),
                ],
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Chart cards ──────────────────────────────────────────────────────────

  Widget _buildVolumeChartCard(
      AppThemeData t, List<double> docsPerMonth, List<String> meses) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Volumen de documentos - 2026', style: AppTheme.h3(t)),
          const SizedBox(height: 4),
          Text('Documentos ingestados por mes', style: AppTheme.caption(t)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: t.border.withOpacity(0.4),
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= 12) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(meses[i],
                            style: AppTheme.caption(t).copyWith(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 5,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: AppTheme.caption(t).copyWith(fontSize: 10),
                    ),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                      12, (i) => FlSpot(i.toDouble(), docsPerMonth[i])),
                  isCurved: true,
                  color: t.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: t.primary.withOpacity(0.10),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoChartCard(
      AppThemeData t, List<MapEntry<String, int>> tiposOrdenados) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Por tipo documental', style: AppTheme.h3(t)),
          const SizedBox(height: 4),
          Text('Distribucion del corpus', style: AppTheme.caption(t)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: t.border.withOpacity(0.4),
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= tiposOrdenados.length) {
                        return const SizedBox.shrink();
                      }
                      final label = tiposOrdenados[i].key;
                      final short =
                          label.length > 8 ? label.substring(0, 7) : label;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(short,
                            style: AppTheme.caption(t).copyWith(fontSize: 8),
                            textAlign: TextAlign.center),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 5,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: AppTheme.caption(t).copyWith(fontSize: 10),
                    ),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: tiposOrdenados.asMap().entries.map((e) {
                final colors = [
                  t.primary,
                  t.info,
                  t.success,
                  t.indigo,
                  t.warning,
                  t.error,
                  t.neutral,
                  t.primary
                ];
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value.toDouble(),
                      color: colors[e.key % colors.length],
                      width: 18,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildExitoChartCard(
      AppThemeData t, List<double> exitoPerMonth, List<String> meses) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tasa de exito en procesamiento', style: AppTheme.h3(t)),
          const SizedBox(height: 4),
          Text('Porcentaje de documentos revisados/extraidos por mes',
              style: AppTheme.caption(t)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: t.border.withOpacity(0.4),
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= 12) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(meses[i],
                            style: AppTheme.caption(t).copyWith(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 20,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()} %',
                      style: AppTheme.caption(t).copyWith(fontSize: 9),
                    ),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                      12, (i) => FlSpot(i.toDouble(), exitoPerMonth[i])),
                  isCurved: true,
                  color: t.success,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: t.success.withOpacity(0.10),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTiempoCard(
      AppThemeData t, Map<String, List<int>> tiemposPorTipo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tiempo prom. de procesamiento', style: AppTheme.h3(t)),
          const SizedBox(height: 4),
          Text('Por tipo documental (ms)', style: AppTheme.caption(t)),
          const SizedBox(height: 14),
          ...tiemposPorTipo.entries.take(8).map((e) {
            final avg = e.value.fold(0, (s, v) => s + v) ~/ e.value.length;
            const maxMs = 8000;
            final pct = (avg / maxMs).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(e.key,
                          style: AppTheme.bodySmall(t),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text('$avg ms',
                        style: AppTheme.caption(t).copyWith(
                            color: t.info, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: t.border,
                      valueColor: AlwaysStoppedAnimation<Color>(t.info),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _kpi(String label, String value, IconData icon, Color color,
      AppThemeData t) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(t),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
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

  Widget _periodBtn(String label, int idx, AppThemeData t) {
    final isActive = _period == idx;
    return InkWell(
      onTap: () => setState(() => _period = idx),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? t.primary : t.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? t.primary : t.border),
        ),
        child: Text(label,
            style: AppTheme.bodySmall(t).copyWith(
              color: isActive ? Colors.white : t.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}