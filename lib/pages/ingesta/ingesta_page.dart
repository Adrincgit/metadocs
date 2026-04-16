import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/theme/theme.dart';

class IngestaPage extends StatefulWidget {
  const IngestaPage({super.key});

  @override
  State<IngestaPage> createState() => _IngestaPageState();
}

class _IngestaPageState extends State<IngestaPage> {
  bool _dragOver = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final docs = MetaDocsMockData.documentos;
    final recent = docs.reversed.take(10).toList();

    // KPIs de sesión (simulados)
    final hoy = docs
        .where((d) => d.fechaIngesta.day == 7 && d.fechaIngesta.month == 3)
        .toList();
    final totalKb = docs.fold(0, (s, d) => s + d.tamanoKb);
    final resultados = MetaDocsMockData.resultados;
    final tiemposProcesados = resultados.where((r) => r.tiempoMs > 0).toList();
    final tiempoPromedio = tiemposProcesados.isEmpty
        ? 0
        : tiemposProcesados.fold(0, (s, r) => s + r.tiempoMs) ~/
            tiemposProcesados.length;

    return ColoredBox(
      color: t.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingesta de Documentos', style: AppTheme.h1(t)),
            const SizedBox(height: 4),
            Text('Carga manual, escáner, email y API',
                style: AppTheme.bodySmall(t)),
            const SizedBox(height: 24),

            // KPIs
            _kpiRow(t, hoy.length, totalKb, tiempoPromedio),
            const SizedBox(height: 20),

            // Main area: Drop + Reglas
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _dropArea(t)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _reglasPanel(t)),
              ],
            ),
            const SizedBox(height: 20),

            // Queue + Sources
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _colaPanel(t, recent)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _origenesPanel(t)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _kpiRow(AppThemeData t, int hoy, int kb, int ms) {
    final kpis = [
      (
        label: 'Ingestados hoy',
        value: '$hoy docs',
        icon: Icons.today_outlined,
        color: t.success
      ),
      (
        label: 'Tamaño total corpus',
        value: '${(kb / 1024).toStringAsFixed(1)} MB',
        icon: Icons.storage_outlined,
        color: t.info
      ),
      (
        label: 'Tiempo prom. OCR',
        value: '${(ms / 1000).toStringAsFixed(2)} s',
        icon: Icons.timer_outlined,
        color: t.indigo
      ),
      (
        label: 'Total en catálogo',
        value: '${MetaDocsMockData.documentos.length}',
        icon: Icons.library_books_outlined,
        color: t.primary
      ),
    ];
    return Row(
      children: kpis.map((k) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: kpis.last.label == k.label ? 0 : 12),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(t),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: k.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(k.icon, color: k.color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(k.value, style: AppTheme.h3(t).copyWith(fontSize: 17)),
                    Text(k.label, style: AppTheme.caption(t)),
                  ],
                ),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _dropArea(AppThemeData t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.cloud_upload_outlined, size: 18, color: t.primary),
          const SizedBox(width: 8),
          Text('Zona de Carga', style: AppTheme.h3(t)),
        ]),
        const SizedBox(height: 16),
        MouseRegion(
          onEnter: (_) => setState(() => _dragOver = true),
          onExit: (_) => setState(() => _dragOver = false),
          child: GestureDetector(
            onTap: () => _showSnack('Explorador de archivos abierto (demo)'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 180,
              decoration: BoxDecoration(
                color: _dragOver ? t.primary.withOpacity(0.08) : t.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _dragOver ? t.primary : t.border,
                  width: _dragOver ? 2 : 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 40,
                      color: _dragOver ? t.primary : t.textDisabled,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Arrastra archivos aquí',
                      style: AppTheme.body(t).copyWith(
                        color: _dragOver ? t.primary : t.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF, XML, DOCX, JPG · Máx. 50 MB por archivo',
                      style: AppTheme.caption(t),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showSnack('Seleccionar archivos (demo)'),
                      icon: const Icon(Icons.folder_open_outlined, size: 16),
                      label: const Text('Seleccionar archivos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: t.primary,
                        side: BorderSide(color: t.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _sourceBtn(Icons.email_outlined, 'Email IMAP', t),
          const SizedBox(width: 8),
          _sourceBtn(Icons.api_outlined, 'API REST', t),
          const SizedBox(width: 8),
          _sourceBtn(Icons.scanner_outlined, 'Escáner', t),
        ]),
      ]),
    );
  }

  Widget _sourceBtn(IconData icon, String label, AppThemeData t) {
    return OutlinedButton.icon(
      onPressed: () => _showSnack('Conectando vía $label…'),
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: t.textSecondary,
        side: BorderSide(color: t.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTheme.bodySmall(t),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _reglasPanel(AppThemeData t) {
    final reglas = [
      (label: 'Auto-clasificación por tipo', activa: true),
      (label: 'Extracción OCR automática', activa: true),
      (label: 'Detección de duplicados', activa: true),
      (label: 'Notificación por email', activa: false),
      (label: 'Clasificación por RFC emisor', activa: true),
      (label: 'Umbral mínimo confianza 70 %', activa: true),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.rule_outlined, size: 18, color: t.indigo),
          const SizedBox(width: 8),
          Text('Reglas de Ingesta', style: AppTheme.h3(t)),
        ]),
        const SizedBox(height: 14),
        ...reglas.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Icon(
                  r.activa ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 16,
                  color: r.activa ? t.success : t.neutral,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(r.label, style: AppTheme.body(t))),
                Switch(
                  value: r.activa,
                  onChanged: (_) => _showSnack('Regla actualizada (demo)'),
                  activeColor: t.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ]),
            )),
      ]),
    );
  }

  Widget _colaPanel(AppThemeData t, List docs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.queue_outlined, size: 18, color: t.warning),
          const SizedBox(width: 8),
          Text('Cola de Ingesta Reciente', style: AppTheme.h3(t)),
          const Spacer(),
          Text('Últimos ${docs.length}', style: AppTheme.caption(t)),
        ]),
        const SizedBox(height: 14),
        ...docs.map((doc) {
          final color = _estatusColor(doc.estatus, t);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(doc.nombre,
                    style: AppTheme.bodySmall(t).copyWith(color: t.textPrimary),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Text(doc.estatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                    )),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _origenesPanel(AppThemeData t) {
    final origenData = [
      (nombre: 'Email IMAP', tipo: 'email', estatus: 'revision', docs: 18),
      (nombre: 'API REST', tipo: 'api', estatus: 'activa', docs: 12),
      (nombre: 'Carga Manual', tipo: 'manual', estatus: 'activa', docs: 22),
      (nombre: 'Escáner MFP', tipo: 'escaner', estatus: 'activa', docs: 11),
      (
        nombre: 'Integración ERP',
        tipo: 'integracion',
        estatus: 'activa',
        docs: 7
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.hub_outlined, size: 18, color: t.success),
          const SizedBox(width: 8),
          Text('Fuentes Activas', style: AppTheme.h3(t)),
        ]),
        const SizedBox(height: 14),
        ...origenData.map((o) {
          final color = o.estatus == 'activa' ? t.success : t.warning;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.cloud_done_outlined, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.nombre, style: AppTheme.body(t)),
                    Text('${o.docs} documentos', style: AppTheme.caption(t)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Text(o.estatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                    )),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Color _estatusColor(String estatus, AppThemeData t) => switch (estatus) {
        'revisado' => t.success,
        'extraido' => t.info,
        'pendiente' => t.warning,
        'procesando' => t.indigo,
        'rechazado' => t.error,
        'archivado' => t.neutral,
        _ => t.neutral,
      };
}
