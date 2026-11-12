-- Filtro de las fichas de Networkianos Lab:
--  * autores (con enlace a su perfil), revista, "Probada en" y botones DOI / PDF / Datos / Código / Vídeo
--  * portada de la publicación
--  * enlace a la versión en el otro idioma (#nw-alt, lo usa el selector ES/EN)
--  * SEO: hreflang, metadatos de Google Scholar (citation_*) y JSON-LD de cada publicación
local function s(v) return v and pandoc.utils.stringify(v) or "" end
local SITE = "https://lab.networkianos.com"

local PERFILES = {
  ["Julián Cárdenas"] = { es = "/equipo/julian-cardenas.html", en = "/en/team/julian-cardenas.html" },
  ["Zeus Domínguez-Rubio"] = { es = "/equipo/zeus-dominguez-rubio.html", en = "/en/team/zeus-dominguez-rubio.html" },
}

local function esc(t) return (t:gsub("&", "&amp;"):gsub('"', "&quot;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
local function jsonstr(t) return '"' .. t:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"' end

local function split_autores(a)
  local out = {}
  a = a:gsub(" y ", ", "):gsub(" and ", ", ")
  for name in a:gmatch("[^,]+") do
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name ~= "" then table.insert(out, name) end
  end
  return out
end

local function self_path()
  local input = quarto.doc.input_file or ""
  local root = (quarto.project and quarto.project.directory) or ""
  local rel = input:sub(#root + 2):gsub("%.qmd$", ".html"):gsub("\\", "/")
  rel = rel:gsub("index%.html$", "")
  return "/" .. rel
end

local function abs(u)
  if u == "" then return "" end
  if u:match("^https?://") then return u end
  if u:sub(1, 1) == "/" then return SITE .. u end
  return u
end

function Pandoc(doc)
  local m = doc.meta
  local en = s(m.lang) == "en"
  local lang = en and "en" or "es"
  local head = {}

  -- hreflang
  local me = self_path()
  if s(m.alt) ~= "" then
    table.insert(doc.blocks, 1, pandoc.RawBlock("html", '<span id="nw-alt" data-href="' .. s(m.alt) .. '" hidden></span>'))
    table.insert(head, '<link rel="alternate" hreflang="' .. lang .. '" href="' .. SITE .. me .. '">')
    table.insert(head, '<link rel="alternate" hreflang="' .. (en and "es" or "en") .. '" href="' .. SITE .. s(m.alt) .. '">')
  end

  if not m.tipo then
    if #head > 0 then quarto.doc.include_text("in-header", table.concat(head, "\n")) end
    return doc
  end

  local html, info = {}, {}
  local autores = s(m.autores)
  if autores ~= "" then
    local linked = autores
    for name, url in pairs(PERFILES) do
      linked = linked:gsub(name:gsub("%-", "%%-"), '<a href="' .. url[lang] .. '">' .. name .. '</a>')
    end
    table.insert(info, linked)
  end
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
  local doiurl = doi
  if doi ~= "" and not doi:match("^http") then doiurl = "https://doi.org/" .. doi end
  add(doiurl, "DOI"); add(s(m.pdf), "PDF"); add(s(m.datos), en and "Data" or "Datos"); add(s(m.codigo), en and "Code" or "Código")
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

  -- Metadatos para Google Scholar y datos estructurados (solo publicaciones)
  local tipo = s(m.tipo)
  local pubtypes = { preprint = true, articulo = true, capitulo = true, informe = true }
  if pubtypes[tipo] then
    local title, year = s(m.title), (s(m.date):match("%d%d%d%d") or "")
    local scholar = not en  -- Google Scholar solo en la ficha original (española) para no duplicar
    local function cite(tag) if scholar then table.insert(head, tag) end end
    cite( '<meta name="citation_title" content="' .. esc(title) .. '">')
    local names = split_autores(autores)
    for _, n in ipairs(names) do cite('<meta name="citation_author" content="' .. esc(n) .. '">') end
    if year ~= "" then cite('<meta name="citation_publication_date" content="' .. year .. '">') end
    local rev = s(m.revista)
    if tipo == "capitulo" then
      if rev ~= "" then cite('<meta name="citation_inbook_title" content="' .. esc(rev) .. '">') end
    elseif rev ~= "" then
      cite('<meta name="citation_journal_title" content="' .. esc(rev) .. '">')
    end
    if doi ~= "" then cite('<meta name="citation_doi" content="' .. esc((doi:gsub("^https?://doi.org/", ""))) .. '">') end
    if s(m.pdf) ~= "" then cite('<meta name="citation_pdf_url" content="' .. abs(s(m.pdf)) .. '">') end
    cite('<meta name="citation_abstract_html_url" content="' .. SITE .. me .. '">')
    -- JSON-LD
    local authors = {}
    for _, n in ipairs(names) do
      local a = '{"@type":"Person","name":' .. jsonstr(n)
      if PERFILES[n] then a = a .. ',"url":' .. jsonstr(SITE .. PERFILES[n][lang]) end
      table.insert(authors, a .. '}')
    end
    local ld = '{"@context":"https://schema.org","@type":' .. jsonstr(tipo == "capitulo" and "Chapter" or "ScholarlyArticle")
      .. ',"headline":' .. jsonstr(title) .. ',"name":' .. jsonstr(title)
      .. ',"author":[' .. table.concat(authors, ",") .. ']'
      .. (year ~= "" and (',"datePublished":' .. jsonstr(year)) or "")
      .. (s(m.description) ~= "" and (',"description":' .. jsonstr(s(m.description))) or "")
      .. (rev ~= "" and (',"isPartOf":{"@type":' .. jsonstr(tipo == "capitulo" and "Book" or "Periodical") .. ',"name":' .. jsonstr(rev) .. '}') or "")
      .. (doiurl ~= "" and (',"sameAs":' .. jsonstr(doiurl)) or "")
      .. (s(m.pdf) ~= "" and (',"encoding":{"@type":"MediaObject","contentUrl":' .. jsonstr(abs(s(m.pdf))) .. ',"encodingFormat":"application/pdf"}') or "")
      .. ',"url":' .. jsonstr(SITE .. me) .. ',"inLanguage":' .. jsonstr(lang) .. '}'
    table.insert(head, '<script type="application/ld+json">' .. ld .. '</script>')
  end
  if #head > 0 then quarto.doc.include_text("in-header", table.concat(head, "\n")) end
  return doc
end
