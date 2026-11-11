# Networkianos Lab

Web de materiales de investigación de Networkianos: <https://lab.networkianos.com> (español) y <https://lab.networkianos.com/en/> (inglés).

Hecha con [Quarto](https://quarto.org). Cada vez que se sube un cambio a la rama `main`, GitHub Actions genera la web y la publica en GitHub Pages.

## Cómo añadir contenido

1. Copia la plantilla de `_plantillas/` que corresponda (publicación, datos, skill, plugin o vídeo).
2. Guárdala en su carpeta (`publicaciones/`, `datos/`, `skills/`, `plugins/`, `videos/`) con un nombre corto, sin espacios ni tildes.
3. Rellena los campos y sube el cambio (Commit + Push en GitHub Desktop, o edita desde github.com con el lápiz).

La portada muestra automáticamente las seis novedades más recientes.

## Versión en inglés

La carpeta `en/` replica la web en inglés (`en/publications/`, `en/data/`, `en/skills/`, `en/plugins/`, `en/videos/`, `en/about.qmd`). Cada ficha tiene un campo `alt:` con la dirección de su versión en el otro idioma; el selector ES/EN del menú lo usa para saltar a la página equivalente.

## Estructura

- `_quarto.yml`: configuración, menús (español e inglés) y selector de idioma.
- `theme.scss`: colores y tipografía (los de networkianos.com).
- `_listing/`: diseño de las fichas (`fichas*.ejs`, `publicaciones*.ejs`) y filtro `enlaces.lua` (autores, botones, portada).
- `img/logos/`: logotipos de las secciones de la portada.
- `CNAME`: dominio `lab.networkianos.com`.
