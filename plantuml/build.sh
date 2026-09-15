#!/usr/bin/env bash
# Renderiza todos los diagramas PlantUML (*.puml) bajo plantuml/ a PNG usando
# Docker (imagen oficial plantuml/plantuml), y copia cada PNG resultante a
# informe/assets/img/ con el mismo nombre base que el .puml de origen.
#
# Uso:
#   ./plantuml/build.sh
#
# Requiere: Docker Desktop corriendo. Pensado para Git Bash / WSL / Linux / macOS.
#
# Convencion: el nombre de archivo del .puml (sin extension) es el nombre de
# imagen que se usara en informe/assets/img/, p.ej.
# plantuml/domain-storytelling/domain-story-pagos.puml ->
# informe/assets/img/domain-story-pagos.png

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMG_DEST_DIR="$ROOT_DIR/informe/assets/img"

if ! command -v docker >/dev/null 2>&1; then
    echo "error: no se encontro 'docker' en el PATH. Instala/inicia Docker Desktop." >&2
    exit 1
fi

DOCKER_MOUNT_PATH="$SCRIPT_DIR"
if command -v cygpath >/dev/null 2>&1; then
    DOCKER_MOUNT_PATH="$(cygpath -m "$SCRIPT_DIR")"
fi

echo "==> Buscando archivos .puml en $SCRIPT_DIR..."
PUML_FILES=()
while IFS= read -r f; do
    PUML_FILES+=("$f")
done < <(find "$SCRIPT_DIR" -type f -name "*.puml" | LC_ALL=C sort)

if [[ "${#PUML_FILES[@]}" -eq 0 ]]; then
    echo "error: no se encontraron archivos .puml dentro de plantuml/" >&2
    exit 1
fi

echo "==> Renderizando ${#PUML_FILES[@]} diagrama(s) con PlantUML (Docker)..."
DOCKER_ARGS=()
for f in "${PUML_FILES[@]}"; do
    rel="${f#$SCRIPT_DIR/}"
    DOCKER_ARGS+=("/work/$rel")
done

MSYS_NO_PATHCONV=1 docker run --rm \
    -v "${DOCKER_MOUNT_PATH}:/work" \
    plantuml/plantuml -tpng "${DOCKER_ARGS[@]}"

echo "==> Copiando PNGs a informe/assets/img/..."
mkdir -p "$IMG_DEST_DIR"
for f in "${PUML_FILES[@]}"; do
    png="${f%.puml}.png"
    base="$(basename "$png")"
    if [[ -f "$png" ]]; then
        cp "$png" "$IMG_DEST_DIR/$base"
        echo "    $base"
    else
        echo "aviso: no se genero $png" >&2
    fi
done

echo "==> Listo."
