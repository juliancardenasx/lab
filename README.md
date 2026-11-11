# Networkianos Lab

Web de materiales de investigación de Networkianos: <https://lab.networkianos.com>

Hecha con [Quarto](https://quarto.org). Cada vez que se sube un cambio a la rama `main`, GitHub Actions genera la web y la publica en GitHub Pages.

## Cómo añadir contenido

1. Copia la plantilla de `_plantillas/` que corresponda (preprint, artículo, datos, skill o vídeo).
2. Guárdala en su carpeta (`preprints/`, `articulos/`, `datos/`, `skills/`, `videos/`) con un nombre corto, sin espacios ni tildes.
3. Rellena los campos y sube el cambio (Commit + Push en GitHub Desktop).

La portada muestra automáticamente las seis novedades más recientes.

## Estructura

- `_quarto.yml`: configuración y menú.
- `theme.scss`: colores y tipografía (los de networkianos.com).
- `_listing/fichas.ejs`: diseño de las fichas de los listados.
- `CNAME`: dominio `lab.networkianos.com`.
