--[[===========================================================================
  NIGHT CITY NOIR — dadosSistema.lua
  As 28 perícias do Cap. 3, com atributo, categoria e o que cada uma cobre.

  "Perícias cobrem uma CATEGORIA DE AÇÃO, não uma ferramenta específica.
   Combate C.C. (Armado) serve tanto pra faca quanto pra katana — modificadores
   situacionais cobrem o resto, sem precisar de perícia nova." (Cap. 3)

  NOTA — o Sumário do livro diz "26 perícias"; as tabelas do Cap. 3 listam 28.
  A ficha segue as TABELAS, que são a fonte com os números.
=============================================================================]]

local D = {}

--[[---------------------------------------------------------------------------
  ATRIBUTO DE CADA PERÍCIA
  Duas perícias têm dois atributos no livro: Manha (MEN/VON) e Sobrevivência
  (COR/MEN). O livro só escreve a barra, sem dizer como escolher.

  DECISÃO DE MESA (confirmada com o mestre, não está escrita no livro):
  a ficha usa sempre o MAIOR dos dois, automaticamente. Se um dia a mesa mudar
  de ideia, é aqui que se mexe — `atributoAlt` já existe pra isso.
-----------------------------------------------------------------------------]]

D.CATEGORIAS_PERICIA = {
    { chave="combate",   nome="Combate",                  cor="#FF3B7F" },
    { chave="fisicas",   nome="Físicas",                  cor="#23E5D3" },
    { chave="tecnicas",  nome="Técnicas",                 cor="#8A63C9" },
    { chave="sociais",   nome="Sociais",                  cor="#FFB03A" },
    { chave="percepcao", nome="Conhecimento & Percepção", cor="#3DD68C" },
}

D.PERICIAS = {
    -- COMBATE ----------------------------------------------------------------
    { campo="cc_armado",          nome="Combate C.C. (Armado)",       atributo="cor", categoria="combate",
      cobre="Facas, tacos, katanas, armas brancas em geral" },
    { campo="cc_desarmado",       nome="Combate C.C. (Desarmado)",    atributo="cor", categoria="combate",
      cobre="Socos, chutes, luta agarrada, artes marciais" },
    { campo="cd_fogo",            nome="Combate à Distância (Fogo)",  atributo="ref", categoria="combate",
      cobre="Pistolas, fuzis, submetralhadoras" },
    { campo="cd_arco",            nome="Combate à Distância (Arco/Arremesso)", atributo="ref", categoria="combate",
      cobre="Arcos, facas de arremesso, granadas" },
    { campo="armas_pesadas",      nome="Armas Pesadas",               atributo="ref", categoria="combate",
      cobre="Metralhadoras, lançadores, armas montadas" },
    { campo="explosivos",         nome="Explosivos",                  atributo="men", categoria="combate",
      cobre="Montar, desarmar, calcular raio de carga" },

    -- FÍSICAS ----------------------------------------------------------------
    { campo="atletismo",          nome="Atletismo",                   atributo="cor", categoria="fisicas",
      cobre="Correr, saltar, escalar, nadar" },
    { campo="furtividade",        nome="Furtividade",                 atributo="ref", categoria="fisicas",
      cobre="Esconder-se, mover-se em silêncio" },
    { campo="prestidigitacao",    nome="Prestidigitação",             atributo="ref", categoria="fisicas",
      cobre="Punga, sabotagem manual rápida" },
    { campo="pilot_terrestre",    nome="Pilotagem Terrestre",         atributo="ref", categoria="fisicas",
      cobre="Carros, motos, veículos terrestres" },
    { campo="pilot_aerea",        nome="Pilotagem Aérea/Drones",      atributo="ref", categoria="fisicas",
      cobre="AVs, drones, veículos aéreos" },
    { campo="conducao_arriscada", nome="Condução Arriscada",          atributo="ref", categoria="fisicas",
      cobre="Perseguições, manobras extremas" },

    -- TÉCNICAS ---------------------------------------------------------------
    { campo="interface",          nome="Interface",                   atributo="men", categoria="tecnicas",
      cobre="Netrunning, invasão de sistemas" },
    { campo="eletronica",         nome="Eletrônica",                  atributo="men", categoria="tecnicas",
      cobre="Sensores, câmeras, dispositivos" },
    { campo="mecanica",           nome="Mecânica",                    atributo="men", categoria="tecnicas",
      cobre="Veículos, armas de fogo, maquinário" },
    { campo="eng_cyber",          nome="Engenharia de Cyberware",     atributo="men", categoria="tecnicas",
      cobre="Instalar, ajustar e modificar implantes" },
    { campo="ciencia",            nome="Ciência",                     atributo="men", categoria="tecnicas",
      cobre="Química, biologia, farmacologia aplicada" },
    { campo="medicina",           nome="Medicina & Primeiros Socorros", atributo="men", categoria="tecnicas",
      cobre="Estabilizar, tratar ferimentos, diagnosticar" },
    { campo="pesquisa",           nome="Pesquisa & Redes",            atributo="men", categoria="tecnicas",
      cobre="Buscar informação em redes e bases de dados" },

    -- SOCIAIS ----------------------------------------------------------------
    { campo="persuasao",          nome="Persuasão",                   atributo="von", categoria="sociais",
      cobre="Convencer, negociar, argumentar" },
    { campo="intimidacao",        nome="Intimidação",                 atributo="von", categoria="sociais",
      cobre="Ameaçar, coagir, impor presença" },
    { campo="enganacao",          nome="Enganação",                   atributo="von", categoria="sociais",
      cobre="Mentir, blefar, disfarçar-se" },
    { campo="manha",              nome="Manha (Streetwise)",          atributo="men", atributoAlt="von", categoria="sociais",
      cobre="Conhecer a rua, contatos, mercado negro" },
    { campo="etiqueta",           nome="Etiqueta Corporativa",        atributo="von", categoria="sociais",
      cobre="Navegar ambientes corp, protocolo" },
    { campo="performance",        nome="Performance",                 atributo="von", categoria="sociais",
      cobre="Atuar, tocar, discursar, chamar atenção" },

    -- CONHECIMENTO & PERCEPÇÃO -----------------------------------------------
    { campo="percepcao_ativa",    nome="Percepção Ativa",             atributo="men", categoria="percepcao",
      cobre="Notar detalhes, buscar pistas, vigiar" },
    { campo="tatica",             nome="Tática",                      atributo="men", categoria="percepcao",
      cobre="Planejamento de combate, leitura de situação" },
    { campo="sobrevivencia",      nome="Sobrevivência",               atributo="cor", atributoAlt="men", categoria="percepcao",
      cobre="Durar em ambientes hostis (Combat Zone, deserto)" },
}

