import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/models/models.dart';
import 'package:metadocs/theme/theme.dart';

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key});

  @override
  State<ConsultasPage> createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  final _queryCtrl = TextEditingController();
  bool _searching = false;
  List<Documento> _results = [];
  String _searchedQuery = '';

  static const _sugerencias = [
    'Contratos vigentes firmados en 2026',
    'Facturas con monto mayor a 50,000',
    'Documentos rechazados del mes de enero',
    'Expedientes clínicos de confianza alta',
    'Informes técnicos pendientes de revisión',
    'Solicitudes con campo RFC extraído',
    'Documentos de origen email sin revisar',
    'Actas constitutivas archivadas',
  ];

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _searching = true;
      _searchedQuery = query;
      _results = [];
    });
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 700));
    final q = query.toLowerCase();
    final docs = MetaDocsMockData.documentos.where((d) {
      return d.nombre.toLowerCase().contains(q) ||
          d.tipoDocumental.toLowerCase().contains(q) ||
          d.estatus.toLowerCase().contains(q) ||
          d.etiquetas.any((e) => e.toLowerCase().contains(q)) ||
          d.origen.toLowerCase().contains(q);
    }).toList();
    if (mounted) {
      setState(() {
        _results = docs;
        _searching = false;
      });
    }
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Consultas Inteligentes', style: AppTheme.h1(t)),
            const SizedBox(height: 4),
            Text('Busca documentos con lenguaje natural sobre el corpus documental',
                style: AppTheme.bodySmall(t)),
            const SizedBox(height: 24),

            // Search bar
            Container(
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.primary.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: t.primary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(children: [
                const SizedBox(width: 16),
                Icon(Icons.search, color: t.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    style: AppTheme.body(t).copyWith(fontSize: 15),
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      hintText: 'Ej: contratos vigentes con RFC extraído…',
                      hintStyle: AppTheme.body(t).copyWith(color: t.textDisabled),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: FilledButton(
                    onPressed: () => _search(_queryCtrl.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Buscar'),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Sugerencias
            if (_results.isEmpty && !_searching) ...[
              Text('Consultas sugeridas', style: AppTheme.h3(t)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _sugerencias.map((s) {
                return ActionChip(
                  label: Text(s, style: AppTheme.bodySmall(t).copyWith(color: t.textSecondary)),
                  onPressed: () {
                    _queryCtrl.text = s;
                    _search(s);
                  },
                  backgroundColor: t.surface,
                  side: BorderSide(color: t.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  avatar: Icon(Icons.auto_awesome_outlined, size: 14, color: t.primary),
                );
              }).toList()),
              const SizedBox(height: 24),

              // Stats row
              Row(children: [
                _statCard('Total documentos', '${MetaDocsMockData.documentos.length}', Icons.folder_copy_outlined, t.primary, t),
                const SizedBox(width: 10),
                _statCard('Extraídos', '${MetaDocsMockData.documentos.where((d) => d.estatus == "extraido" || d.estatus == "revisado").length}', Icons.check_circle_outline, t.success, t),
                const SizedBox(width: 10),
                _statCard('Tipos documentales', '${MetaDocsMockData.tiposDocumentales.length}', Icons.category_outlined, t.info, t),
                const SizedBox(width: 10),
                _statCard('Campos indexados', '${MetaDocsMockData.resultados.fold(0, (s, r) => s + r.camposExtraidos)}', Icons.data_object_outlined, t.indigo, t),
              ]),
            ],

            // Loading
            if (_searching) ...[
              const SizedBox(height: 32),
              Center(child: Column(children: [
                CircularProgressIndicator(color: t.primary),
                const SizedBox(height: 14),
                Text('Consultando corpus documental…',
                    style: AppTheme.body(t).copyWith(color: t.textSecondary)),
              ])),
            ],

            // Results
            if (!_searching && _results.isNotEmpty) ...[
              Row(children: [
                Icon(Icons.search, size: 16, color: t.primary),
                const SizedBox(width: 6),
                Text('"$_searchedQuery"',
                    style: AppTheme.h3(t).copyWith(color: t.primary)),
                const SizedBox(width: 8),
                Text('— ${_results.length} resultado(s)',
                    style: AppTheme.bodySmall(t).copyWith(color: t.textSecondary)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() { _results = []; _queryCtrl.clear(); }),
                  icon: Icon(Icons.close, size: 14, color: t.textSecondary),
                  label: Text('Limpiar', style: AppTheme.bodySmall(t).copyWith(color: t.textSecondary)),
                ),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final doc = _results[i];
                    final conf = (doc.confianzaIA * 100).toStringAsFixed(0);
                    final confColor = doc.confianzaIA >= 0.8 ? t.success
                        : doc.confianzaIA >= 0.6 ? t.warning : t.error;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.border),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: t.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.description_outlined, color: t.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.nombre,
                                style: AppTheme.body(t).copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Row(children: [
                              Text('${doc.tipoDocumental} · ${doc.origen}',
                                  style: AppTheme.caption(t)),
                              const SizedBox(width: 8),
                              if (doc.etiquetas.isNotEmpty)
                                ...doc.etiquetas.take(2).map((e) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: t.primarySoft,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(e, style: TextStyle(color: t.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                                  ),
                                )),
                            ]),
                          ],
                        )),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$conf %',
                                style: TextStyle(color: confColor, fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('confianza IA', style: AppTheme.caption(t)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        _estatusBadge(doc.estatus, t),
                      ]),
                    );
                  },
                ),
              ),
            ],

            // Empty state after search
            if (!_searching && _results.isEmpty && _searchedQuery.isNotEmpty) ...[
              const SizedBox(height: 40),
              Center(child: Column(children: [
                Icon(Icons.search_off_outlined, size: 48, color: t.textDisabled),
                const SizedBox(height: 12),
                Text('No se encontraron documentos para "$_searchedQuery"',
                    style: AppTheme.body(t).copyWith(color: t.textSecondary)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() { _searchedQuery = ''; _queryCtrl.clear(); }),
                  child: Text('Borrar búsqueda', style: AppTheme.body(t).copyWith(color: t.primary)),
                ),
              ])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _estatusBadge(String estatus, AppThemeData t) {
    final color = switch (estatus) {
      'revisado' => t.success,
      'extraido' => t.info,
      'procesando' => t.warning,
      'rechazado' => t.error,
      'archivado' => t.neutral,
      _ => t.neutral,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(estatus,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, AppThemeData t) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(t),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTheme.h3(t).copyWith(fontSize: 15)),
              Text(label, style: AppTheme.caption(t)),
            ],
          )),
        ]),
      ),
    );
  }
}