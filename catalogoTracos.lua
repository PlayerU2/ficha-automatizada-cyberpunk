--[[===========================================================================
  NIGHT CITY NOIR — catalogoTracos.lua
  Vantagens e Desvantagens do Cap. 8, transcritas linha a linha.

  CATEGORIA DE VANTAGEM (o livro define as três no cabeçalho do capítulo):
    "Criação: ou já nasce com isso, ou nunca mais.
     XP: dá pra desenvolver com treino.
     Narrativa: concedida pelo mestre, fora do orçamento de pontos."

  REGRA DAS CINCO SOCIAIS (caixa do Cap. 8):
    "Fama na Rua, Contato Confiável, Patrono, Aliados e Título/Credencial
     PODEM ser compradas na criação (relações que já existiam antes da
     campanha). Depois disso, NÃO ENTRAM NA LOJA DE XP — só surgem de graça,
     como consequência da história."

  DESVANTAGENS (caixa do Cap. 8):
    "Desvantagens só entram NA CRIAÇÃO. Nenhuma nova pode ser adicionada
     depois que a campanha começa — daí em diante, só é possível REMOVER."
  E o Cap. 13 completa: "Desvantagens só podem ser removidas (nunca
  adicionadas), pagando o dobro do valor original + um arco narrativo que
  resolva de fato."
=============================================================================]]

local T = {}

T.CATEGORIA = {
    criacao  = { chave="criacao",  nome="Criação apenas", cor="#23E5D3",
                 explica="Ou já nasce com isso, ou nunca mais. Não pode ser comprada depois." },
    xp       = { chave="xp",       nome="XP-comprável",   cor="#3DD68C",
                 explica="Dá pra desenvolver com treino, a qualquer momento da campanha." },
    narrativa= { chave="narrativa",nome="Narrativa",      cor="#FFB03A",
                 explica="Concedida pelo mestre, fora do orçamento de pontos." },
    social   = { chave="social",   nome="Criação / Narrativa", cor="#8A63C9",
                 explica="Comprável na criação. Depois, só surge de graça pela história — nunca pela loja de XP." },
}

-- "Depois disso, não entram na loja de XP" (Cap. 8)
T.MULTIPLICADOR_REMOVER_DESVANTAGEM = 2  -- Cap. 13

--[[---------------------------------------------------------------------------
  VANTAGENS — Cap. 8
  `custo` em pontos. Onde o livro imprime faixa (5/10/20 · 10-15), `custoMin`
  e `custoMax` guardam os extremos e a ficha pede o valor ao jogador.
  `mecanico` só existe quando o efeito é numérico, permanente e incondicional.
-----------------------------------------------------------------------------]]

