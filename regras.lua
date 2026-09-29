--[[===========================================================================
  NIGHT CITY NOIR — regras.lua
  Fórmulas puras do sistema. NÃO depende de `self`, `sheet`, NDB ou Firecast:
  roda com `lua5.3` puro, o que permite testar tudo em segundos.

  REGRA DE OURO DESTE ARQUIVO: toda função cita o texto do livro que a origina.
  Se você mudar uma fórmula sem trocar a citação, o próximo a ler vai confiar
  na citação e errar.

  Referência: Night City Noir — Livro do Jogador v2.1
=============================================================================]]

local R = {}

R.VERSAO_LIVRO = "v3.0"

--[[---------------------------------------------------------------------------
  ATRIBUTOS — Cap. 2
  "ATRIBUTO | SIGLA | CUSTO/PT
   Corpo    | COR | 6 | Força física, dano corpo a corpo, resistir dano
   Reflexos | REF | 8 | Combate à distância, furtividade, pilotagem, iniciativa
   Mente    | MEN | 7 | Perícias técnicas, hacking, cyberpsicose, percepção
   Vontade  | VON | 5 | Resistir medo/coação, presença"
-----------------------------------------------------------------------------]]

R.ATRIBUTOS = {
    -- `cor` é a cor de tela do atributo, não regra: mora aqui para que a
    -- identidade visual de COR/REF/MEN/VON seja a mesma em toda a ficha.
    { chave = "cor", sigla = "COR", nome = "Corpo",    custoPorPonto = 6, cor = "#FF3B7F",
      usadoPara = "Força física, dano corpo a corpo, resistir dano" },
    { chave = "ref", sigla = "REF", nome = "Reflexos", custoPorPonto = 8, cor = "#23E5D3",
      usadoPara = "Combate à distância, furtividade, pilotagem, iniciativa" },
    { chave = "men", sigla = "MEN", nome = "Mente",    custoPorPonto = 7, cor = "#8A63C9",
      usadoPara = "Perícias técnicas, hacking, cyberpsicose, percepção" },
    { chave = "von", sigla = "VON", nome = "Vontade",  custoPorPonto = 5, cor = "#FFB03A",
      usadoPara = "Resistir medo/coação, presença" },
}

-- "Faixa normal: 7 a 16. Média humana = 10." (Cap. 2)
-- "Piso de 7 — sem exceções. Atributos nunca vão abaixo de 7 por compra de
--  pontos, ponto final." (Cap. 2, caixa de aviso)
R.ATRIBUTO_MIN  = 7
R.ATRIBUTO_MAX  = 16
R.ATRIBUTO_BASE = 10

-- =========================================================================
-- BÔNUS DE DANO CORPO A CORPO — Cap. 2 do Livro do Jogador v3.0
--
--   COR    7    8    9   10   11-12   13-14   15-16
--   Bônus -3   -2   -1   +0     +1      +2      +3
--
-- Esta tabela NÃO existia na v2.1 do livro. Sem ela, "1d6+COR" e "2d6+COR"
-- das tabelas de arma (Cap. 9) não tinham significado: a ficha mandava a
-- string literal para a macro /d, e o chat recebia "/d 2d6+COR 4 Katana".
-- "+COR" significa "+ o Bônus desta tabela", NUNCA o valor do atributo.
--
-- Faixas fora de 7..16 são fixadas nas pontas: um NPC com COR 20 continua
-- com +3, porque o livro não imprime nada além de 16 e inventar seria
-- inventar regra.
-- =========================================================================
R.BONUS_DANO = { [7] = -3, [8] = -2, [9] = -1, [10] = 0,
                 [11] = 1, [12] = 1, [13] = 2, [14] = 2, [15] = 3, [16] = 3 }

function R.bonusDano(cor)
    local v = math.floor(tonumber(cor) or R.ATRIBUTO_BASE)
    if v < R.ATRIBUTO_MIN then v = R.ATRIBUTO_MIN end
    if v > R.ATRIBUTO_MAX then v = R.ATRIBUTO_MAX end
    return R.BONUS_DANO[v] or 0
end

--- Resolve o dado impresso na tabela de armas num dado que a macro entende.
--  "2d6+COR" com COR 14 vira "2d6+2"; com COR 10 vira "2d6"; com COR 7 vira
--  "2d6-3". "+REF" da Faca de Arremesso também usa o Bônus de COR (Cap. 2 e
--  Apêndice B, item 2): é o braço que impulsiona, REF já governa a pontaria.
--  Qualquer outro dado passa intacto.
function R.dadoComBonus(dado, bonus)
    local s = tostring(dado or "1d6")
    if not s:find("COR") and not s:find("REF") then return s end
    local base = s:gsub("%s*%+%s*COR", ""):gsub("%s*%+%s*REF", "")
    local b    = math.floor(tonumber(bonus) or 0)
    if b == 0 then return base end
    return base .. R.comSinal(b)
end

--- Atalho para quem só tem a COR na mão (testes e NPCs). A ficha usa
--  R.dadoComBonus com o bônus já somado ao cyberware.
function R.dadoResolvido(dado, cor)
    return R.dadoComBonus(dado, R.bonusDano(cor))
end

