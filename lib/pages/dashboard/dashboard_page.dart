import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? _touchedPieIndex;

  late final int _totalDocs;
  late final int _pendientes;
  late final int _errores;
  late final int _enProceso;
  late final double _confianzaPromedio;
  late final int _camposExtraidos;
  late final List<double> _volumenMensual;
  late final Map<String, int> _porTipo;
  late final Map<String, int> _porEstatus;
  late final Map<String, int> _porOrigen;

  @override
  void initState() {
    super.initState();
    final docs = MetaDocsMockData.documentos;
    final resultados = MetaDocsMockData.resultados;

    _totalDocs = docs.length;
    _pendientes = docs.where((d) => d.estatus == 'pendiente').length;
    _errores = docs.where((d) => d.estatus == 'rechazado').length;
    _enProceso = docs.where((d) => d.estatus == 'procesando').length;

    final withConfidence = docs.where((d) => d.confianzaIA > 0).toList();
    _confianzaPromedio = withConfidence.isEmpty
        ? 0
        : withConfidence.fold<double>(0.0, (s, d) => s + d.confianzaIA) /
            withConfidence.length;
    _camposExtraidos = resultados.fold(0, (s, r) => s + r.camposExtraidos);

    final vol = List<double>.filled(12, 0);
    for (final d in docs) {
      final m = d.fechaIngesta.month - 1;
      if (m >= 0 && m < 12) vol[m]++;
    }
    _volumenMensual = vol;

    _porTipo = {};
    for (final d in docs) {
      _porTipo[d.tipoDocumental] = (_porTipo[d.tipoDocumental] ?? 0) + 1;
    }
    _porEstatus = {};
    for (final d in docs) {
      _porEstatus[d.estatus] = (_porEstatus[d.estatus] ?? 0) + 1;
    }
    _porOrigen = {};
    for (final d in docs) {
      _porOrigen[d.origen] = (_porOrigen[d.origen] ?? 0) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: AppTheme.h1(t)),
            const SizedBox(height: 4),
            Text('Resumen operativo · 7 de marzo de 2026',
                style: AppTheme.bodySmall(t)),
            const SizedBox(height: 24),
            _kpiRow(t),
            const SizedBox(height: 20),
            _chartsRow1(t),
            const SizedBox(height: 20),
            _chartsRow2(t),
            const SizedBox(height: 20),
            _bottomRow(t),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── KPI Row ──────────────────────────────────────────────────────────────
  Widget _kpiRow(AppThemeData t) {
    final kpis = [
      _KpiData('Total Documentos', '$_totalDocs',
          Icons.description_outlined, t.primary, t.primarySoft),
      _KpiData('Pendientes de OCR', '$_pendientes',
          Icons.hourglass_empty_rounded, t.warning, t.warningSoft),
      _KpiData('Rechazados', '$_errores',
          Icons.error_outline_rounded, t.error, t.errorSoft),
      _KpiData('En Procesamiento', '$_enProceso',
          Icons.sync_rounded, t.info, t.infoSoft),
      _KpiData('Confianza IA prom.',
          '${(_confianzaPromedio * 100).toStringAsFixed(1)} %',
          Icons.psychology_outlined, t.indigo, t.indigoSoft),
      _KpiData('Campos Extraídos', '$_camposExtraidos',
          Icons.data_object_rounded, t.success, t.successSoft),
    ];
    return LayoutBuilder(builder: (_, box) {
      final cols = box.maxWidth > 900
          ? 6
          : box.maxWidth > 600
              ? 3
              : 2;
      final spacing = 12.0;
      final w = (box.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: kpis
            .map((k) => SizedBox(width: w, child: _KpiCard(data: k, t: t)))
            .toList(),
      );
    });
  }

  // ── Charts row 1: Line + Pie ──────────────────────────────────────────────
  Widget _chartsRow1(AppThemeData t) {
    return SizedBox(
      height: 280,
      child: Row(children: [
        Expanded(flex: 3, child: _lineChart(t)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _pieChart(t)),
      ]),
    );
  }

  // ── Charts row 2: Bar + Origen ────────────────────────────────────────────
  Widget _chartsRow2(AppThemeData t) {
    return SizedBox(
      height: 240,
      child: Row(children: [
        Expanded(flex: 3, child: _barChartTipo(t)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _origenChart(t)),
      ]),
    );
  }

  // ── Bottom row: Activity + Alerts ─────────────────────────────────────────
  Widget _bottomRow(AppThemeData t) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _recentActivity(t)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _alerts(t)),
      ],
    );
  }

  // ── Line Chart ────────────────────────────────────────────────────────────
  Widget _lineChart(AppThemeData t) {
    const labels = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final spots = List.generate(
        12, (i) => FlSpot(i.toDouble(), _volumenMensual[i]));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Volumen de Ingesta Mensual', style: AppTheme.h3(t)),
        const SizedBox(height: 2),
        Text('Documentos procesados por mes — 2026',
            style: AppTheme.bodySmall(t)),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(LineChartData(
            minX: 0,
            maxX: 11,
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: t.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: AppTheme.caption(t),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= 12) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels[i], style: AppTheme.caption(t)),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
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
      ]),
    );
  }

  // ── Pie Chart ─────────────────────────────────────────────────────────────
  Widget _pieChart(AppThemeData t) {
    final colorMap = {
      'revisado': t.success,
      'extraido': t.info,
      'pendiente': t.warning,
      'procesando': t.indigo,
      'rechazado': t.error,
      'archivado': t.neutral,
    };
    final entries = _porEstatus.entries.toList();
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < entries.length; i++) {
      final touched = i == _touchedPieIndex;
      final color = colorMap[entries[i].key] ?? t.neutral;
      sections.add(PieChartSectionData(
        value: entries[i].value.toDouble(),
        color: color,
        radius: touched ? 62 : 52,
        title: touched ? '${entries[i].value}' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Por Estatus', style: AppTheme.h3(t)),
        const SizedBox(height: 8),
        Expanded(
          child: Row(children: [
            Expanded(
              child: PieChart(PieChartData(
                sections: sections,
                centerSpaceRadius: 34,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (evt, res) => setState(() {
                    _touchedPieIndex =
                        (evt.isInterestedForInteractions &&
                                res?.touchedSection != null)
                            ? res!.touchedSection!.touchedSectionIndex
                            : null;
                  }),
                ),
              )),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.map((e) {
                final c = colorMap[e.key] ?? t.neutral;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: c, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 5),
                    Text('${e.key} (${e.value})',
                        style: AppTheme.caption(t)),
                  ]),
                );
              }).toList(),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Bar Chart por Tipo ────────────────────────────────────────────────────
  Widget _barChartTipo(AppThemeData t) {
    final sorted = _porTipo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(8).toList();
    final groups = List.generate(top.length, (i) {
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: top[i].value.toDouble(),
          color: t.primary,
          width: 24,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ]);
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Documentos por Tipo', style: AppTheme.h3(t)),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            barGroups: groups,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: t.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (v, _) =>
                      Text('${v.toInt()}', style: AppTheme.caption(t)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= top.length) {
                      return const SizedBox.shrink();
                    }
                    final full = top[i].key;
                    final label =
                        full.length > 7 ? '${full.substring(0, 6)}…' : full;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(label,
                          style: AppTheme.caption(t),
                          textAlign: TextAlign.center),
                    );
                  },
                ),
              ),
            ),
          )),
        ),
      ]),
    );
  }

  // ── Origen Chart ──────────────────────────────────────────────────────────
  Widget _origenChart(AppThemeData t) {
    final labelMap = {
      'email': 'Email',
      'carga_manual': 'Manual',
      'escaner': 'Escáner',
      'api': 'API REST',
      'integracion': 'Integración',
    };
    final sorted = _porOrigen.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold(0, (s, e) => s + e.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Por Origen', style: AppTheme.h3(t)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: sorted.map((e) {
              final pct = total > 0 ? e.value / total : 0.0;
              final label = labelMap[e.key] ?? e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: AppTheme.bodySmall(t)),
                        Text('${e.value}', style: AppTheme.label(t)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: t.border,
                        valueColor: AlwaysStoppedAnimation<Color>(t.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ── Recent Activity ───────────────────────────────────────────────────────
  Widget _recentActivity(AppThemeData t) {
    final recent = MetaDocsMockData.auditoriaEventos.take(6).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Actividad Reciente', style: AppTheme.h3(t)),
        const SizedBox(height: 14),
        ...recent.map((evt) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _accionColor(evt.accion, t).withOpacity(0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(_accionIcon(evt.accion),
                  color: _accionColor(evt.accion, t), size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evt.descripcion,
                      style: AppTheme.bodySmall(t)
                          .copyWith(color: t.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${evt.usuario} · ${evt.modulo}',
                      style: AppTheme.caption(t)),
                ],
              ),
            ),
          ]),
        )),
      ]),
    );
  }

  // ── Alerts ────────────────────────────────────────────────────────────────
  Widget _alerts(AppThemeData t) {
    final errDocs =
        MetaDocsMockData.documentos.where((d) => d.estatus == 'rechazado');
    final pendDocs =
        MetaDocsMockData.documentos.where((d) => d.estatus == 'pendiente');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.notifications_outlined, size: 17, color: t.warning),
          const SizedBox(width: 6),
          Text('Alertas del Sistema', style: AppTheme.h3(t)),
        ]),
        const SizedBox(height: 14),
        _AlertItem(
          icon: Icons.cancel_outlined,
          color: t.error,
          title: '${errDocs.length} documentos rechazados',
          subtitle: 'Confianza IA < 65 % — revisión manual requerida',
          t: t,
        ),
        const SizedBox(height: 8),
        _AlertItem(
          icon: Icons.hourglass_bottom_rounded,
          color: t.warning,
          title: '${pendDocs.length} pendientes de OCR',
          subtitle: 'En cola · sin procesamiento iniciado',
          t: t,
        ),
        const SizedBox(height: 8),
        _AlertItem(
          icon: Icons.wifi_off_rounded,
          color: t.info,
          title: 'Email IMAP en revisión',
          subtitle: 'Certificado SSL expirado — verificar',
          t: t,
        ),
      ]),
    );
  }

  Color _accionColor(String a, AppThemeData t) => switch (a) {
        'subir' => t.success,
        'extraer' => t.info,
        'revisar' => t.primary,
        'rechazar' => t.error,
        'archivar' => t.neutral,
        _ => t.warning,
      };

  IconData _accionIcon(String a) => switch (a) {
        'subir' => Icons.upload_file_outlined,
        'extraer' => Icons.manage_search_outlined,
        'revisar' => Icons.fact_check_outlined,
        'rechazar' => Icons.cancel_outlined,
        'archivar' => Icons.archive_outlined,
        _ => Icons.settings_outlined,
      };
}

// ── KPI helpers ───────────────────────────────────────────────────────────────
class _KpiData {
  const _KpiData(
      this.label, this.value, this.icon, this.color, this.softColor);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color softColor;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data, required this.t});
  final _KpiData data;
  final AppThemeData t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(data.value, style: AppTheme.kpi(t)),
          const SizedBox(height: 4),
          Text(data.label, style: AppTheme.bodySmall(t)),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.t,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final AppThemeData t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTheme.body(t)
                      .copyWith(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTheme.caption(t)),
            ],
          ),
        ),
      ]),
    );
  }
}

