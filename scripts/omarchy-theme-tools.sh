#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
THEME_NAME=${THEME_NAME:-nicaragua}

RESET=$'\e[0m'
BLUE=$'\e[38;5;4m'
CYAN=$'\e[38;5;6m'
GREEN=$'\e[38;5;2m'
YELLOW=$'\e[38;5;3m'
RED=$'\e[38;5;1m'
MUTED=$'\e[38;5;8m'

title() {
    printf '\n%s╭─ %s󰣇  %s%s\n' "$MUTED" "$BLUE" "$1" "$RESET"
    printf '%s╰────────────────────────────────────────%s\n\n' "$MUTED" "$RESET"
}
ok() { printf '%s󰄬 %s%s\n' "$GREEN" "$1" "$RESET"; }
warn() { printf '%s󰀪 %s%s\n' "$YELLOW" "$1" "$RESET"; }
error() { printf '%s󰅚 %s%s\n' "$RED" "$1" "$RESET" >&2; }
tip() { printf '%s󰋽 Tip%s %s\n' "$CYAN" "$RESET" "$1"; }
confirm() {
    local answer
    printf '%s󰐕 %s %s[s/N]%s: ' "$CYAN" "$1" "$MUTED" "$RESET"
    read -r answer
    [[ "$answer" =~ ^[SsYy]$ ]]
}

require() { command -v "$1" >/dev/null 2>&1 || { error "No se encontró '$1'."; exit 1; }; }

apply_nicaragua() {
    require omarchy
    omarchy theme set "$THEME_NAME"
    ok "Tema '$THEME_NAME' aplicado."
}

sync_repo() {
    require git
    cd "$REPO_DIR"
    if [[ -n $(git status --porcelain) ]]; then
        error 'El repositorio tiene cambios locales; no se hará pull.'
        git status --short
        return 1
    fi
    git pull --ff-only
    ok 'Repositorio del tema actualizado.'
}

publish_repo() {
    require git
    cd "$REPO_DIR"
    git status --short
    [[ -n $(git status --porcelain) ]] || { warn 'No hay cambios para publicar.'; return 0; }
    git add -A
    local message
    printf '%s' "$CYAN󰜘 Mensaje del commit $MUTED[Actualizar tema]$RESET: "
    read -r message
    git commit -m "${message:-Actualizar tema}"
    if confirm '¿Hacer push al repositorio del tema?'; then
        git push
        ok 'Cambios publicados.'
    else
        tip 'El commit quedó local; puedes publicarlo después con git push.'
    fi
}

search_themes() {
    require gh
    title 'Buscar temas públicos de Omarchy'
    tip 'La búsqueda usa GitHub y muestra repositorios que contienen «omarchy» y «theme».'
    gh api -X GET search/repositories \
        -f q='omarchy theme in:name' -f sort=stars -f order=desc -f per_page=20 \
        --jq '.items[] | "\(.full_name)  ★\(.stargazers_count)\n  \(.html_url)\n  \(.description // "Sin descripción")\n"'
}

installed() {
    require omarchy
    title 'Temas instalados'
    omarchy theme list
    printf '\n'
    omarchy theme extras
}

update_installed() {
    require omarchy
    title 'Actualizar temas instalados'
    omarchy theme update
    ok 'Temas instalados revisados.'
}

help_text() {
    title 'Herramientas de temas Omarchy'
    printf '%s\n' \
        '  apply       Aplicar el tema Nicaragua' \
        '  sync        Actualizar este repositorio sin sobrescribir cambios' \
        '  publish     Crear un commit y ofrecer push' \
        '  search      Buscar temas públicos en GitHub' \
        '  installed   Listar temas disponibles e instalados' \
        '  update      Actualizar temas instalados desde sus repositorios' \
        '  menu        Abrir el menú interactivo'
}

menu() {
    local option url
    while true; do
        title 'OMARCHY · Gestor de temas'
        printf '  %s1%s  Aplicar Nicaragua\n' "$BLUE" "$RESET"
        printf '  %s2%s  Sincronizar repositorio Nicaragua\n' "$BLUE" "$RESET"
        printf '  %s3%s  Publicar cambios de Nicaragua\n' "$BLUE" "$RESET"
        printf '  %s4%s  Buscar temas en GitHub\n' "$BLUE" "$RESET"
        printf '  %s5%s  Listar temas instalados\n' "$BLUE" "$RESET"
        printf '  %s6%s  Actualizar temas instalados\n' "$BLUE" "$RESET"
        printf '  %s0%s  Salir\n\n' "$BLUE" "$RESET"
        printf '%s󰘳 Selecciona una opción%s: ' "$CYAN" "$RESET"
        read -r option
        case "$option" in
            1) apply_nicaragua ;;
            2) sync_repo ;;
            3) publish_repo ;;
            4) search_themes ;;
            5) installed ;;
            6) update_installed ;;
            0) return ;;
            *) error 'Opción inválida.' ;;
        esac
        printf '\n'; read -r -p 'Pulsa ENTER para continuar' _
    done
}

case "${1:-menu}" in
    apply) apply_nicaragua ;;
    sync) sync_repo ;;
    publish) publish_repo ;;
    search) search_themes ;;
    installed) installed ;;
    update) update_installed ;;
    help|--help|-h) help_text ;;
    menu) menu ;;
    *) error "Uso: $0 [apply|sync|publish|search|installed|update|help|menu]"; exit 2 ;;
esac
