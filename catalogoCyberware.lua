--[[===========================================================================
  NIGHT CITY NOIR — catalogoCyberware.lua
  Tabela de Cyberware do Cap. 6, transcrita item a item.

  `humanidade` é o número como o LIVRO IMPRIME: já negativo. Somar direto.

  `moeda` — o Cap. 6 abre com a tabela TIPO → CUSTO → MOEDA ACEITA:
      Cosmético       0   Limpos ou Sujos
      Funcional legal -1  Limpos ou Sujos
      Militar/pesado  -2  Sujos (ou Limpos + Etiqueta Corporativa com clearance)
      Black market    -3  Só Sujos
  Como os quatro custos são distintos, o custo de Humanidade de cada item
  determina o tipo sem ambiguidade. Ainda assim isso é DERIVAÇÃO, não texto
  literal do item: a ficha mostra a moeda como AVISO, nunca como bloqueio.
  Quem decide é o mestre.
=============================================================================]]

local C = {}

C.TIPO_POR_HUMANIDADE = {
    [0]  = { tipo="Cosmético",       moeda="Eddies Limpos ou Sujos" },
    [-1] = { tipo="Funcional legal", moeda="Eddies Limpos ou Sujos" },
    [-2] = { tipo="Militar/pesado",  moeda="Eddies Sujos (ou Limpos + Etiqueta Corporativa com clearance)" },
    [-3] = { tipo="Black market / ilegal", moeda="Só Eddies Sujos" },
}

--- Aceita o custo com qualquer sinal: fichas antigas gravavam positivo.
function C.tipoDe(humanidade)
    local v = -math.abs(tonumber(humanidade) or 0)
    local t = C.TIPO_POR_HUMANIDADE[v]
    if t == nil then return "—", "consulte o mestre" end
    return t.tipo, t.moeda
end

C.CATEGORIAS = {
    "Interface Neural", "Cyberóptica", "Cyberáudio",
    "Membros Cibernéticos", "Derme/Subdérmico", "Internos",
    "Mercado Negro",
}