--[[---------------------------------------------------------------------------
  ATAQUE ENGANOSO — Cap. 4, pág. 11-A (novo na v3.2)

  "Você abre mão de precisão pra fechar o espaço de defesa do alvo. Declare
   antes de rolar, e a troca é fixa: cada −2 que você tira do seu Valor-Alvo
   tira −1 da Reação dele."

  As três regras finas da mesma página, e as três importam:
    · "Não empilha com Rajada na mesma rolagem."
    · "Não reduz a Reação abaixo de 3."
    · "Vale para qualquer ataque — corpo a corpo, à distância ou arremesso."

  O −6 é o limite impresso: a tabela para ali.
-----------------------------------------------------------------------------]]
R.ENGANOSO_MAX = -6

-- Os três degraus impressos, mais o "sem manobra". Viram o combo da ficha.
R.ENGANOSO_OPCOES = {
    { chave=0,  nome="—" },
    { chave=-2, nome="−2  ·  alvo perde 1 da Reação" },
    { chave=-4, nome="−4  ·  alvo perde 2" },
    { chave=-6, nome="−6  ·  alvo perde 3 (limite)" },
}

--- Devolve a penalidade aplicada e quanto a Reação do alvo cai.
--  `troca` é o que o jogador escolheu tirar do próprio alvo: 0, -2, -4 ou -6.
function R.ataqueEnganoso(troca, reacaoAlvo)
    local t = math.floor(tonumber(troca) or 0)
    if t > 0 then t = -t end
    if t < R.ENGANOSO_MAX then t = R.ENGANOSO_MAX end
    -- só passos de 2 valem; 3 não compra 1,5
    t = -math.floor(math.abs(t) / 2) * 2
    local corte = math.floor(math.abs(t) / 2)

    local reacao = tonumber(reacaoAlvo)
    if reacao ~= nil then
        local nova = math.floor(reacao) - corte
        -- "Não reduz a Reação abaixo de 3. Ninguém fica indefeso por manobra."
        if nova < 3 then
            nova = 3
            corte = math.floor(reacao) - 3
            if corte < 0 then corte = 0 end
        end
        return t, corte, nova
    end
    return t, corte, nil
end

--[[---------------------------------------------------------------------------
  DANO AMBIENTAL — Cap. 5, pág. 13-A (novo na v3.2)

  "Night City mata de queda, de fumaça e de calor tanto quanto de bala."

  A regra de RD da página, e ela tem uma exceção física:
    "É a mesma lógica que o Cap. 5 já usa em Envenenado e Em Chamas: armadura
     para impacto. A queda é a exceção, e por um motivo físico: até 6 metros o
     corpo absorve, acima disso a armadura não ajuda mais."
-----------------------------------------------------------------------------]]
R.AMBIENTE = {
    queda        = { nome="Queda",                    dado="1d6 a cada 3 m",
                     ignoraRd="acima de 6 m",
                     escape="Atletismo reduz em 1d6 se houver o que agarrar. Perna Reforçada ignora os 3 primeiros metros." },
    asfixia      = { nome="Afogamento · asfixia",     dado="1d6 por rodada", ignoraRd=true,
                     escape="Aguenta COR ÷ 2 rodadas antes de começar. Pulmões Reforçados multiplicam esse tempo por 4." },
    fogo         = { nome="Fogo ambiente · eletricidade", dado="2d6 por rodada", ignoraRd=true,
                     escape="Ação dedicada para sair, apagar, ou água. Mesmo dano da condição Em Chamas." },
    temperatura  = { nome="Frio ou calor extremo",    dado="—", ignoraRd=false,
                     escape="Teste de COR por cena de exposição. Falhou, fica Exausto — e acumula uma cena após a outra." },
    fumaca       = { nome="Fumaça densa · gás",       dado="1d6 por rodada", ignoraRd=true,
                     escape="Filtro Toxicológico anula. Prender a respiração adia, mas não cancela." },
    esmagamento  = { nome="Esmagamento · desabamento", dado="3d6", ignoraRd=false,
                     escape="Reação para sair da área: sucesso reduz à metade, como área." },
}

R.AMBIENTE_ORDEM = { "queda", "asfixia", "fogo", "temperatura", "fumaca", "esmagamento" }

--- Dano de queda: 1d6 a cada 3 m, e a RD só conta até 6 m.
function R.quedaDe(metros, temPernaReforcada)
    local m = tonumber(metros) or 0
    if temPernaReforcada then m = m - 3 end     -- "ignora os 3 primeiros metros"
    if m < 0 then m = 0 end
    local dados = math.floor(m / 3)
    if dados < 0 then dados = 0 end
    local usaRd = (tonumber(metros) or 0) <= 6
    return dados, usaRd
end

--- Custo em pontos de um atributo.
--  "Custo = (Valor − 10) × custo/pt. Baixar abaixo de 10 devolve pontos pela
--   METADE do valor de subir a mesma distância (arredondado pra baixo)." (Cap. 2)
--
--  ATENÇÃO — "arredondado pra baixo" aqui é sobre o TAMANHO do reembolso, não
--  sobre a reta numérica. Conferido contra a tabela impressa do Cap. 2:
--    MEN 7 → −3 × 7 = −21 ÷ 2 = −10,5 → o livro imprime −10 (e não −11)
--    VON 9 → −1 × 5 =  −5 ÷ 2 =  −2,5 → o livro imprime  −2 (e não  −3)
--  Ou seja: reembolso = floor(|diff| × custo ÷ 2), devolvido como negativo.
--  Usar math.floor no número já negativo dá 1 ponto a mais de reembolso em
--  4 células da tabela — foi exatamente o bug da versão anterior da ficha.
function R.custoAtributo(valor, custoPorPonto)
    local v    = tonumber(valor) or R.ATRIBUTO_BASE
    local cpp  = tonumber(custoPorPonto) or 0
    local diff = v - R.ATRIBUTO_BASE
    if diff >= 0 then
        return diff * cpp
    end
    return -math.floor((-diff) * cpp / 2)