--- Índice por campo, para lookup O(1) no meio do recálculo.
D.PERICIA_POR_CAMPO = {}
for _, p in ipairs(D.PERICIAS) do D.PERICIA_POR_CAMPO[p.campo] = p end

--- Perícias de uma categoria, na ordem do livro.
function D.periciasDaCategoria(chaveCategoria)
    local out = {}
    for _, p in ipairs(D.PERICIAS) do
        if p.categoria == chaveCategoria then out[#out + 1] = p end
    end
    return out
end

--[[---------------------------------------------------------------------------
  PERÍCIA DE ATAQUE POR TIPO DE ARMA — Cap. 4, "Como rolar cada tipo de ataque"
  "TIPO DE ARMA | PERÍCIA | ATRIB.
   Corpo a corpo (armado)      | Combate C.C. (Armado)     | COR
   Corpo a corpo (desarmado)   | Combate C.C. (Desarmado)  | COR
   Arma de fogo                | Combate à Distância (Fogo)| REF
   Arco / arremesso / granada  | Combate à Distância (Arco/Arremesso) | REF
   Arma pesada / montada       | Armas Pesadas             | REF"
-----------------------------------------------------------------------------]]

-- DECISÃO DA MESA (v3.2, ratificada pelo mestre em 13/08/2026): **todo
-- explosivo rola Explosivos (MEN)** — mirar, arremessar, montar e desarmar.
-- O rodapé do Cap. 9 só dizia "montar e desarmar cargas usa Explosivos (MEN)",
-- e a tabela de Alcance mantinha "Arco/Arremesso", o que fazia a granada cair
-- em REF. A mesa joga com MEN nos dois momentos.
--
-- A Faca de Arremesso NÃO entra aqui: ela é arremesso, não explosivo, e
-- continua em Combate à Distância (Arco/Arremesso).
D.PERICIA_DE_ATAQUE = {
    corpoArmado    = "cc_armado",
    corpoDesarmado = "cc_desarmado",
    fogo           = "cd_fogo",
    arremesso      = "cd_arco",
    pesada         = "armas_pesadas",
    explosivo      = "explosivos",
}

D.TIPOS_ARMA = {
    { chave="corpoArmado",    nome="Corpo a corpo (armado)"      },
    { chave="corpoDesarmado", nome="Corpo a corpo (desarmado)"   },
    { chave="fogo",           nome="Arma de fogo"                },
    { chave="arremesso",      nome="Arco / arremesso"            },
    { chave="explosivo",      nome="Explosivo (granada, carga)"  },
    { chave="pesada",         nome="Arma pesada / montada"       },
}

--[[---------------------------------------------------------------------------
  TABELA DE ALCANCE — Cap. 9
  "Sem régua — o mestre define curta/média/longa pela cena."
  N/A = a arma não alcança aquela faixa.
-----------------------------------------------------------------------------]]

D.ALCANCE = {
    ["Pistola / SMG"]        = { curta = 0,  media = -2, longa = -6  },
    ["Escopeta"]             = { curta = 2,  media = -4, longa = nil },
    ["Fuzil de Assalto"]     = { curta = 0,  media = 0,  longa = -3  },
    ["Fuzil de Precisão"]    = { curta = -4, media = 0,  longa = 2   },
    ["Arma Pesada/Militar"]  = { curta = -2, media = 0,  longa = 0   },
    ["Arco/Arremesso"]       = { curta = 0,  media = -3, longa = nil },
}

D.CLASSES_ALCANCE = {
    "Pistola / SMG", "Escopeta", "Fuzil de Assalto",
    "Fuzil de Precisão", "Arma Pesada/Militar", "Arco/Arremesso",
}

--- Modificador de alcance. Devolve (mod, alcancavel).
function D.modAlcance(classe, faixa)
    local t = D.ALCANCE[classe]
    if t == nil then return 0, true end
    local v = t[faixa]
    if v == nil then return 0, false end
    return v, true
end

--[[---------------------------------------------------------------------------
  ARMADURAS — Cap. 4, tabela de Redução de Dano
-----------------------------------------------------------------------------]]

D.RD_POR_ARMADURA = {
    { nome="Roupa reforçada",            rd=1 },
    { nome="Colete leve",                rd=2 },
    { nome="Blindagem tática/corporativa", rd=4 },
    { nome="Blindagem militar pesada",   rd=6 },
}

return D
