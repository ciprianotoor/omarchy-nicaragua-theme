![Nicaragua Omarchy Theme](cover.svg)

# Nicaragua — Omarchy theme

Tema inspirado en Nicaragua: azul y blanco, el Lago Cocibolca, volcanes, ríos, costas y la arquitectura colonial de Granada.

```bash
omarchy theme set nicaragua
omarchy theme refresh
omarchy theme bg next
```

Los fondos fotográficos con licencia abierta se encuentran en `backgrounds/`. Consulta `SOURCES.txt` para atribuciones y licencias.

## Herramientas de sincronización

El repositorio incluye un gestor con menú para aplicar el tema, sincronizar o
publicar cambios, listar temas instalados, actualizar temas y buscar temas
públicos en GitHub:

```bash
./scripts/omarchy-theme-tools.sh
```

También puedes usar comandos directos:

```bash
./scripts/omarchy-theme-tools.sh apply
./scripts/omarchy-theme-tools.sh sync
./scripts/omarchy-theme-tools.sh search
./scripts/omarchy-theme-tools.sh update
```

La sincronización usa `git pull --ff-only` y se detiene si hay cambios locales.
La instalación de temas delega en `omarchy theme install`; revisa el repositorio
antes de instalar temas de terceros.