end

--- Custo de um atributo pela chave ("cor", "ref", "men", "von").
function R.custoAtributoPorChave(chave, valor)
    for _, a in ipairs(R.ATRIBUTOS) do
        if a.chave == chave then return R.custoAtributo(valor, a.custoPorPonto) end
    end
    return 0
end

--- Texto de auditoria do custo — "mostre a conta, não só o resultado".
function R.contaCustoAtributo(chave, valor)
    local v, cpp = tonumber(valor) or R.ATRIBUTO_BASE, 0
    for _, a in ipairs(R.ATRIBUTOS) do
        if a.chave == chave then cpp = a.custoPorPonto end
    end
    local diff = v - R.ATRIBUTO_BASE
    if diff == 0 then return "valor base 10 — custo zero" end
    if diff > 0 then
        return string.format("(%d − 10) × %d = %d", v, cpp, diff * cpp)
    end
    return string.format("(10 − %d) × %d ÷ 2 = %d (devolve metade)",
                         v, cpp, R.custoAtributo(v, cpp))
end

--[[---------------------------------------------------------------------------
  PERÍCIAS — Cap. 3 e Cap. 1
-----------------------------------------------------------------------------]]

-- "Custo progressivo — NÍVEL 0/1/2/3/4 · Custo cumulativo 0*/3/8/15/25
--  *Nível 0 aplica -3 de penalidade se tentado mesmo assim." (Cap. 3)
R.CUSTO_PERICIA = { [0] = 0, [1] = 3, [2] = 8, [3] = 15, [4] = 25 }
R.PERICIA_NIVEL_MAX = 4
R.PENALIDADE_NIVEL_ZERO = -3

--- Custo cumulativo de comprar uma perícia até `nivel` do zero.
function R.custoPericia(nivel)
    local n = math.floor(tonumber(nivel) or 0)
    if n < 0 then n = 0 end
    if n > R.PERICIA_NIVEL_MAX then n = R.PERICIA_NIVEL_MAX end
    return R.CUSTO_PERICIA[n]
end

--- Custo de EVOLUIR de um nível para outro em jogo.
--  "Perícias: paga só a diferença entre níveis: 0→1: 3 · 1→2: 5 · 2→3: 7 ·
--   3→4: 10" (Cap. 13). Confere com a tabela cumulativa: 3, 8−3, 15−8, 25−15.
function R.custoEvoluirPericia(de, para)
    return R.custoPericia(para) - R.custoPericia(de)
end

-- Modificador que a perícia soma no Valor-Alvo — Cap. 3 do livro v3.0.
--
--   Nível     0     1     2     3     4
--   Modif.   -3    +0    +1    +2    +3
--
-- REGRA DA MESA, confirmada pelo mestre em 12/08/2026:
--   "O nível 1 só zera o modificador negativo. O jogador só ganha +1 a partir
--    do nível 2, e vai até no máximo +3 no nível 4."
--
-- Ou seja: NÍVEL 1 PAGA PELO DIREITO DE ROLAR SEM PENALIDADE, não por um bônus.
-- O bônus é `nivel - 1`, e o nível 0 é o caso à parte, com -3.
--
-- ERRO MEU, corrigido aqui: a v2.0 desta ficha trocou `nivel - 1` por `nivel`,
-- lendo "Valor-Alvo = Atributo + Nível da Perícia" (Cap. 1) ao pé da letra e
-- tratando o `n-1` da v1 como bug. A v1 estava certa. A frase do Cap. 1 é uma
-- fórmula-resumo, não a tabela — e a tabela é quem manda. Toda perícia treinada
-- ficou 1 ponto fácil demais entre a v2.0 e a v2.4.
function R.modificadorPericia(nivel)
    local n = math.floor(tonumber(nivel) or 0)
    if n <= 0 then return R.PENALIDADE_NIVEL_ZERO end
    if n > R.PERICIA_NIVEL_MAX then n = R.PERICIA_NIVEL_MAX end
    return n - 1
end

--- Valor-Alvo de um teste. "Valor-Alvo = Atributo + Nível da Perícia +
--  Modificadores" (Cap. 1)
function R.valorAlvo(atributo, nivelPericia, modificadores)
    return (tonumber(atributo) or R.ATRIBUTO_BASE)
         + R.modificadorPericia(nivelPericia)
         + (tonumber(modificadores) or 0)
end

--[[---------------------------------------------------------------------------
  RESULTADO DE UM TESTE 3d6 — Cap. 1
  "3 ou 4            → Sucesso Crítico (sempre sucede)
   5 até o Valor-Alvo → Sucesso normal
   Valor-Alvo+1 a 16  → Falha normal
   17                 → Falha — crítica se o Valor-Alvo for menor que 15
   18                 → Falha Crítica (sempre falha)"
  "Margem = Valor-Alvo − resultado rolado."
-----------------------------------------------------------------------------]]

