import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/models/models.dart';
import 'package:metadocs/theme/theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ExploradorPage extends StatefulWidget {
  const ExploradorPage({super.key});

  @override
  State<ExploradorPage> createState() => _ExploradorPageState();
}

class _ExploradorPageState extends State<ExploradorPage> {
  PlutoGridStateManager? _sm;
  String _filterTipo = 'Todos';
  String _filterFormato = 'Todos';
  String _groupBy = 'Ninguno';

  final _tipos = [
    'Todos',
    'Contrato',
    'Factura',
    'Expediente Clínico',
    'Oficio',
    'Acta Constitutiva',
    'Informe Técnico',
    'Solicitud',
    'Dictamen'
  ];
  final _groupOpts = ['Ninguno', 'Tipo documental', 'Mes de ingesta', 'Origen'];

  List<Documento> get _filtered => MetaDocsMockData.documentos
      .where((d) => d.estatus == 'revisado' || d.estatus == 'extraido')
      .where((d) => _filterTipo == 'Todos' || d.tipoDocumental == _filterTipo)
      .where((d) =>
          _filterFormato == 'Todos' ||
          d.nombre.toLowerCase().endsWith('.${_filterFormato.toLowerCase()}'))
      .toList();

  List<PlutoColumn> _cols(AppThemeData t) => [
        PlutoColumn(
          title: 'Documento',
          field: 'nombre',
          type: PlutoColumnType.text(),
          width: 240,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final nombre = ctx.cell.value as String;
            return Row(children: [
              _formatIcon(nombre),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(nombre,
                      style: AppTheme.tableData(t),
                      overflow: TextOverflow.ellipsis)),
            ]);
          },
        ),
        PlutoColumn(
          title: 'Tipo',
          field: 'tipo',
          type: PlutoColumnType.text(),
          width: 130,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) =>
              Text(ctx.cell.value as String, style: AppTheme.tableData(t)),
        ),
        PlutoColumn(
          title: 'Campo extraído',
          field: 'campo',
          type: PlutoColumnType.text(),
          width: 160,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t)
                  .copyWith(color: t.info, fontWeight: FontWeight.w500)),
        ),
        PlutoColumn(
          title: 'Valor',
          field: 'valor',
          type: PlutoColumnType.text(),
          width: 200,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t), overflow: TextOverflow.ellipsis),
        ),
        PlutoColumn(
          title: 'Confianza',
          field: 'confianza',
          type: PlutoColumnType.number(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final val = (ctx.cell.value as num).toDouble();
            final color = val >= 0.9
                ? t.success
                : val >= 0.7
                    ? t.warning
                    : t.error;
            return Text('${(val * 100).toStringAsFixed(0)} %',
                style: AppTheme.tableData(t)
                    .copyWith(color: color, fontWeight: FontWeight.w600));
          },
        ),
        PlutoColumn(
          title: 'Tipo de campo',
          field: 'tipoCampo',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final tipo = ctx.cell.value as String;
            final color = _tipoCampoColor(tipo, t);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Text(tipo.toUpperCase(),
                  style: TextStyle(
                      color: color, fontSize: 9, fontWeight: FontWeight.w700)),
            );
          },
        ),
        PlutoColumn(
          title: 'Origen doc.',
          field: 'origen',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) =>
              Text(ctx.cell.value as String, style: AppTheme.tableData(t)),
        ),
        PlutoColumn(
          title: 'Fecha ingesta',
          field: 'fecha',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) =>
              Text(ctx.cell.value as String, style: AppTheme.tableData(t)),
        ),
      ];

  List<PlutoRow> _rows(AppThemeData t) {
    final rows = <PlutoRow>[];
    for (final doc in _filtered) {
      if (doc.metadatos.isEmpty) continue;
      final tipo = MetaDocsMockData.tiposDocumentales
          .where((td) => td.nombre == doc.tipoDocumental)
          .firstOrNull;
      final campos = tipo?.campos ?? [];

      for (final entry in doc.metadatos.entries) {
        final campoMeta = campos
            .where((c) =>
                c.nombre.toLowerCase() ==
                entry.key.replaceAll('_', ' ').toLowerCase())
            .firstOrNull;
        final tipoCampo = campoMeta?.tipo ?? 'texto';
        final fecha =
            '${doc.fechaIngesta.day.toString().padLeft(2, '0')}/${doc.fechaIngesta.month.toString().padLeft(2, '0')}/${doc.fechaIngesta.year}';
        rows.add(PlutoRow(cells: {
          'nombre': PlutoCell(value: doc.nombre),
          'tipo': PlutoCell(value: doc.tipoDocumental),
          'campo': PlutoCell(value: entry.key),
          'valor': PlutoCell(value: entry.value),
          'confianza': PlutoCell(value: doc.confianzaIA),
          'tipoCampo': PlutoCell(value: tipoCampo),
          'origen': PlutoCell(value: doc.origen),
          'fecha': PlutoCell(value: fecha),
        }));
      }
    }
    return rows;
  }

  Color _tipoCampoColor(String tipo, AppThemeData t) => switch (tipo) {
        'texto' => t.textSecondary,
        'fecha' => t.info,
        'monto' => t.success,
        'rfc' => t.warning,
        'entidad' => t.indigo,
        _ => t.neutral,
      };

  PlutoGridConfiguration _config(AppThemeData t) => PlutoGridConfiguration(
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

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final rows = _rows(t);

    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explorador de Metadatos', style: AppTheme.h1(t)),
                const SizedBox(height: 4),
                Text(
                    '${rows.length} campos extraídos de ${_filtered.length} documentos',
                    style: AppTheme.bodySmall(t)),
              ],
            )),
            OutlinedButton.icon(
              onPressed: () => _showSnack('Exportando metadatos a CSV…'),
              icon: Icon(Icons.download_outlined, size: 16, color: t.primary),
              label: Text('Exportar CSV',
                  style: AppTheme.button(t).copyWith(color: t.primary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: t.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Filters
          Wrap(spacing: 12, runSpacing: 10, children: [
            _ddBtn('Tipo documental', _filterTipo, _tipos, t,
                (v) => setState(() => _filterTipo = v!)),
            _ddBtn('Agrupar por', _groupBy, _groupOpts, t,
                (v) => setState(() => _groupBy = v!)),
            if (_filterTipo != 'Todos')
              TextButton.icon(
                onPressed: () => setState(() {
                  _filterTipo = 'Todos';
                  _filterFormato = 'Todos';
                }),
                icon: const Icon(Icons.clear, size: 13),
                label: const Text('Limpiar filtros'),
              ),
          ]),
          const SizedBox(height: 10),

          // Format quick-filter
          Row(children: [
            Text('Formato:',
                style: AppTheme.caption(t).copyWith(color: t.textSecondary)),
            const SizedBox(width: 10),
            _fmtChip('Todos', Icons.folder_outlined, t.neutral, t),
            const SizedBox(width: 6),
            _fmtChip('PDF', Icons.picture_as_pdf_outlined,
                const Color(0xFFDC2626), t),
            const SizedBox(width: 6),
            _fmtChip('XML', Icons.code_outlined, const Color(0xFF0284C7), t),
          ]),
          const SizedBox(height: 14),

          // Legend
          Wrap(spacing: 10, children: [
            _tipoPill('texto', t),
            _tipoPill('fecha', t),
            _tipoPill('monto', t),
            _tipoPill('rfc', t),
            _tipoPill('entidad', t),
          ]),
          const SizedBox(height: 12),

          // Grid / Cards
          Expanded(
            child: MediaQuery.sizeOf(context).width < mobileSize
                ? _buildMobileCards(t)
                : Container(
                    decoration: AppTheme.tableDecoration(t),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: PlutoGrid(
                        columns: _cols(t),
                        rows: rows,
                        onLoaded: (e) => _sm = e.stateManager,
                        configuration: _config(t),
                        createFooter: (sm) {
                          sm.setPageSize(25, notify: false);
                          return PlutoPagination(sm);
                        },
                      ),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMobileCards(AppThemeData t) {
    if (_filtered.isEmpty) {
      return Center(child: Text('Sin registros', style: AppTheme.body(t)));
    }
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final doc = _filtered[i];
        final fecha =
            '${doc.fechaIngesta.day.toString().padLeft(2, '0')}/${doc.fechaIngesta.month.toString().padLeft(2, '0')}/${doc.fechaIngesta.year}';
        final campos = doc.metadatos.entries.toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(doc.nombre,
                        style: AppTheme.body(t)
                            .copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.info.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: t.info.withOpacity(0.35)),
                    ),
                    child: Text(doc.tipoDocumental,
                        style: TextStyle(
                            color: t.info,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text('${campos.length} campos extraídos · $fecha',
                    style:
                        AppTheme.caption(t).copyWith(color: t.textSecondary)),
                const SizedBox(height: 8),
                ...campos.take(4).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(children: [
                        SizedBox(
                          width: 110,
                          child: Text(e.key,
                              style: AppTheme.caption(t).copyWith(
                                  color: t.info, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: Text(e.value.toString(),
                              style: AppTheme.caption(t),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    )),
                if (campos.length > 4)
                  Text('+ ${campos.length - 4} campos más',
                      style:
                          AppTheme.caption(t).copyWith(color: t.textDisabled)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ddBtn(String label, String value, List<String> items, AppThemeData t,
      void Function(String?) onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: t.surface,
          style: AppTheme.body(t),
          icon: Icon(Icons.expand_more, size: 16, color: t.textDisabled),
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: AppTheme.body(t)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _tipoPill(String tipo, AppThemeData t) {
    final color = _tipoCampoColor(tipo, t);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(tipo.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  /// Returns a colored icon for a given document filename extension.
  Widget _formatIcon(String nombre) {
    final ext =
        nombre.contains('.') ? nombre.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf,
            size: 16, color: Color(0xFFDC2626));
      case 'xml':
        return const Icon(Icons.code, size: 16, color: Color(0xFF0284C7));
      default:
        return const Icon(Icons.insert_drive_file_outlined,
            size: 16, color: Color(0xFF64748B));
    }
  }

  /// Quick-filter chip for document format.
  Widget _fmtChip(String fmt, IconData icon, Color color, AppThemeData t) {
    final isSelected = _filterFormato == fmt;
    return GestureDetector(
      onTap: () => setState(() => _filterFormato = fmt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.14) : t.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? color.withOpacity(0.6) : t.border,
              width: isSelected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: isSelected ? color : t.textSecondary),
          const SizedBox(width: 5),
          Text(fmt,
              style: TextStyle(
                  color: isSelected ? color : t.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }
}
