-- Añade al principio de cada ficha (preprint, artículo, datos, skill, vídeo)
-- los autores, la revista y los botones DOI / PDF / Datos / Código / Vídeo.
local function s(v) return v and pandoc.utils.stringify(v) or "" end

function Pandoc(doc)
  local m = doc.meta
  local en = s(m.lang) == "en"
  -- Enlace a la versión en el otro idioma (lo usa el selector ES/EN)
  if s(m.alt) ~= "" then
    table.insert(doc.blocks, 1, pandoc.RawBlock("html", '<span id="nw-alt" data-href="' .. s(m.alt) .. '" hidden></span>'))
  end
  if not m.tipo then return doc end
  local html = {}
  local info = {}
  if s(m.autores) ~= "" then table.insert(info, s(m.autores)) end
  if s(m.revista) ~= "" then table.insert(info, "<em>" .. s(m.revista) .. "</em>") end
  if m.plataformas then
    local p = {}
    if type(m.plataformas) == "table" and m.plataformas[1] then
      for _, v in ipairs(m.plataformas) do table.insert(p, s(v)) end
    else table.insert(p, s(m.plataformas)) end
    table.insert(info, (en and "Tested in: " or "Probada en: ") .. table.concat(p, ", "))
  end
  if #info > 0 then
    table.insert(html, '<p class="nw-meta">' .. table.concat(info, " · ") .. "</p>")
  end
  local btns = {}
  local function add(url, label)
    if url ~= "" then table.insert(btns, '<a class="nw-btn" href="' .. url .. '">' .. label .. "</a>") end
  end
  local doi = s(m.doi)
  if doi ~= "" and not doi:match("^http") then doi = "https://doi.org/" .. doi end
  add(doi, "DOI"); add(s(m.pdf), "PDF"); add(s(m.datos), en and "Data" or "Datos"); add(s(m.codigo), en and "Code" or "Código")
  if s(m.tipo) ~= "video" then add(s(m.youtube), en and "Video" or "Vídeo") end
  if #btns > 0 then
    table.insert(html, '<div class="nw-links">' .. table.concat(btns) .. "</div>")
  end
  if s(m.image) ~= "" and s(m.tipo) ~= "video" and s(m.tipo) ~= "skill" then
    table.insert(html, 1, '<img class="nw-cover" src="' .. s(m.image) .. '" alt="">')
  end
  if #html > 0 then
    table.insert(doc.blocks, s(m.alt) ~= "" and 2 or 1, pandoc.RawBlock("html", '<div class="nw-item-head">' .. table.concat(html) .. "</div>"))
  end
  return doc
end