function R.interpretarTeste(rolado, alvo)
    local r = tonumber(rolado) or 0
    local a = tonumber(alvo) or 0
    local margem = a - r
    if r <= 4 then
        return "critico",       "Sucesso Crítico", margem
    elseif r == 18 then
        return "falhaCritica",  "Falha Crítica",   margem
    elseif r == 17 then
        if a < 15 then return "falhaCritica", "Falha Crítica", margem end
        return "falha",         "Falha",           margem
    elseif r <= a then
        return "sucesso",       "Sucesso",         margem
    end
    return "falha",             "Falha",           margem
end

--[[---------------------------------------------------------------------------
  ATRIBUTOS DERIVADOS — Cap. 2, "Atributos derivados (de graça)"
   Pontos de Vida (PV)      COR × 2
   Percepção                = MEN
   Velocidade Básica        (REF + COR) ÷ 4, arred. p/ baixo
   Esquiva                  Velocidade Básica + 3
   Humanidade               10 − custo total de cyberware (Cap. 6)
   Foco Neural (netrunners) MEN × 2

  NOTA sobre a Referência Rápida (p. 28): ela imprime "(REF+COR)+4" para
  Velocidade Básica. É erro de composição da página — o Cap. 2 escreve
  "÷ 4, arred. p/ baixo", e "arredondar para baixo" só faz sentido numa
  divisão. A ficha segue o Cap. 2.
-----------------------------------------------------------------------------]]

function R.pontosDeVida(cor, ajuste)
    return (tonumber(cor) or R.ATRIBUTO_BASE) * 2 + (tonumber(ajuste) or 0)
end

function R.percepcao(men, ajuste)
    return (tonumber(men) or R.ATRIBUTO_BASE) + (tonumber(ajuste) or 0)
end

function R.velocidadeBasica(ref, cor, ajuste)
    local base = math.floor(((tonumber(ref) or R.ATRIBUTO_BASE)
                           + (tonumber(cor) or R.ATRIBUTO_BASE)) / 4)
    return base + (tonumber(ajuste) or 0)
end

function R.esquiva(velBasica, ajuste)
    return (tonumber(velBasica) or 0) + 3 + (tonumber(ajuste) or 0)
end

function R.focoNeural(men, ajuste)
    return (tonumber(men) or R.ATRIBUTO_BASE) * 2 + (tonumber(ajuste) or 0)
end

--- Humanidade. Cap. 2: "10 − custo total de cyberware (Cap. 6)".
--  No Cap. 6 os custos já vêm NEGATIVOS (0, −1, −2, −3), então a soma é somada
--  a 10, não subtraída. A ficha guarda sempre o número como o livro imprime.
--  `ajuste` cobre a desvantagem "Cyberpsicose Latente — Humanidade inicial
--  2 pts mais baixa" (Cap. 8) e correções do mestre.
R.HUMANIDADE_BASE = 10
function R.humanidade(somaCustosCyberware, ajuste)
    return R.HUMANIDADE_BASE + (tonumber(somaCustosCyberware) or 0)
                             + (tonumber(ajuste) or 0)
end

-- "Humanidade baixa (5 ou menos): o mestre pode pedir teste de VON em momentos
--  de estresse extremo pra evitar um episódio de Cyberpsicose em Combate."
-- "Humanidade 0: o personagem perde o controle."
R.HUMANIDADE_ALERTA = 5
function R.estadoHumanidade(h)
    local v = tonumber(h) or R.HUMANIDADE_BASE
    if v <= 0 then
        return "critico", "Humanidade 0 — perde o controle: vira NPC hostil ou sai da narrativa (Cap. 6)"
    elseif v <= R.HUMANIDADE_ALERTA then
        return "alerta",  "Humanidade baixa — o mestre pode pedir VON contra Cyberpsicose em estresse extremo (Cap. 6)"
    end
    return "ok", ""
end

--[[---------------------------------------------------------------------------
  COMBATE — Cap. 4
-----------------------------------------------------------------------------]]

-- "Iniciativa: ordem de ação = maior Velocidade Básica primeiro
--  (empates por maior REF)."
function R.iniciativa(velBasica, ref)
    return (tonumber(velBasica) or 0), (tonumber(ref) or 0)
end

--- Redução de Dano efetiva do alvo.
--  "Perfurante: armas com o traço Perfurante (sniper, arma militar, carga
--   explosiva) ignoram METADE da RD do alvo (arredondado pra baixo) antes de
--   aplicar o restante. Dano final = Dano rolado − (RD ÷ 2)" (Cap. 4)
--  "Cabeça: Ignora ½ RD (compõe com Perfurante)" (Cap. 4, Tiro Certeiro)
--  "Cabeça + Perfurante: RD é dividida por 2 duas vezes em sequência
--   (não somado) — RD 6 → 3 → 1, nunca 0." (Cap. 4)
function R.rdEfetiva(rd, perfurante, naCabeca)
    local v = math.floor(tonumber(rd) or 0)
    if v <= 0 then return 0 end
    local metades = 0
    if perfurante then metades = metades + 1 end
    if naCabeca   then metades = metades + 1 end
    if metades == 0 then return v end
    for _ = 1, metades do v = math.floor(v / 2) end
    -- "nunca 0": o alvo blindado nunca fica sem nenhuma proteção.
    if v < 1 then v = 1 end
    return v
