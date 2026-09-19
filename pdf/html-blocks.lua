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

function RawBlock(el)
  if el.format ~= 'html' then
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
