#!/usr/bin/env bash
# Compila informe/**/*.md (en orden de carpeta, el mismo orden que README.md)
# en un unico PDF con estilos, usando Docker + Pandoc + Eisvogel.
#
# Uso:
#   ./pdf/build.sh              # build de la imagen (si hace falta) + genera el PDF
#   ./pdf/build.sh --no-build   # se salta "docker build" y usa la imagen ya existente
#
# Requiere: Docker Desktop corriendo. Pensado para Git Bash / WSL / Linux / macOS.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
IMAGE_NAME="iot-informe-pdf"
COMBINED_MD="$DIST_DIR/combined.md"
OUTPUT_PDF="$DIST_DIR/informe.pdf"

SKIP_BUILD=false
if [[ "${1:-}" == "--no-build" ]]; then
    SKIP_BUILD=true
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "error: no se encontro 'docker' en el PATH. Instala/inicia Docker Desktop." >&2
    exit 1
fi

mkdir -p "$DIST_DIR"

if [[ "$SKIP_BUILD" == false ]]; then
    echo "==> Construyendo imagen Docker ($IMAGE_NAME)..."
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
fi

echo "==> Recolectando secciones de informe/ en orden..."
# El orden de lectura del informe esta dado por el prefijo numerico de cada
# carpeta (00-caratula, 01-registro-de-versiones, ..., 12-anexos), que es el
# mismo orden documentado en README.md y derivado del enunciado (statement).
# Un sort lexicografico (LC_ALL=C) alcanza porque los prefijos son de 2 digitos.
mapfile -t SOURCE_FILES < <(find "$ROOT_DIR/informe" -type f -name "*.md" | LC_ALL=C sort)

if [[ "${#SOURCE_FILES[@]}" -eq 0 ]]; then
    echo "error: no se encontraron archivos .md dentro de informe/" >&2
    exit 1
fi

echo "==> Armando documento combinado ($COMBINED_MD)..."
{
    printf -- '---\n'
    printf 'title: "Informe de Trabajo Final — 1ASI0572 Desarrollo de Soluciones IoT"\n'
    printf 'lang: es-ES\n'
    printf 'toc: true\n'
    printf 'toc-own-page: true\n'
    printf 'toc-depth: 3\n'
    printf 'colorlinks: true\n'
    printf 'linkcolor: blue\n'
    printf -- '---\n'
} > "$COMBINED_MD"

# Directorios (unicos, relativos a ROOT_DIR -- que es como se ve /data dentro
# del contenedor) donde vive cada seccion. Se pasan a pandoc como
# --resource-path para que las imagenes de cada capitulo (rutas relativas
# tipo ../assets/img/x.png o ../../statement/imagenes/x.jpeg) se resuelvan
# sin tener que reescribir ningun enlace al concatenar los .md.
RESOURCE_PATH="."
FIRST=true
for f in "${SOURCE_FILES[@]}"; do
    dir="$(dirname "${f#$ROOT_DIR/}")"
    if [[ ":$RESOURCE_PATH:" != *":$dir:"* ]]; then
        RESOURCE_PATH="$RESOURCE_PATH:$dir"
    fi

    if [[ "$FIRST" == false ]]; then
        # Salto de pagina en LaTeX antes de cada seccion (bloque crudo, requiere
        # la extension raw_attribute habilitada abajo en --from).
        printf '\n```{=latex}\n\\newpage\n```\n\n' >> "$COMBINED_MD"
    fi
    FIRST=false

    cat "$f" >> "$COMBINED_MD"
    printf '\n' >> "$COMBINED_MD"
done

echo "==> Secciones incluidas (${#SOURCE_FILES[@]}):"
printf '    %s\n' "${SOURCE_FILES[@]#$ROOT_DIR/}"

echo "==> Compilando PDF con Pandoc + Eisvogel (XeLaTeX)..."

# En Git Bash / MSYS sobre Windows, docker.exe no es un binario MSYS: hay que
# desactivar la conversion automatica de rutas (MSYS_NO_PATHCONV) y usar la
# ruta en formato Windows para el volumen, o "-v" se arma mal.
DOCKER_MOUNT_PATH="$ROOT_DIR"
if command -v cygpath >/dev/null 2>&1; then
    DOCKER_MOUNT_PATH="$(cygpath -m "$ROOT_DIR")"
fi

MSYS_NO_PATHCONV=1 docker run --rm \
    -v "${DOCKER_MOUNT_PATH}:/data" \
    -w /data \
    "$IMAGE_NAME" \
    --from=gfm+raw_attribute \
    --lua-filter=pdf/fix-table-widths.lua \
    --resource-path="$RESOURCE_PATH" \
    --template=/usr/local/share/pandoc/templates/eisvogel.latex \
    --pdf-engine=xelatex \
    --top-level-division=section \
    -o "pdf/dist/informe.pdf" \
    "pdf/dist/combined.md"

echo "==> Listo: $OUTPUT_PDF"
ls -lh "$OUTPUT_PDF"