end

--- Dano final depois da armadura.
function R.danoFinal(danoRolado, rd, perfurante, naCabeca)
    local d = (tonumber(danoRolado) or 0) - R.rdEfetiva(rd, perfurante, naCabeca)
    if d < 0 then d = 0 end
    return d
end

-- "Ataques Múltiplos: 1º —, 2º -3, 3º -6. Limite de 3 ataques por turno."
-- "Interface de Combate (cyberware): reduz essa penalidade pela metade,
--  arredondando para baixo: -1 / -3 em vez de -3 / -6."
R.PENALIDADE_ATAQUES          = { [1] = 0, [2] = -3, [3] = -6 }
R.PENALIDADE_ATAQUES_INTERFACE = { [1] = 0, [2] = -1, [3] = -3 }
R.MAX_ATAQUES_TURNO = 3

function R.penalidadeAtaqueMultiplo(ordinal, temInterfaceDeCombate)
    local n = math.floor(tonumber(ordinal) or 1)
    if n < 1 then n = 1 end
    if n > R.MAX_ATAQUES_TURNO then n = R.MAX_ATAQUES_TURNO end
    local t = temInterfaceDeCombate and R.PENALIDADE_ATAQUES_INTERFACE
                                    or  R.PENALIDADE_ATAQUES
    return t[n]
end

-- "Cobertura: Parcial -2 pra atacar · Pesada -4 pra atacar ·
--  Total: não pode ser atingido direto" (Cap. 4)
R.COBERTURA = {
    { chave = "nenhuma", nome = "Sem cobertura",     mod = 0,  bloqueia = false },
    { chave = "parcial", nome = "Cobertura parcial", mod = -2, bloqueia = false },
    { chave = "pesada",  nome = "Cobertura pesada",  mod = -4, bloqueia = false },
    { chave = "total",   nome = "Cobertura total",   mod = 0,  bloqueia = true  },
}

-- "Tiro Certeiro: Torso (padrão) — dano normal · Membro -4, ½ Velocidade ou
--  solta item · Cabeça -6, ignora ½ RD (compõe com Perfurante)" (Cap. 4)
R.ALVO_CORPO = {
    { chave = "torso",  nome = "Torso (padrão)", mod = 0,  efeito = "Dano normal" },
    { chave = "membro", nome = "Membro",         mod = -4, efeito = "½ Velocidade ou solta item" },
    { chave = "cabeca", nome = "Cabeça",         mod = -6, efeito = "Ignora ½ RD (compõe com Perfurante)" },
}

-- "Alcance — sem régua: o mestre define curta/média/longa pela cena." (Cap. 9)
R.FAIXAS_ALCANCE = {
    { chave = "curta", nome = "Curta (10m)"  },
    { chave = "media", nome = "Média (10-30m)" },
    { chave = "longa", nome = "Longa (30m+)"  },
}

-- "Ataque Furtivo: teste de Furtividade vs Percepção do alvo. Sucesso: +4 no
--  ataque, dado de dano extra, sem Esquiva. A cada vez que o MESMO ALVO sofre
--  isso no mesmo combate, ganha Percepção cumulativa contra novas tentativas:
--  1º —, 2º +2, 3º +4, 4º +6. Reseta ao fim do combate." (Cap. 4)
R.BONUS_ATAQUE_FURTIVO   = 4
R.PERCEPCAO_APOS_FURTIVO = { [1] = 0, [2] = 2, [3] = 4, [4] = 6 }

-- "Fogo de Supressão: gasta o turno, sem dano. Área inteira: cobertura
--  (perde ação) ou age a -4. Sem cobertura: teste de VON ou fica preso no lugar."
R.MOD_FOGO_SUPRESSAO = -4

-- "Derrubado: atacar caído (corpo a corpo) +2. À distância -2. O próprio
--  caído: -4 até gastar ação pra levantar."
R.MOD_ATACAR_CAIDO_CC        = 2
R.MOD_ATACAR_CAIDO_DISTANCIA = -2
R.MOD_ESTANDO_CAIDO          = -4

-- "Atordoado / Ofuscado: perde a Esquiva na próxima rolagem de defesa e sofre
--  -4 em qualquer teste até o fim da próxima rodada."
R.MOD_ATORDOADO = -4

--[[---------------------------------------------------------------------------
  CONDIÇÕES E ESTADOS — Cap. 5
  `modTeste` é o modificador que a ficha soma nos testes automaticamente.
  Onde o efeito é dano ou é condicional demais, `modTeste` fica 0 e o texto
  explica — automatizar o que é condicional é como se inventa regra.
-----------------------------------------------------------------------------]]

