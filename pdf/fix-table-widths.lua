-- Filtro de tablas para el PDF. Hace dos cosas:
--
-- 1) Ancho de columnas: los pipe tables (GFM) no traen ancho, asi que pandoc
--    las arma con columnas "l" sin wrap y una celda con un parrafo largo
--    desborda la pagina. Se le asigna a cada tabla anchos explicitos
--    (proporcionales al texto que carga cada columna), lo que hace que pandoc
--    genere columnas "p{...}" que si wrappean.
--
-- 2) Bordes de celda: por defecto pandoc usa estilo booktabs (solo tres
--    lineas horizontales: arriba, bajo el encabezado y abajo, sin lineas
--    verticales). Para que las tablas del informe se lean como grilla, la
--    tabla se escribe a LaTeX y se le agregan las lineas verticales al
--    preambulo de columnas y un \hline despues de cada fila.

local MIN_FRAC = 0.08

-- Pandoc resuelve las rutas de imagen con --resource-path, pero solo para las
-- imagenes que siguen en el AST. Como esta tabla se entrega como LaTeX crudo,
-- sus imagenes quedan fuera de esa resolucion y hay que dejarlas apuntando a
-- una ruta valida desde la raiz del repo: todas las secciones viven en
-- informe/<seccion>/, asi que "../assets/" equivale a "informe/assets/".
local function resolve_image_paths(tbl)
  return tbl:walk({
    Image = function(img)
      img.src = img.src:gsub('^%.%./assets/', 'informe/assets/')
      return img
    end
  })
end

-- Escribe una tabla ya con anchos asignados al LaTeX que produciria pandoc.
local function render_latex(tbl)
  return pandoc.write(pandoc.Pandoc({ resolve_image_paths(tbl) }), 'latex')
end

-- Convierte el LaTeX booktabs que genera pandoc en una tabla con grilla:
-- lineas verticales entre columnas y un \hline despues de cada fila.
local function add_cell_borders(latex, ncols)
  -- Linea vertical al inicio de cada columna (el preambulo pandoc emite una
  -- linea ">{\raggedright\arraybackslash}p{...}" por columna).
  latex = latex:gsub('>{\\raggedright\\arraybackslash}p{', '|>{\\raggedright\\arraybackslash}p{')
  -- El "@{}" de apertura y cierre suprime el padding de los bordes; con
  -- lineas verticales si se quiere ese padding, asi que se quitan y el de
  -- cierre pasa a ser la linea vertical derecha.
  latex = latex:gsub('\\begin{longtable}%[%]{@{}', '\\begin{longtable}[]{')
  latex = latex:gsub('@{}}\n', '|}\n')
  -- Un \hline despues de cada fila (encabezado incluido).
  latex = latex:gsub(' \\\\\n', ' \\\\ \\hline\n')
  -- La linea superior de booktabs pasa a ser el borde superior; las otras dos
  -- sobran porque cada fila ya cierra con su propio \hline.
  latex = latex:gsub('\\toprule\\noalign{}', '\\hline')
  latex = latex:gsub('\\midrule\\noalign{}\n', '')
  latex = latex:gsub('\\bottomrule\\noalign{}\n', '')
  -- Pandoc calcula el ancho de columna restandole a \linewidth el padding de
  -- las columnas interiores (2*(ncols-1) veces \tabcolsep), porque el "@{}"
  -- eliminaba el de los bordes. Al reponer ese padding y agregar las lineas
  -- verticales hay que restar tambien el padding de los bordes y el grosor de
  -- las reglas, o la tabla se desborda del margen.
  latex = latex:gsub('%(\\linewidth %- %d+\\tabcolsep%)',
    '(\\linewidth - ' .. (2 * ncols) .. '\\tabcolsep - ' .. (ncols + 1) .. '\\arrayrulewidth)')
  return latex
end


function Table(tbl)
  local ncols = #tbl.colspecs
  if ncols == 0 then
    return tbl
  end

  local rows = {}
  if tbl.head and tbl.head.rows then
    for _, row in ipairs(tbl.head.rows) do
      table.insert(rows, row)
    end
  end
  for _, body in ipairs(tbl.bodies) do
    for _, row in ipairs(body.body) do
      table.insert(rows, row)
    end
  end

  local lengths = {}
  for i = 1, ncols do
    lengths[i] = 0
  end

  for _, row in ipairs(rows) do
    for i, cell in ipairs(row.cells) do
      if i <= ncols then
        lengths[i] = lengths[i] + #pandoc.utils.stringify(cell)
      end
    end
  end

  local total = 0
  for i = 1, ncols do
    lengths[i] = math.max(lengths[i], 1)
    total = total + lengths[i]
  end

  local widths = {}
  local sum = 0
  for i = 1, ncols do
    widths[i] = math.max(lengths[i] / total, MIN_FRAC)
    sum = sum + widths[i]
  end
  for i = 1, ncols do
    widths[i] = widths[i] / sum
  end

  for i, spec in ipairs(tbl.colspecs) do
    tbl.colspecs[i] = { spec[1], widths[i] }
  end

  return pandoc.RawBlock('latex', add_cell_borders(render_latex(tbl), ncols))
end
