import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/models/models.dart';
import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/theme/theme.dart';

class EsquemasPage extends StatefulWidget {
  const EsquemasPage({super.key});

  @override
  State<EsquemasPage> createState() => _EsquemasPageState();
}

class _EsquemasPageState extends State<EsquemasPage> {
  TipoDocumental? _selected;

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  Color _tipoCampoColor(String tipo, AppThemeData t) => switch (tipo) {
        'texto' => t.info,
        'fecha' => t.indigo,
        'monto' => t.success,
        'rfc' => t.warning,
        'entidad' => t.primary,
        _ => t.neutral,
      };

  IconData _tipoCampoIcon(String tipo) => switch (tipo) {
        'texto' => Icons.text_fields,
        'fecha' => Icons.calendar_today_outlined,
        'monto' => Icons.attach_money,
        'rfc' => Icons.badge_outlined,
        'entidad' => Icons.account_tree_outlined,
        _ => Icons.data_object_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final tipos = MetaDocsMockData.tiposDocumentales;
    final sel = _selected ?? tipos.first;

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
                  Text('Esquemas y Taxonomía', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text(
                      '${tipos.length} tipos documentales · ${tipos.fold(0, (s, td) => s + td.campos.length)} campos definidos',
                      style: AppTheme.bodySmall(t)),
                ],
              )),
              OutlinedButton.icon(
                onPressed: () => _showSnack('Nuevo tipo documental (demo)'),
                icon: Icon(Icons.add, size: 15, color: t.primary),
                label: Text('Nuevo tipo',
                    style: AppTheme.button(t).copyWith(color: t.primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: t.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            Expanded(
              child: LayoutBuilder(builder: (_, box) {
                final mob = box.maxWidth < mobileSize;
                // Sidebar de tipos
                final sidebar = Container(
                  decoration: AppTheme.cardDecoration(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child:
                            Text('Tipos documentales', style: AppTheme.h3(t)),
                      ),
                      Divider(color: t.border, height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tipos.length,
                          itemBuilder: (_, i) {
                            final td = tipos[i];
                            final isSelected = sel.id == td.id;
                            return InkWell(
                              onTap: () => setState(() => _selected = td),
                              child: Container(
                                color: isSelected
                                    ? t.primary.withOpacity(0.10)
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? t.primary.withOpacity(0.15)
                                          : t.border.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.description_outlined,
                                        color: isSelected
                                            ? t.primary
                                            : t.textSecondary,
                                        size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(td.nombre,
                                          style: AppTheme.body(t).copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? t.primary
                                                : t.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis),
                                      Text('${td.campos.length} campos',
                                          style: AppTheme.caption(t)),
                                    ],
                                  )),
                                  if (isSelected)
                                    Icon(Icons.chevron_right,
                                        size: 16, color: t.primary),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
                final detail = Container(
                  decoration: AppTheme.cardDecoration(t),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado del tipo
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(sel.nombre, style: AppTheme.h2(t)),
                              ),
                              FilledButton.icon(
                                onPressed: () => _showSnack(
                                    'Agregar campo a: ${sel.nombre}'),
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('Agregar campo'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: t.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  textStyle: AppTheme.bodySmall(t),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Text(sel.descripcion,
                                style: AppTheme.body(t)
                                    .copyWith(color: t.textSecondary)),
                            const SizedBox(height: 10),
                            Row(children: [
                              _badge(
                                  '${sel.campos.length} campos', t.primary, t),
                              const SizedBox(width: 8),
                              _badge(
                                '${sel.campos.where((c) => c.obligatorio).length} obligatorios',
                                t.error,
                                t,
                              ),
                              const SizedBox(width: 8),
                              _badge(
                                '${sel.campos.where((c) => !c.obligatorio).length} opcionales',
                                t.neutral,
                                t,
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Divider(color: t.border, height: 1),

                      // Tabla de campos
                      // Header
                      Container(
                        color: t.isDark
                            ? const Color(0xFF0D1628)
                            : const Color(0xFFF1F5FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(children: [
                          Expanded(
                              child: Text('Campo',
                                  style: AppTheme.tableHeader(t))),
                          SizedBox(
                              width: 100,
                              child:
                                  Text('Tipo', style: AppTheme.tableHeader(t))),
                          SizedBox(
                              width: 80,
                              child: Text('Obligatorio',
                                  style: AppTheme.tableHeader(t))),
                          SizedBox(
                              width: 80,
                              child: Text('Acciones',
                                  style: AppTheme.tableHeader(t))),
                        ]),
                      ),
                      Divider(color: t.border, height: 1),

                      // Campos
                      Expanded(
                        child: ListView.separated(
                          itemCount: sel.campos.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: t.border, height: 1),
                          itemBuilder: (_, i) {
                            final campo = sel.campos[i];
                            final tipoColor = _tipoCampoColor(campo.tipo, t);
                            final isOdd = i.isOdd;
                            return Container(
                              color: isOdd
                                  ? (t.isDark
                                      ? const Color(0xFF0D1628)
                                      : const Color(0xFFF8FAFC))
                                  : t.surface,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Row(children: [
                                Expanded(
                                  child: Row(children: [
                                    Icon(_tipoCampoIcon(campo.tipo),
                                        size: 15, color: tipoColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(campo.nombre,
                                            style: AppTheme.tableData(t)
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w500),
                                            overflow: TextOverflow.ellipsis)),
                                  ]),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: tipoColor.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: tipoColor.withOpacity(0.3)),
                                    ),
                                    child: Text(campo.tipo,
                                        style: TextStyle(
                                            color: tipoColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: campo.obligatorio
                                      ? Row(children: [
                                          Icon(Icons.check_circle_outline,
                                              size: 14, color: t.error),
                                          const SizedBox(width: 4),
                                          Text('Sí',
                                              style: AppTheme.tableData(t)
                                                  .copyWith(color: t.error)),
                                        ])
                                      : Text('No',
                                          style: AppTheme.tableData(t).copyWith(
                                              color: t.textSecondary)),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _iconBtn(
                                            Icons.edit_outlined,
                                            t.info,
                                            () => _showSnack(
                                                'Editar campo: ${campo.nombre}')),
                                        const SizedBox(width: 4),
                                        _iconBtn(
                                            Icons.delete_outline,
                                            t.error,
                                            () => _showSnack(
                                                'Eliminar campo: ${campo.nombre}')),
                                      ]),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );

                if (mob) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 220, child: sidebar),
                      const SizedBox(height: 12),
                      Expanded(child: detail),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: sidebar),
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

  Widget _badge(String label, Color color, AppThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
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