R.CONDICOES = {
    { chave="sangramento", nome="Sangramento", modTeste=0,
      gatilho="Crítico (margem 6+) ou arma Sangrenta",
      efeito="1 PV/rodada",
      remove="Primeiros Socorros (teste simples) ou Selante de Feridas" },
    { chave="cyberpsicose", nome="Cyberpsicose em Combate", modTeste=0,
      gatilho="Falha em VON vs cyberpsicose",
      efeito="1d6 rodadas atacando o mais próximo, +2 dano, sem Esquiva",
      remove="Tempo, ou Persuasão -6 de um aliado" },
    { chave="amedrontado", nome="Amedrontado", modTeste=-2,
      gatilho="Falha em VON vs medo/intimidação/supressão",
      efeito="-2 geral",
      remove="Fonte sai de cena, ou nova VON bem-sucedida" },
    { chave="envenenado", nome="Envenenado", modTeste=-2,
      gatilho="Veneno, gás, toxina",
      efeito="1d6/rodada (ignora RD) · -2 físico",
      remove="Medicina, ou Filtro Toxicológico (auto)" },
    { chave="cego", nome="Cego (temporário)", modTeste=-2,
      gatilho="Flashbang, spray, luz forte",
      efeito="-6 à distância / -2 corpo a corpo",
      remove="Tempo (1 rodada+), ou Visão Noturna/Cyberóptica anula" },
    { chave="emChamas", nome="Em Chamas", modTeste=0,
      gatilho="Arma incendiária, explosão, ambiente",
      efeito="2d6/rodada (ignora RD)",
      remove="Ação dedicada, ou água/lama" },
    { chave="imobilizado", nome="Imobilizado", modTeste=0,
      gatilho="Perder Agarrar, rede, amarras",
      efeito="Só pode tentar se soltar",
      remove="Teste de escape, ou aliado libera" },
    { chave="exausto", nome="Exausto", modTeste=-2,
      gatilho="Esforço extremo sustentado",
      efeito="-2 Atletismo/Combate/Pilotagem",
      remove="Cena completa de descanso" },
    { chave="atordoado", nome="Atordoado / Ofuscado", modTeste=-4,
      gatilho="Flashbang, atingir a cabeça sem cair, falha crítica de Percepção",
      efeito="Perde a Esquiva na próxima defesa; -4 em qualquer teste até o fim da próxima rodada",
      remove="Fim da próxima rodada" },
}

