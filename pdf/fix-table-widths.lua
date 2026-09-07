-- Los pipe tables (GFM) no traen ancho de columna, asi que pandoc las arma
-- con columnas "l" sin wrap: si una celda tiene un parrafo largo, la tabla se
-- desborda de la pagina en el PDF. Este filtro le asigna a cada tabla anchos
-- de columna explicitos (proporcionales a la cantidad de texto que carga cada
-- columna), lo que hace que pandoc genere columnas "p{...}" que si wrappean.

local MIN_FRAC = 0.08

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

  return tbl
end