T.VANTAGENS = {
    { nome="Ambidestria",          custo=5,  categoria="criacao",
      efeito="Sem penalidade com a mão não-dominante" },
    { nome="Memória Eidética",     custo=5,  categoria="criacao",
      efeito="Lembra com precisão tudo que viu ou ouviu" },
    { nome="Sentido Aguçado",      custo=5,  categoria="criacao",
      efeito="+2 Percepção num sentido específico",
      nota="É +2 num SENTIDO, não na Percepção geral — por isso não entra no cálculo automático. Some no ajuste quando a cena usar aquele sentido." },
    { nome="Equilíbrio Perfeito",  custo=5,  categoria="criacao",
      efeito="Nunca perde equilíbrio em terreno instável" },
    { nome="Idioma Extra",         custo=5,  categoria="xp",
      efeito="Fala fluente um idioma a mais" },
    { nome="Aparência Atraente",   custo=5,  categoria="criacao",
      efeito="+1 em testes sociais de 1ª impressão",
      nota="Condicional (só 1ª impressão) — fica como texto." },
    { nome="Reflexos Rápidos",     custo=10, categoria="xp",
      efeito="+1 na Velocidade Básica (só iniciativa)",
      mecanico={ iniciativa=1 },
      nota="ESCOPO: é +1 SÓ na iniciativa. Não muda a Esquiva nem o deslocamento, que também saem da Velocidade Básica." },
    { nome="Vontade de Ferro",     custo=10, categoria="xp",
      efeito="+2 em VON vs. medo/coação/cyberpsicose",
      nota="Condicional ao tipo de teste — some no ajuste na hora." },
    { nome="Reconstituição Rápida",custo=10, categoria="xp",
      efeito="Dobra a cura natural de PV em descanso",
      mecanico={ dobraCuraNatural=true }, nota="Cap. 11 confirma: dobra os valores de recuperação natural." },
    { nome="Faro pra Perigo",      custo=10, categoria="xp",
      efeito="Percepção grátis ao entrar numa emboscada" },
    { nome="Carisma",              custo=10, categoria="xp",
      efeito="+2 em Persuasão, Intimidação e Enganação",
      mecanico={ pericia={ persuasao=2, intimidacao=2, enganacao=2 } },
      nota="Numérico, permanente e incondicional — a ficha aplica sozinha nas três perícias nomeadas." },
    { nome="Voz de Comando",       custo=10, categoria="xp",
      efeito="Bônus em Intimidação liderando um grupo",
      nota="Condicional (liderando grupo) e sem valor fixo no livro." },
    { nome="Status Social",        custo=5,  custoMin=5, custoMax=20, escalonado={5,10,20}, categoria="criacao",
      efeito="NPCs de status igual/menor te respeitam",
      nota="O livro imprime 5/10/20 — escolha o degrau com o mestre." },
    { nome="Sorte",                custo=15, categoria="criacao",
      efeito="1x/sessão, re-rola um teste e fica com o novo" },
    { nome="Alto Limiar de Dor",   custo=15, categoria="criacao",
      efeito="Ignora penal. de ferimento até metade do PV" },
    { nome="Imunidade Parcial à Cyberpsicose", custo=20, categoria="xp",
      efeito="+4 (em vez de só VON) contra cyberpsicose",
      nota="Cap. 6: o teste de cyberpsicose é de VON. Esta vantagem soma +4 nesse teste específico." },
    { nome="Intuição Combativa",   custo=20, categoria="xp",
      efeito="Age antes da iniciativa normal 1x/combate" },
    { nome="Especialista em Trauma", custo=10, categoria="xp", medtech=true,
      efeito="Estabilizar não gasta ação nem carga de kit",
      nota="Cap. 11 repete com o mesmo custo." },
    { nome="Mão Firme",            custo=10, categoria="xp", medtech=true,
      efeito="Cada 3 pts de margem cura +1 PV extra",
      mecanico={ maoFirme=true }, nota="Cap. 11: dobra o PV extra por margem no Tratamento de Campo." },
    { nome="Cirurgião de Campo",   custo=20, categoria="narrativa", medtech=true,
      efeito="Tenta reverter dano permanente em cirurgia arriscada",
      nota="Cap. 11: teste -4; falha crítica piora." },

    -- AS CINCO SOCIAIS — regra dupla (caixa do Cap. 8)
    { nome="Fama na Rua",       custo=5,  categoria="social",
      efeito="NPCs de rua já reconhecem sua reputação" },
    { nome="Contato Confiável", custo=10, categoria="social",
      efeito="Um NPC dá informação ou fica acionado" },
    { nome="Patrono",           custo=15, categoria="social",
      efeito="NPC poderoso (fixer, exec, líder) ajuda ocasionalmente" },
    { nome="Aliados",           custo=10, custoMin=10, custoMax=15, categoria="social",
      efeito="Um grupo de NPCs pode ser convocado pra ajudar",
      nota="O livro imprime 10-15 — o valor depende do tamanho e da lealdade do grupo." },
    { nome="Título/Credencial", custo=5,  categoria="social",
      efeito="Crachá/identidade que abre acesso restrito" },
}

--[[---------------------------------------------------------------------------
  DESVANTAGENS — Cap. 8
  `retorno` são pontos que VOLTAM pro orçamento (Cap. 14: teto de +40 no total).
  `resolve` é o texto do livro sobre como sair dela.
-----------------------------------------------------------------------------]]