--- Soma dos modificadores das condições ativas.
--  `ativas` é uma tabela {chave = true}.
function R.modificadorDeCondicoes(ativas)
    if type(ativas) ~= "table" then return 0, {} end
    local total, nomes = 0, {}
    for _, c in ipairs(R.CONDICOES) do
        if ativas[c.chave] then
            total = total + c.modTeste
            if c.modTeste ~= 0 then
                nomes[#nomes + 1] = string.format("%s %+d", c.nome, c.modTeste)
            else
                nomes[#nomes + 1] = c.nome
            end
        end
    end
    return total, nomes
end

--[[---------------------------------------------------------------------------
  RIQUEZA — Cap. 7
  "*% livre = quanto da renda mensal sobra depois do próprio custo de vida do
   status; o resto é patrimônio 'preso' (imóvel, aparências), existe na ficha
   mas não vira eddies soltos."
-----------------------------------------------------------------------------]]

R.RIQUEZA = {
    { chave="miseria",     nome="Miséria",        custo=-20, eddiesIniciais=400,   rendaMensal=100,   pctLivre=100 },
    { chave="pobreza",     nome="Pobreza",        custo=-10, eddiesIniciais=1000,  rendaMensal=250,   pctLivre=100 },
    { chave="classeMedia", nome="Classe Média",   custo=0,   eddiesIniciais=2000,  rendaMensal=500,   pctLivre=90,  padrao=true },
    { chave="confortavel", nome="Confortável",    custo=10,  eddiesIniciais=4000,  rendaMensal=1000,  pctLivre=80 },
    { chave="rico",        nome="Rico",           custo=20,  eddiesIniciais=10000, rendaMensal=2500,  pctLivre=60 },
    { chave="muitoRico",   nome="Muito Rico",     custo=30,  eddiesIniciais=20000, rendaMensal=5000,  pctLivre=40 },
    { chave="podreDeRico", nome="Podre de Rico",  custo=50,  eddiesIniciais=50000, rendaMensal=12500, pctLivre=25 },
}

function R.riquezaPorChave(chave)
    for _, t in ipairs(R.RIQUEZA) do
        if t.chave == chave then return t end
    end
    return R.RIQUEZA[3] -- Classe Média é o padrão do livro
end

--- Renda líquida mensal: parte da renda que vira eddies soltos.
function R.rendaLivre(chaveRiqueza)
    local t = R.riquezaPorChave(chaveRiqueza)
    return math.floor(t.rendaMensal * t.pctLivre / 100)
end

--[[---------------------------------------------------------------------------
  ORÇAMENTO DE CRIAÇÃO — Cap. 14
  "80 pontos base, até 120 com Desvantagens (máx. +40, sugestão de até 4
   desvantagens)."
  "Distribua entre Atributos (Cap. 2), Perícias (Cap. 3) e Vantagens (Cap. 8)
   — guia solto: ~30/~30/~20 pts"
-----------------------------------------------------------------------------]]

R.PONTOS_BASE                = 80
R.TETO_RETORNO_DESVANTAGENS  = 40
R.SUGESTAO_MAX_DESVANTAGENS  = 4
R.GUIA_DISTRIBUICAO = { atributos = 30, pericias = 30, vantagens = 20 }

--- Orçamento completo. Devolve uma tabela com todas as parcelas, para a ficha
--  poder mostrar a conta linha a linha em vez de só o saldo.
--  `t` = { retornoDesvantagens, xpGanho, ajusteManual,
--          custoAtributos, custoPericias, custoVantagens, custoRiqueza }
function R.orcamento(t)
    t = t or {}
    local retornoBruto = tonumber(t.retornoDesvantagens) or 0
    local retorno      = math.min(retornoBruto, R.TETO_RETORNO_DESVANTAGENS)

    local disponivel = R.PONTOS_BASE
                     + retorno
                     + (tonumber(t.xpGanho)      or 0)
                     + (tonumber(t.ajusteManual) or 0)

    local gasto = (tonumber(t.custoAtributos) or 0)
                + (tonumber(t.custoPericias)  or 0)
                + (tonumber(t.custoVantagens) or 0)
                + (tonumber(t.custoRiqueza)   or 0)

    return {
        base              = R.PONTOS_BASE,
        retornoBruto      = retornoBruto,
        retornoAplicado   = retorno,
        retornoCortado    = retornoBruto > R.TETO_RETORNO_DESVANTAGENS,
        xpGanho           = tonumber(t.xpGanho)      or 0,
        ajusteManual      = tonumber(t.ajusteManual) or 0,
        disponivel        = disponivel,
        custoAtributos    = tonumber(t.custoAtributos) or 0,
        custoPericias     = tonumber(t.custoPericias)  or 0,
        custoVantagens    = tonumber(t.custoVantagens) or 0,
        custoRiqueza      = tonumber(t.custoRiqueza)   or 0,
        gasto             = gasto,
        saldo             = disponivel - gasto,
    }
end

-- XP por sessão — Cap. 13
-- "Participar da sessão 2 · Cumprir o objetivo principal +1 ·
--  Momento marcante de interpretação +1 · Assumir um risco genuíno pelo grupo +1"
-- "Faixa típica: 2 a 5 XP por sessão."
R.XP_SESSAO = {
    { chave="participou",  nome="Participar da sessão",              xp=2 },
    { chave="objetivo",    nome="Cumprir o objetivo principal",      xp=1 },
    { chave="interpretou", nome="Momento marcante de interpretação", xp=1 },
    { chave="risco",       nome="Assumir um risco genuíno pelo grupo", xp=1 },
}

--[[---------------------------------------------------------------------------
  CURA, DESCANSO E MEDTECH — Cap. 11
-----------------------------------------------------------------------------]]

R.RECUPERACAO = {
    { chave="cenaCurta", nome="Cena curta (sem sofrer dano nela)",
      texto="1 PV, uma vez por cena" },
    { chave="descanso",  nome="Descanso completo (uma noite)",
      texto="metade do PV máx. (arred. cima)" },
    { chave="repouso",   nome="Repouso total (3+ dias)",
      texto="PV máximo cheio" },
}

--- Cura de descanso completo: "metade do PV máx. (arred. cima)"
function R.curaDescansoCompleto(pvMaximo)
    return math.ceil((tonumber(pvMaximo) or 0) / 2)
end

-- "Tratamento de Campo (1 carga de Kit): 1d6 (2d6 crítico) + 1 PV extra a cada
--  3 pts de margem. Uma vez por combate, por alvo."
-- "Mão Firme (10 XP): cada 3 pts de margem cura +1 PV extra."
function R.pvExtraPorMargem(margem, temMaoFirme)
    local m = tonumber(margem) or 0
    if m < 0 then return 0 end
    local extra = math.floor(m / 3)
    if temMaoFirme then extra = extra * 2 end
    return extra
end

-- "Estabilização (PV 0): teste de Primeiros Socorros. Sem isso, perde 1 PV
--  adicional/rodada até morrer (limite -COR)."
-- Cap. 4: "PV zerado — testes de VON permitem agir com PV negativo até o
--  limite de -COR."
function R.limiteMorte(cor)
    return -(tonumber(cor) or R.ATRIBUTO_BASE)
end

--[[---------------------------------------------------------------------------
  NETRUNNING — Cap. 10
-----------------------------------------------------------------------------]]

R.SISTEMAS_NET = {
    { chave="domestico",  nome="Doméstico / comercial simples", dificuldade=-2 },
    { chave="corpPadrao", nome="Corporativo padrão",            dificuldade=-4 },
    { chave="corpTier1",  nome="Corporativo Tier 1 / militar",  dificuldade=-6 },
}

R.ICE = {
    { chave="branco", nome="ICE Branco (Alarme)",   dano=nil,       texto="Sem dano — só +1 no Nível de Alerta" },
    { chave="cinza",  nome="ICE Cinza (Supressor)", dano="2d6",     texto="2d6 de dano neural" },
    { chave="preto",  nome="ICE Preto (Letal)",     dano="3d6+2",   texto="3d6+2 de dano neural — se zerar o Foco, role a Tabela de Flatline" },
}

R.ALERTA_MAX = 5
R.ALERTA = {
    { nivel=0, texto="Início — some +1 a cada falha ou ICE Branco" },
    { nivel=3, texto="Segurança física notificada" },
    { nivel=5, texto="Conexão cortada à força, localização rastreada" },
}

function R.consequenciaAlerta(nivel)
    local n = tonumber(nivel) or 0
    if n >= 5 then return R.ALERTA[3].texto end
    if n >= 3 then return R.ALERTA[2].texto end
    return R.ALERTA[1].texto
end

-- "Só quando uma ICE Preta zera o Foco Neural. Role 1d6:"
R.FLATLINE = {
    { faixa="1-2", min=1, max=2, nome="Apagão",
      efeito="Ejetado; -2 em tudo até descanso completo (sem dano físico)" },
    { faixa="3-4", min=3, max=4, nome="Convulsão",
      efeito="2d6 dano físico (ignora RD); incapacitado 1 rodada" },
    { faixa="5",   min=5, max=5, nome="Dano Neural Permanente",
      efeito="3d6 dano físico + perde 1 ponto permanente de MEN" },
    { faixa="6",   min=6, max=6, nome="Flatline",
      efeito="VON rodadas de vida real; sem reanimação (Medicina difícil), morre" },
}

function R.resultadoFlatline(d6)
    local v = tonumber(d6) or 0
    for _, f in ipairs(R.FLATLINE) do
        if v >= f.min and v <= f.max then return f end
    end
    return nil
end

-- "Foco zerado por ICE Branca/Cinza: ejeta o netrunner e aplica -2 em todos os
--  testes até descanso completo." (Cap. 10)
R.MOD_FOCO_ZERADO = -2

-- "Foco Neural se recupera por completo com descanso completo (exceto dano
--  neural permanente de Flatline)." (Cap. 11)

