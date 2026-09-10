# Imagen para renderizar el modelo Structurizr DSL (diagrama.dsl) a diagramas
# PNG: System Landscape, Context, Container y Deployment.
#
# Se parte del tag oficial "-playwright": la exportacion a PNG/SVG usa
# Playwright (Chromium headless) para tomar el snapshot de cada vista, y esas
# dependencias nativas no estan incluidas en el tag "latest"/sin sufijo (ver
# docs.structurizr.com/export/png-and-svg). El ENTRYPOINT de la imagen base
# (/usr/local/structurizr.sh) ya despacha subcomandos como "export" o
# "local", asi que no hace falta sobreescribirlo aqui.
#
# Build:
#   docker build -t iot-informe-diagrams ./arquitectura

FROM structurizr/structurizr:2026.06.28-playwright