T.DESVANTAGENS = {
    { nome="Maneirismo Chamativo", retorno=5,
      efeito="Dificulta se disfarçar/passar despercebido", resolve="XP (2x) + disciplina" },
    { nome="Baixo Limiar de Dor",  retorno=5,
      efeito="Penalidade de ferimento começa mais cedo", resolve="—" },
    { nome="Intolerância",         retorno=5,
      efeito="Reage mal a um grupo, prejudica social", resolve="XP (2x) + convivência forçada" },
    { nome="Curioso Demais",       retorno=5,
      efeito="Dificuldade em resistir a investigar perigos", resolve="XP (2x) + disciplina" },
    { nome="Sem Noção de Dinheiro",retorno=5,
      efeito="Gasta eddies por impulso", resolve="XP (2x) + disciplina" },
    { nome="Um Olho Só",           retorno=5,
      efeito="-2 Percepção visual à distância/profundidade", resolve="Cyberware (Olho Ótico)",
      nota="Condicional ao sentido — não entra no cálculo automático de Percepção." },
    { nome="Nanismo",              retorno=5,
      efeito="Reduz alcance físico; +1 Furtividade", resolve="—",
      mecanico={ pericia={ furtividade=1 } } },
    { nome="Alergia",              retorno=5, retornoMin=5, retornoMax=10,
      efeito="Reação ruim a uma substância específica", resolve="—",
      nota="O livro imprime 5-10 — a gravidade define o valor." },
    { nome="Manco",                retorno=5,
      efeito="-1 Atletismo e Pilotagem", resolve="Cyberware (Perna Reforçada)",
      mecanico={ pericia={ atletismo=-1, pilot_terrestre=-1, pilot_aerea=-1, conducao_arriscada=-1 } },
      nota="O livro escreve \"Pilotagem\" no singular; a ficha aplica nas três perícias de pilotagem. Se sua mesa entender diferente, é aqui que se mexe." },
    { nome="Código de Honra",      retorno=10,
      efeito="Princípio pessoal que nunca quebra", resolve="XP (2x) + evento que quebra/reconstrói" },
    { nome="Vício",                retorno=10,
      efeito="Depende de substância; penalidade sem ela", resolve="XP (2x) + arco de recuperação" },
    { nome="Pobreza",              retorno=10,
      efeito="Metade dos eddies iniciais", resolve="—",
      mecanico={ metadeEddiesIniciais=true },
      nota="Cap. 7: incide sobre os Eddies Limpos Iniciais do tier de Riqueza." },
    { nome="Fobia",                retorno=10,
      efeito="Pânico/penalidade severa com um gatilho", resolve="XP (2x) + encarar o gatilho em cena" },
    { nome="Cyberpsicose Latente", retorno=10,
      efeito="Humanidade inicial 2 pts mais baixa", resolve="XP (2x) + clínica especializada rara",
      mecanico={ humanidade=-2 },
      nota="Numérico e permanente — a ficha aplica sozinha na Humanidade base." },
    { nome="Rival",                retorno=10,
      efeito="NPC/grupo atrapalha, sem ameaça mortal constante", resolve="Narrativa (reconciliação ou confronto)" },
    { nome="Impulsivo",            retorno=10,
      efeito="Teste de VON pra resistir a agir por impulso", resolve="XP (2x) + consequência grave antes" },
    { nome="Mudo",                 retorno=10,
      efeito="Não fala; testes sociais exigem outro meio", resolve="—" },
    { nome="Fragilidade",          retorno=10,
      efeito="-2 PV máximo", resolve="—",
      mecanico={ pv=-2 },
      nota="Numérico e permanente — entra no PV máximo automaticamente." },
    { nome="Status Social Baixo",  retorno=10,
      efeito="NPCs de status maior te tratam com desdém", resolve="Narrativa (ascensão genuína em jogo)" },
    { nome="Pária",                retorno=10,
      efeito="Um grupo social inteiro não confia em você", resolve="Narrativa (mudança do motivo social)" },
    { nome="Surdo",                retorno=15,
      efeito="Sem audição; -4 Percepção auditiva", resolve="Cyberware (Implante Auditivo)",
      nota="Condicional ao sentido — não entra no cálculo automático de Percepção." },
    { nome="Segredo Grave",        retorno=15,
      efeito="Se descoberto, destrói sua vida ou arrisca aliados", resolve="Narrativa (descoberto ou eliminado quem sabia)" },
    { nome="Dependente",           retorno=15,
      efeito="Alguém pra proteger, pode ser usado contra você", resolve="Narrativa (história do NPC evolui)" },
    { nome="Marcado",              retorno=15,
      efeito="Fisicamente identificável de forma única", resolve="Narrativa (raramente muda)" },
    { nome="Membro Amputado",      retorno=15, retornoMin=15, retornoMax=20,
      efeito="Penalidade severa sem prótese", resolve="Cyberware (Braço/Perna Cibernético)",
      nota="O livro imprime 15-20 — qual membro define o valor." },
    { nome="Cego",                 retorno=25,
      efeito="Sem visão; depende de outros sentidos/cyberóptica", resolve="Cyberware (Olho Ótico/Cyberóptica)" },
    { nome="Inimigo Poderoso",     retorno=20,
      efeito="Corp/gangue/caçador de recompensas persegue ativamente", resolve="Narrativa (neutralizar, derrotar, paz)" },
}