--[[---------------------------------------------------------------------------
  VEÍCULOS E PERSEGUIÇÕES — Cap. 12
-----------------------------------------------------------------------------]]

-- "Hiato 0 = colado (embarcar, atirar sem penal. extra, forçar colisão).
--  Hiato 5 = fugitivo escapou."
R.HIATO_MIN, R.HIATO_MAX = 0, 5

R.TERRENO_PERSEGUICAO = {
    { chave="rodovia",  nome="Rodovia livre",                dificuldade=-2 },
    { chave="urbano",   nome="Trânsito urbano moderado",     dificuldade=-4 },
    { chave="estreito", nome="Ruas estreitas / Combat Zone", dificuldade=-6 },
    { chave="offroad",  nome="Fora de estrada / escombros",  dificuldade=-8 },
}

-- "Cada rodada: os dois rolam /a com REF + Pilotagem + MAN vs Dificuldade do
--  terreno. Maior margem 'ganha' a rodada (Hiato -1 se perseguidor,
--  +1 se fugitivo)."
function R.alvoPerseguicao(ref, nivelPilotagem, manobrabilidade, dificuldadeTerreno)
    return (tonumber(ref) or R.ATRIBUTO_BASE)
         + R.modificadorPericia(nivelPilotagem)
         + (tonumber(manobrabilidade)    or 0)
         + (tonumber(dificuldadeTerreno) or 0)
end

R.CHOQUE = {
    { faixa="1-2", min=1, max=2, texto="Capota/desliza — 2d6 aos ocupantes, veículo imobilizado" },
    { faixa="3-4", min=3, max=4, texto="Colisão feia — 3d6 a todos dentro, veículo destruído" },
    { faixa="5-6", min=5, max=6, texto="Descontrole total — 4d6, mais quem estiver por perto" },
}

function R.resultadoChoque(d6)
    local v = tonumber(d6) or 0
    for _, c in ipairs(R.CHOQUE) do
        if v >= c.min and v <= c.max then return c end
    end
    return nil
end

-- "Combate em Perseguição: atirar de veículo em movimento: -2 + penal. de
--  Hiato. No veículo (não motorista): dano vai pra Estrutura. No motorista:
--  -4 adicional de precisão (a RD do veículo ainda reduz o dano,
--  separadamente). Colisão (Ram): 2d6 + 1d6 a cada 2 pts de diferença de VEL,
--  aplicado à Estrutura de ambos."
R.MOD_ATIRAR_DE_VEICULO   = -2
R.MOD_MIRAR_NO_MOTORISTA  = -4

function R.danoColisao(velA, velB)
    local dif = math.abs((tonumber(velA) or 0) - (tonumber(velB) or 0))
    local extras = math.floor(dif / 2)
    if extras <= 0 then return "2d6" end
    return string.format("2d6 + %dd6", extras)
end

--[[---------------------------------------------------------------------------
  UTILITÁRIOS DE TEXTO
-----------------------------------------------------------------------------]]

--- Conta CARACTERES, não bytes. `#texto` em português erra ~10% por causa do
--  UTF-8 multibyte — descarta os bytes de continuação (10xxxxxx).
function R.contarCaracteres(s)
    s = tostring(s or "")
    local total = 0
    for i = 1, #s do
        local b = s:byte(i)
        if b < 128 or b >= 192 then total = total + 1 end
    end
    return total
end

--- Formata eddies com separador de milhar, como o livro imprime (1.500).
function R.eddies(n)
    local v = math.floor(tonumber(n) or 0)
    local sinal = v < 0 and "-" or ""
    v = math.abs(v)
    local s = tostring(v)
    local out = ""
    while #s > 3 do
        out = "." .. s:sub(-3) .. out
        s = s:sub(1, -4)
    end
    return sinal .. s .. out
end

--- Sinal explícito: 3 vira "+3", -3 vira "-3", 0 vira "0".
function R.comSinal(n)
    local v = tonumber(n) or 0
    if v > 0 then return "+" .. tostring(v) end
    return tostring(v)
end

return R