--[[
  Campos de cada item:
    nome        como o livro escreve
    categoria   seção da tabela
    efeito      texto do livro, palavra por palavra
    preco       em eddies
    humanidade  custo de Humanidade (negativo, como impresso)
    mecanico    o que a FICHA aplica sozinha (nil = nada é automático).
                Só entra aqui o que é numérico, permanente e incondicional.
                O resto vira texto — é assim que se evita inventar regra.
]]
C.ITENS = {
    -- INTERFACE NEURAL -------------------------------------------------------
    { nome="Interface Neural Básica", categoria="Interface Neural",
      efeito="Plugar em terminais, veículos e sistemas", preco=500, humanidade=-1,
      mecanico=nil, nota="Pré-requisito prático pra netrunning sério (Cap. 10)." },
    { nome="Slot de Chip de Habilidade", categoria="Interface Neural",
      efeito="Chip de perícia temporário: Nível 1 numa perícia enquanto plugado",
      preco=800, humanidade=-1,
      mecanico=nil, nota="O nível concedido pelo chip é temporário — lance como ajuste manual na perícia." },
    { nome="Acelerador de Reflexos", categoria="Interface Neural",
      efeito="+1 REF só pra iniciativa", preco=3000, humanidade=-2,
      mecanico={ iniciativa=1 },
      nota="Atenção ao escopo: é +1 REF SÓ na iniciativa, não no REF geral nem nas perícias de REF." },
    { nome="Interface de Combate", categoria="Interface Neural",
      efeito="Reduz penalidade de múltiplos ataques/turno", preco=4500, humanidade=-2,
      mecanico={ interfaceDeCombate=true },
      nota="Cap. 4: penalidade vira -1 / -3 em vez de -3 / -6." },
    { nome="Black Dragon Chip", categoria="Interface Neural",
      efeito="Acesso a bancos de dados roubados: +2 em Pesquisa & Redes sobre alvos corporativos",
      preco=6000, humanidade=-3,
      mecanico=nil, nota="Marcado como mercado negro na própria tabela do livro." },

    -- CYBERÓPTICA -----------------------------------------------------------
    { nome="Olho Ótico Básico", categoria="Cyberóptica",
      efeito="Substitui olho danificado, visão normal", preco=200, humanidade=0,
      mecanico=nil, nota="Cap. 8: resolve a desvantagem Um Olho Só." },
    { nome="Visão Noturna", categoria="Cyberóptica",
      efeito="Enxerga no escuro sem penalidade", preco=600, humanidade=-1,
      mecanico=nil, nota="Cap. 5: anula a condição Cego (temporário) por luz/escuridão." },
    { nome="Zoom Óptico", categoria="Cyberóptica",
      efeito="+2 em Percepção e Percepção Ativa à distância (além de 10 m)",
      preco=700, humanidade=-1,
      mecanico=nil, nota="O livro não fixa o valor do bônus — é situacional, o mestre define na cena." },
    { nome="Gravador Ocular", categoria="Cyberóptica",
      efeito="Grava tudo que o personagem vê", preco=500, humanidade=0, mecanico=nil },
    { nome="Mira Inteligente (Smartlink)", categoria="Cyberóptica",
      efeito="+1 em todo ataque à distância (Fogo, Arco/Arremesso, Pesadas)",
      preco=2500, humanidade=-2,
      mecanico={ pericia={ cd_fogo=1, cd_arco=1, armas_pesadas=1 } },
      nota="A v2.1 não fixava o valor; a v3.0 fecha em +1 em todo ataque à distância (Apêndice B), e a ficha aplica." },

    -- CYBERÁUDIO ------------------------------------------------------------
    { nome="Implante Auditivo Básico", categoria="Cyberáudio",
      efeito="Restaura audição", preco=200, humanidade=0,
      mecanico=nil, nota="Cap. 8: resolve a desvantagem Surdo." },
    { nome="Amplificador Sonoro", categoria="Cyberáudio",
      efeito="Detecta sons distantes ou sussurros", preco=500, humanidade=-1, mecanico=nil },
    { nome="Filtro de Ruído", categoria="Cyberáudio",
      efeito="Imune a ensurdecimento", preco=600, humanidade=-1, mecanico=nil },
    { nome="Interceptador de Rádio", categoria="Cyberáudio",
      efeito="Escuta frequências de rádio, incl. policiais", preco=900, humanidade=-1, mecanico=nil },

    -- MEMBROS CIBERNÉTICOS --------------------------------------------------
    { nome="Braço Cibernético Padrão", categoria="Membros Cibernéticos",
      efeito="Substitui membro perdido, função normal", preco=1500, humanidade=-1,
      mecanico=nil, nota="Cap. 8: resolve a desvantagem Membro Amputado." },
    { nome="Braço de Combate", categoria="Membros Cibernéticos",
      efeito="+1 no Bonus de Dano corpo a corpo; lamina retratil 1d6+Bonus", preco=5000, humanidade=-2,
      mecanico={ bonusDano=1,
                 armaEmbutida={ nome="Lâmina Retrátil", dano="1d6+COR", tipo="corpoArmado" } },
      nota="A v2.1 escrevia só \"+dano corpo a corpo\"; a v3.0 fixa em +1 no Bônus de Dano (Apêndice B). A lâmina fica escondida e sempre com você." },
    { nome="Perna Reforçada", categoria="Membros Cibernéticos",
      efeito="+2 em Atletismo; salto com o dobro da distância", preco=3500, humanidade=-2,
      mecanico={ pericia={ atletismo=2 } },
      nota="Cap. 8: resolve a desvantagem Manco. A v3.0 fecha o bônus em +2 em Atletismo (Apêndice B); o salto dobrado é narrativo." },
    { nome="Garras Retráteis (Mantis Blades)", categoria="Membros Cibernéticos",
      efeito="Arma corpo a corpo embutida, 2d6+COR", preco=6000, humanidade=-3,
      mecanico={ armaEmbutida={ nome="Garras Retráteis", dano="2d6+COR", tipo="corpoArmado" } },
      nota="Mesmo dado da Katana/Espada, mas sempre com você e sem chamar atenção." },
    { nome="Chassi Reforçado Completo", categoria="Membros Cibernéticos",
      efeito="+1 COR, +2 RD natural permanente", preco=15000, humanidade=-3,
      mecanico={ bonusAtributo={ cor=1 }, rdNatural=2 },
      nota="A v2.1 escrevia \"+RD natural permanente\" sem número; a v3.0 fixa em +2 (Apêndice B). A RD de implante SOMA à armadura vestida (Cap. 4)." },

    -- DERME/SUBDÉRMICO ------------------------------------------------------
    { nome="Placas Subdérmicas Leves", categoria="Derme/Subdérmico",
      efeito="+1 RD", preco=2000, humanidade=-1,
      mecanico={ rdNatural=1 } },
    { nome="Placas Subdérmicas Pesadas", categoria="Derme/Subdérmico",
      efeito="+2 RD", preco=4500, humanidade=-2,
      mecanico={ rdNatural=2 } },
    { nome="Camuflagem Dérmica", categoria="Derme/Subdérmico",
      efeito="+2 em Furtividade", preco=3000, humanidade=-2,
      mecanico={ pericia={ furtividade=2 } },
      nota="A v3.0 fecha o bônus em +2 em Furtividade (Apêndice B), e a ficha aplica." },
    { nome="Selante de Feridas", categoria="Derme/Subdérmico",
      efeito="Auto-estabiliza ao cair com PV 0", preco=2500, humanidade=-1,
      mecanico={ autoEstabiliza=true },
      nota="Cap. 11: faz a estabilização automaticamente, sem teste. Cap. 5: também estanca Sangramento." },

    -- INTERNOS --------------------------------------------------------------
    { nome="Biomonitor", categoria="Internos",
      efeito="Alerta de sinais vitais (próprios e de aliados)", preco=300, humanidade=0, mecanico=nil },
    { nome="Filtro Toxicológico", categoria="Internos",
      efeito="Neutraliza Envenenado automaticamente", preco=1200, humanidade=-1,
      mecanico={ imuneEnvenenado=true }, nota="Cap. 5: remove a condição Envenenado sem teste." },
    { nome="Glândula de Adrenalina Sintética", categoria="Internos",
      efeito="Enquanto Ferido (PV <= metade): +2 COR e Atletismo, +1 no Bonus de Dano",
      preco=2800, humanidade=-2,
      mecanico=nil, nota="Condicional e temporário — fica como texto, o mestre aplica na cena." },
    { nome="Pulmões Reforçados", categoria="Internos",
      efeito="Prende a respiração mais tempo, resiste a gases", preco=1500, humanidade=-1, mecanico=nil },

    -- MERCADO NEGRO (só Eddies Sujos) ---------------------------------------
    { nome="Black ICE Neural", categoria="Mercado Negro",
      efeito="Retalia contra netrunners invasores: 2d6 neurais em quem falhar ao te invadir",
      preco=10000, humanidade=-3,
      mecanico=nil, nota="Cap. 10: relevante em Combate Virtual." },
    { nome="Núcleo de Sobrecarga", categoria="Mercado Negro",
      efeito="1x/cena: +4 COR e REF por 3 rodadas; depois 2d6 ignorando RD e Exausto",
      preco=7000, humanidade=-3,
      mecanico=nil, nota="O livro não quantifica nem o bônus nem o dano — é da mesa." },
    { nome="Borgware Militar Roubado", categoria="Mercado Negro",
      efeito="Braco + chassi militar sem licenca: +1 COR, +2 RD, +1 no Bonus de Dano",
      preco=12000, humanidade=-3,
      mecanico={ bonusAtributo={ cor=1 }, rdNatural=2, bonusDano=1 },
      nota="Rastreável por quem o perdeu. Valores fixados na v3.0 (Apêndice B) — a v2.1 só descrevia a peça." },
}

--- Itens de uma categoria, na ordem do livro.
function C.daCategoria(categoria)
    local out = {}
    for _, it in ipairs(C.ITENS) do
        if it.categoria == categoria then out[#out + 1] = it end
    end
    return out
end

function C.porNome(nome)
    for _, it in ipairs(C.ITENS) do
        if it.nome == nome then return it end
    end
    return nil
end

return C
