#!/usr/bin/env bash
# Renderiza arquitectura/diagrama.dsl (Structurizr DSL) a PNG -- System
# Landscape, Context, Container y Deployment -- usando Docker + Structurizr
# (exportacion headless via Playwright/Chromium), y copia los 4 diagramas
# dentro de informe/assets/img/ con nombres estandar.
#
# Uso:
#   ./arquitectura/build.sh              # build de la imagen (si hace falta) + genera los PNG
#   ./arquitectura/build.sh --no-build   # se salta "docker build" y usa la imagen ya existente
#
# Requiere: Docker Desktop corriendo. Pensado para Git Bash / WSL / Linux / macOS.
# La primera vez descarga la imagen base structurizr/structurizr:*-playwright (~2 GB).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
IMAGE_NAME="iot-informe-diagrams"
IMG_DEST_DIR="$ROOT_DIR/informe/assets/img"

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

echo "==> Limpiando exportaciones anteriores en $DIST_DIR..."
rm -f "$DIST_DIR"/*.png

echo "==> Exportando vistas de diagrama.dsl a PNG (Structurizr + Playwright)..."

# En Git Bash / MSYS sobre Windows, docker.exe no es un binario MSYS: hay que
# desactivar la conversion automatica de rutas (MSYS_NO_PATHCONV) y usar la
# ruta en formato Windows para el volumen, o "-v" se arma mal.
DOCKER_MOUNT_PATH="$SCRIPT_DIR"
if command -v cygpath >/dev/null 2>&1; then
    DOCKER_MOUNT_PATH="$(cygpath -m "$SCRIPT_DIR")"
fi

MSYS_NO_PATHCONV=1 docker run --rm \
    -v "${DOCKER_MOUNT_PATH}:/usr/local/structurizr" \
    "$IMAGE_NAME" \
    export -workspace diagrama.dsl -format png -output dist

echo "==> Copiando diagramas a informe/assets/img/ con nombres estandar..."
mkdir -p "$IMG_DEST_DIR"

# Mapeo nombre-de-vista (key definido en diagrama.dsl) -> nombre estandar del
# informe. Si se agregan/renombran vistas en el DSL, este mapa debe actualizarse.
declare -A RENAME_MAP=(
    ["SystemLandscape.png"]="system-landscape-diagram.png"
    ["SystemContext.png"]="context-diagram.png"
    ["Containers.png"]="container-diagram.png"
    ["Deployment.png"]="deployment-diagram.png"
)

for src in "${!RENAME_MAP[@]}"; do
    dest="${RENAME_MAP[$src]}"
    if [[ ! -f "$DIST_DIR/$src" ]]; then
        echo "error: no se genero '$src' en $DIST_DIR -- revisa la salida de 'docker run' de arriba." >&2
        exit 1
    fi
    cp "$DIST_DIR/$src" "$IMG_DEST_DIR/$dest"
    echo "    $src -> informe/assets/img/$dest"
done

echo "==> Listo."
ls -lh "$IMG_DEST_DIR/system-landscape-diagram.png" \
       "$IMG_DEST_DIR/context-diagram.png" \
       "$IMG_DEST_DIR/container-diagram.png" \
       "$IMG_DEST_DIR/deployment-diagram.png"