--[[---------------------------------------------------------------------------
  BUSCA E VALIDAÇÃO
-----------------------------------------------------------------------------]]

function T.vantagemPorNome(nome)
    for _, v in ipairs(T.VANTAGENS) do if v.nome == nome then return v end end
    return nil
end

function T.desvantagemPorNome(nome)
    for _, d in ipairs(T.DESVANTAGENS) do if d.nome == nome then return d end end
    return nil
end

--- Pode comprar esta vantagem agora?
--  Devolve (permitido, motivoDaRecusa). O motivo diz POR QUÊ e QUEM LIBERA —
--  uma recusa que só diz "não permitido" é uma ficha que o mestre abandona.
function T.podeComprarVantagem(nome, fichaFinalizada)
    local v = T.vantagemPorNome(nome)
    if v == nil then return true, nil end
    if not fichaFinalizada then return true, nil end

    if v.categoria == "criacao" then
        return false, string.format(
            "\"%s\" é Vantagem de Criação (Cap. 8): ou já nasce com ela, ou nunca mais. "
         .. "Só o mestre pode liberar, destravando a ficha.", v.nome)
    end
    if v.categoria == "social" then
        return false, string.format(
            "\"%s\" é uma das cinco sociais (Cap. 8): comprável na criação, mas depois "
         .. "NÃO entra na loja de XP — só surge de graça, como consequência da história. "
         .. "Peça ao mestre.", v.nome)
    end
    if v.categoria == "narrativa" then
        return false, string.format(
            "\"%s\" é Vantagem Narrativa (Cap. 8): concedida pelo mestre, fora do "
         .. "orçamento de pontos. Não se compra.", v.nome)
    end
    return true, nil   -- categoria "xp": comprável a qualquer momento
end

--- Pode adicionar desvantagem agora?
function T.podeAdicionarDesvantagem(fichaFinalizada)
    if not fichaFinalizada then return true, nil end
    return false,
        "Desvantagens só entram na criação (Cap. 8). Depois que a campanha começa, "
     .. "só dá pra REMOVER — pagando o dobro do valor original mais um arco narrativo "
     .. "que resolva de fato (Cap. 13). Só o mestre libera."
end

--- Custo em XP para remover uma desvantagem. Cap. 13: "o dobro do valor original".
function T.custoRemoverDesvantagem(nome)
    local d = T.desvantagemPorNome(nome)
    if d == nil then return 0 end
    return (d.retorno or 0) * T.MULTIPLICADOR_REMOVER_DESVANTAGEM
end

return T
