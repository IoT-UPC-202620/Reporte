# Imagen para compilar el informe (Markdown, GitHub-flavored) a un unico PDF
# con estilos, usando Pandoc + XeLaTeX + la plantilla Eisvogel.
#
# Se parte de pandoc/extra, que ya trae todos los paquetes LaTeX que Eisvogel
# necesita (koma-script, footnotebackref, mdframed, titling, etc. -- ver
# https://github.com/Wandmalfarbe/pandoc-latex-template#texlive) y la propia
# plantilla eisvogel.latex preinstalada en /usr/local/share/pandoc/templates.
# Evita tener que reconstruir esa lista de dependencias a mano con tlmgr.
#
# Build:
#   docker build -t iot-informe-pdf ./pdf

FROM pandoc/extra:3.10.0.0-ubuntu

WORKDIR /data
ENTRYPOINT ["pandoc"]
