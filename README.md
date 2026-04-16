# MetaDocs — AI Document Intelligence Demo

Demo de sistema de gestión documental con inteligencia artificial, desarrollado con Flutter Web.

Creado por [Adrinc]


## Tecnologías

- Flutter Web
- Provider (state management)
- GoRouter (navegación)
- PlutoGrid (tablas administrativas)
- fl_chart (gráficas)

## Desarrollo local

```bash
flutter pub get
flutter run -d chrome
```

## Build de producción

```bash
flutter build web --release --no-tree-shake-icons --base-href /metadocs/
```

El output queda en `build/web/` y se copia a `docs/` para el deploy en GitHub Pages.
