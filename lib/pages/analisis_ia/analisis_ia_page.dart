import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/models/models.dart';
import 'package:metadocs/theme/theme.dart';

class AnalisisIaPage extends StatefulWidget {
  const AnalisisIaPage({super.key});

  @override
  State<AnalisisIaPage> createState() => _AnalisisIaPageState();
}

class _AnalisisIaPageState extends State<AnalisisIaPage> {
  int _selectedIdx = 0;
  bool _loading = false;

  Documento get _selected => MetaDocsMockData.documentos[_selectedIdx];

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  Future<void> _simulate(String accion) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _loading = false);
      _showSnack('$accion completado para: ${_selected.nombre}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < mobileSize;
    final doc = _selected;
    final resultados = MetaDocsMockData.resultados;
    final resultado =
        resultados.where((r) => r.documentoId == doc.id).firstOrNull;

    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Análisis con IA', style: AppTheme.h1(t)),
            const SizedBox(height: 4),
            Text(
                'Motor: Gemini Vision · ${MetaDocsMockData.documentos.length} documentos en corpus',
                style: AppTheme.bodySmall(t)),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(builder: (_, box) {
                final mob = box.maxWidth < mobileSize;

                // -- Sidebar: lista de documentos --
                final sidebar = Container(
                  decoration: AppTheme.cardDecoration(t),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Icon(Icons.library_books_outlined,
                            size: 16, color: t.primary),
                        const SizedBox(width: 8),
                        Text('Documentos', style: AppTheme.h3(t)),
                      ]),
                    ),
                    Divider(color: t.border, height: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: MetaDocsMockData.documentos.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: t.border, height: 1),
                        itemBuilder: (_, i) {
                          final d = MetaDocsMockData.documentos[i];
                          final isSelected = i == _selectedIdx;
                          final color = _estatusColor(d.estatus, t);
                          return InkWell(
                            onTap: () => setState(() {
                              _selectedIdx = i;
                              _loading = false;
                            }),
                            child: Container(
                              color: isSelected
                                  ? t.primary.withOpacity(0.10)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(d.nombre,
                                            style: AppTheme.bodySmall(t)
                                                .copyWith(
                                                    color: isSelected
                                                        ? t.primary
                                                        : t.textPrimary,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400),
                                            overflow: TextOverflow.ellipsis),
                                        Text(d.tipoDocumental,
                                            style: AppTheme.caption(t)),
                                      ]),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                );

                // -- Panel de análisis --
                final detail = _loading
                    ? Container(
                        decoration: AppTheme.cardDecoration(t),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: t.primary),
                              const SizedBox(height: 16),
                              Text('Procesando con IA…',
                                  style: AppTheme.body(t)),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Doc header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: AppTheme.cardDecoration(t),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(doc.nombre,
                                              style: AppTheme.h2(t),
                                              overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Text(
                                              '${doc.tipoDocumental} · ${doc.paginas} págs. · ${(doc.tamanoKb / 1024).toStringAsFixed(1)} MB',
                                              style: AppTheme.bodySmall(t)),
                                        ],
                                      ),
                                    ),
                                    _estatusBadge(doc.estatus, t),
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Text('Confianza IA: ',
                                        style: AppTheme.body(t)),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: doc.confianzaIA,
                                          backgroundColor: t.border,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  doc.confianzaIA >= 0.9
                                                      ? t.success
                                                      : doc.confianzaIA >= 0.7
                                                          ? t.warning
                                                          : t.error),
                                          minHeight: 7,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        '${(doc.confianzaIA * 100).toStringAsFixed(0)} %',
                                        style: AppTheme.body(t).copyWith(
                                            fontWeight: FontWeight.w600)),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // IA Actions
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: AppTheme.cardDecoration(t),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.psychology_outlined,
                                        size: 18, color: t.indigo),
                                    const SizedBox(width: 8),
                                    Text('Acciones de IA',
                                        style: AppTheme.h3(t)),
                                  ]),
                                  const SizedBox(height: 16),
                                  Wrap(spacing: 10, runSpacing: 10, children: [
                                    _iaBtn(
                                        Icons.summarize_outlined,
                                        'Resumir documento',
                                        t.primary,
                                        t,
                                        () => _simulate('Resumen IA')),
                                    _iaBtn(
                                        Icons.data_object_outlined,
                                        'Extraer datos',
                                        t.success,
                                        t,
                                        () => _simulate('Extracción de datos')),
                                    _iaBtn(
                                        Icons.security_outlined,
                                        'Detectar riesgos',
                                        t.error,
                                        t,
                                        () => _simulate('Análisis de riesgo')),
                                    _iaBtn(
                                        Icons.compare_arrows_outlined,
                                        'Comparar versiones',
                                        t.warning,
                                        t,
                                        () => _simulate('Comparación')),
                                    _iaBtn(
                                        Icons.category_outlined,
                                        'Re-clasificar',
                                        t.indigo,
                                        t,
                                        () => _simulate('Re-clasificación')),
                                    _iaBtn(
                                        Icons.translate_outlined,
                                        'Traducir',
                                        t.info,
                                        t,
                                        () => _simulate('Traducción')),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Metadata extraction results
                            if (doc.metadatos.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: AppTheme.cardDecoration(t),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Icon(Icons.fact_check_outlined,
                                          size: 18, color: t.success),
                                      const SizedBox(width: 8),
                                      Text('Campos extraídos',
                                          style: AppTheme.h3(t)),
                                      const Spacer(),
                                      Text('${doc.metadatos.length} campos',
                                          style: AppTheme.caption(t)),
                                    ]),
                                    const SizedBox(height: 14),
                                    ...doc.metadatos.entries.take(8).map((e) =>
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(children: [
                                            SizedBox(
                                              width: 160,
                                              child: Text(e.key,
                                                  style: AppTheme.bodySmall(t)
                                                      .copyWith(
                                                          color:
                                                              t.textSecondary)),
                                            ),
                                            Expanded(
                                              child: Text(e.value,
                                                  style: AppTheme.body(t)
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          ]),
                                        )),
                                    if (doc.metadatos.length > 8)
                                      Text(
                                          '+ ${doc.metadatos.length - 8} campos más…',
                                          style: AppTheme.caption(t)
                                              .copyWith(color: t.primary)),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 12),

                            // Etiquetas
                            if (doc.etiquetas.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: AppTheme.cardDecoration(t),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.label_outline,
                                            size: 18, color: t.info),
                                        const SizedBox(width: 8),
                                        Text('Entidades detectadas',
                                            style: AppTheme.h3(t)),
                                      ]),
                                      const SizedBox(height: 14),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: doc.etiquetas
                                            .map((e) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: t.primary
                                                        .withOpacity(0.10),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                        color: t.primary
                                                            .withOpacity(0.3)),
                                                  ),
                                                  child: Text(e,
                                                      style: AppTheme.bodySmall(
                                                              t)
                                                          .copyWith(
                                                              color: t.primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                ))
                                            .toList(),
                                      ),
                                    ]),
                              ),

                            // Resultado procesamiento
                            if (resultado != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: AppTheme.cardDecoration(t),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Icon(Icons.analytics_outlined,
                                          size: 18, color: t.indigo),
                                      const SizedBox(width: 8),
                                      Text('Resultado de procesamiento',
                                          style: AppTheme.h3(t)),
                                    ]),
                                    const SizedBox(height: 14),
                                    _metaRow(
                                        'Motor OCR', resultado.motorOCR, t),
                                    _metaRow('Tiempo',
                                        '${resultado.tiempoMs} ms', t),
                                    _metaRow('Campos extraídos',
                                        '${resultado.camposExtraidos}', t),
                                    _metaRow('Estatus', resultado.estatus, t),
                                    if (resultado.errores.isNotEmpty)
                                      _metaRow('Errores',
                                          resultado.errores.join(', '), t),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      );

                // -- Layout --
                if (mob) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 200, child: sidebar),
                      const SizedBox(height: 12),
                      Expanded(child: detail),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 280, child: sidebar),
                    const SizedBox(width: 16),
                    Expanded(child: detail),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iaBtn(IconData icon, String label, Color color, AppThemeData t,
      VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: AppTheme.bodySmall(t),
      ),
    );
  }

  Widget _metaRow(String label, String value, AppThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: AppTheme.bodySmall(t).copyWith(color: t.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: AppTheme.body(t).copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
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

  Widget _estatusBadge(String estatus, AppThemeData t) {
    final c = _estatusColor(estatus, t);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(estatus.toUpperCase(),
          style: TextStyle(
              color: c,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3)),
    );
  }
}
