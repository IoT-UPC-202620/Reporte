-- Filtro de HTML para el PDF. El writer de LaTeX de pandoc descarta el HTML
-- crudo, asi que todo bloque HTML del informe (la caratula centrada, un <img>,
-- un <table>) se perdia en silencio al compilar. Este filtro parsea cada bloque
-- con el lector de HTML de pandoc y lo devuelve como bloques nativos, que ya si
-- se escriben a LaTeX (y que luego procesa fix-table-widths.lua si son tablas).
--
-- Debe ir ANTES de fix-table-widths.lua en la linea de comandos de pandoc.

-- Texto, imagen o tabla: lo que si hay que conservar.
local function has_content(blocks)
  local found = pandoc.utils.stringify(pandoc.Pandoc(blocks)):match('%S') ~= nil
  pandoc.Pandoc(blocks):walk({
    Image = function() found = true end,
    Table = function() found = true end,
  })
  return found
end

local function has_table(blocks)
  local found = false
  pandoc.Pandoc(blocks):walk({
    Table = function() found = true end,
  })
  return found
end

-- Marca opcional en el Markdown, invisible en GitHub, justo antes de una tabla:
--
--   <!-- pdf:unroll -->
--
--   | tabla | ... |
--
-- LaTeX no parte una fila de longtable entre paginas: si una celda es mas alta
-- que la pagina (p. ej. la tabla de Student Outcome, que el statement pide
-- ampliar en cada entrega) la fila se sale del margen y deja paginas en blanco.
-- Con la marca, la tabla se escribe como bloques (etiqueta de columna + contenido
-- de cada celda), que si paginan.
local UNROLL_MARK = '^%s*<!%-%-%s*pdf:unroll%s*%-%->%s*$'

local function unroll(tbl)
  local labels = {}
  for i, cell in ipairs(tbl.head.rows[1] and tbl.head.rows[1].cells or {}) do
    labels[i] = pandoc.utils.stringify(cell.contents)
  end

  local out = pandoc.List()
  for _, body in ipairs(tbl.bodies) do
    for r, row in ipairs(body.body) do
      if r > 1 then
        out:insert(pandoc.RawBlock('latex', '\\medskip\\hrule\\medskip'))
      end
      for i, cell in ipairs(row.cells) do
        local label = pandoc.Strong({ pandoc.Str((labels[i] or '') .. (i == 1 and ':' or '')) })
        local contents = cell.contents:map(function(b)
          if b.t == 'Plain' then return pandoc.Para(b.content) end
          return b
        end)
        if i == 1 and contents[1] and contents[1].t == 'Para' then
          -- El criterio (1.a celda) va en una linea junto con su etiqueta.
          local inlines = pandoc.List({ label, pandoc.Space() })
          inlines:extend(contents[1].content)
          out:insert(pandoc.Para(inlines))
          for k = 2, #contents do out:insert(contents[k]) end
        else
          out:insert(pandoc.Para({ label }))
          out:extend(contents)
        end
      end
    end
  end
  return out
end

-- Un "<br>" dentro de una celda de tabla pipe (o de un parrafo Markdown) llega
-- como HTML en linea, que el writer de LaTeX tambien descarta: las lineas de la
-- celda quedaban pegadas. Se convierte en un salto de linea nativo.
function RawInline(el)
  if el.format == 'html' and el.text:match('^<br%s*/?>$') then
    return pandoc.LineBreak()
  end
  return nil
end

-- Reemplaza cada "<!-- pdf:unroll -->" y la tabla que le sigue por sus bloques.
function Blocks(blocks)
  local out = pandoc.List()
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    if b.t == 'RawBlock' and b.format == 'html' and b.text:match(UNROLL_MARK) then
      local nxt = blocks[i + 1]
      if nxt and nxt.t == 'Table' then
        out:extend(unroll(nxt))
        i = i + 2
      else
        i = i + 1 -- marca sin tabla a continuacion: se descarta
      end
    else
      out:insert(b)
      i = i + 1
    end
  end
  return out
end

function RawBlock(el)
  if el.format ~= 'html' then
    return nil
  end

  -- La marca de arriba se consume en Blocks(), junto con su tabla.
  if el.text:match(UNROLL_MARK) then
    return nil
  end

  local blocks = pandoc.read(el.text, 'html').blocks

  -- Un "<br>" suelto (o un "</p>" de cierre) no aporta contenido. Un "\\" a
  -- comienzo de parrafo haria fallar a LaTeX ("no line here to end"), asi que
  -- un <br> solitario se traduce como un espacio vertical.
  if not has_content(blocks) then
    if el.text:match('<br') then
      return pandoc.RawBlock('latex', '\\bigskip')
    end
    return {}
  end

  -- align="center" se pierde al parsear; se restituye con un entorno center.
  -- Las tablas se saltan porque longtable ya ocupa todo el ancho.
  if el.text:match('^%s*<%w+[^>]-align="center"') and not has_table(blocks) then
    local centered = pandoc.List({ pandoc.RawBlock('latex', '\\begin{center}') })
    centered:extend(blocks)
    centered:insert(pandoc.RawBlock('latex', '\\end{center}'))
    return centered
  end

  return blocks
end
