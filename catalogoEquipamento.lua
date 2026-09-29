--[[===========================================================================
  NIGHT CITY NOIR — catalogoEquipamento.lua
  Cap. 9 (armas, armaduras, arremesso, equipamento geral, medtech),
  Cap. 10 (programas) e Cap. 12 (veículos), transcritos linha a linha.
=============================================================================]]

local E = {}

--[[---------------------------------------------------------------------------
  ARMAS — Cap. 9
  `tipo` liga a arma à perícia de ataque (Cap. 4).
  `classeAlcance` liga à tabela de Alcance; nil = corpo a corpo, sem alcance.
  `perfurante` é o traço do Cap. 4 que ignora metade da RD.
-----------------------------------------------------------------------------]]

E.CATEGORIAS_ARMA = { "Corpo a Corpo", "Armas de Fogo", "Arremesso e Explosivos" }

E.ARMAS = {
    -- CORPO A CORPO ----------------------------------------------------------
    { nome="Faca",           categoria="Corpo a Corpo", dano="1d6+COR", preco=50,
      tipo="corpoArmado", traco="", nota="Fácil de esconder", ocultacao="oculto" },
    { nome="Taco/Cano",      categoria="Corpo a Corpo", dano="1d6+COR", preco=30,
      tipo="corpoArmado", traco="", nota="Improvisada, fácil de achar" },
    { nome="Katana/Espada",  categoria="Corpo a Corpo", dano="2d6+COR", preco=800,
      tipo="corpoArmado", traco="", nota="Exige treino ou tem penalidade", ocultacao="aberto" },
    { nome="Machadinha",     categoria="Corpo a Corpo", dano="2d6+COR", preco=400,
      tipo="corpoArmado", traco="", nota="", ocultacao="volumoso" },
    { nome="Soco/Chute",     categoria="Corpo a Corpo", dano="1d6+COR", preco=0,
      tipo="corpoDesarmado", traco="", nota="Combate Desarmado, sem bônus de arma" },

    -- ARMAS DE FOGO ----------------------------------------------------------
    { nome="Pistola Leve",       categoria="Armas de Fogo", dano="2d6",   preco=300,
      tipo="fogo", classeAlcance="Pistola / SMG", traco="", nota="", ocultacao="oculto" },
    { nome="Pistola Pesada",     categoria="Armas de Fogo", dano="2d6+1", preco=600,
      tipo="fogo", classeAlcance="Pistola / SMG", traco="", nota="", ocultacao="oculto" },
    { nome="Submetralhadora",    categoria="Armas de Fogo", dano="2d6+1", preco=900,
      tipo="fogo", classeAlcance="Pistola / SMG", traco="Rajada disponível", rajada=true,
      nota="Rajada: dobra o dado, -2 no teste. Continua sendo 1 ataque/1 Ação — não conta como ataque extra.", ocultacao="volumoso" },
    { nome="Fuzil de Assalto",   categoria="Armas de Fogo", dano="3d6",   preco=1500,
      tipo="fogo", classeAlcance="Fuzil de Assalto", traco="", nota="", ocultacao="aberto" },
    { nome="Fuzil de Precisão",  categoria="Armas de Fogo", dano="3d6+2", preco=3500,
      tipo="fogo", classeAlcance="Fuzil de Precisão", traco="Perfurante", perfurante=true, nota="", ocultacao="aberto" },
    { nome="Escopeta",           categoria="Armas de Fogo", dano="3d6",   preco=700,
      tipo="fogo", classeAlcance="Escopeta", traco="", nota="Ver tabela de Alcance: +2 na curta, N/A na longa", ocultacao="volumoso" },
    { nome="Arma Pesada/Militar",categoria="Armas de Fogo", dano="3d6+2", preco=6000,
      tipo="pesada", classeAlcance="Arma Pesada/Militar", traco="Perfurante", perfurante=true,
      nota="Preço a partir de 6.000 — o livro imprime \"6.000+\"", ocultacao="aberto" },

    -- ARREMESSO E EXPLOSIVOS -------------------------------------------------
    -- O livro imprime "1d6 + Bônus" e o Apêndice B, item 2, fixa que o bônus é
    -- o de COR — REF já governa a pontaria. Escrever "+REF" aqui funcionava por
    -- acidente (R.dadoComBonus troca os dois), mas dizia a regra errada a quem
    -- lê o catálogo.
    { nome="Faca de Arremesso",       categoria="Arremesso e Explosivos", dano="1d6+COR", preco=40,
      tipo="arremesso", classeAlcance="Arco/Arremesso", traco="",
      nota="Arremesso, não explosivo: rola Combate à Distância (Arco/Arremesso).", ocultacao="oculto" },
    -- tipo="explosivo" → perícia Explosivos (MEN). A faixa de alcance continua a
    -- de Arco/Arremesso porque distância é física, não é escolha de perícia.
    { nome="Granada de Fragmentação", categoria="Arremesso e Explosivos", dano="3d6",     preco=300,
      tipo="explosivo", classeAlcance="Arco/Arremesso", traco="",
      nota="Área, raio 3 m. Esquiva bem-sucedida reduz o dano à metade, não anula.", ocultacao="oculto" },
    { nome="Granada de Choque",       categoria="Arremesso e Explosivos", dano="—",       preco=250,
      tipo="explosivo", classeAlcance="Arco/Arremesso", traco="",
      nota="Área, raio 3 m. Atordoa, não fere; teste de VON evita (Cap. 5).", ocultacao="oculto" },
    { nome="Carga Explosiva (C4)",    categoria="Arremesso e Explosivos", dano="4d6+2",   preco=1200,
      tipo="explosivo", traco="Perfurante", perfurante=true,
      nota="Área, raio 6 m. Montada, não arremessada — sem faixa de alcance." },
}

--[[---------------------------------------------------------------------------
  ARMADURAS — Cap. 9 (RD confere com a tabela do Cap. 4)
-----------------------------------------------------------------------------]]

E.ARMADURAS = {
    { nome="Roupa Reforçada", ocultacao="oculto",         rd=1, preco=150,  nota="Discreta",                    mecanico=nil },
    { nome="Colete Leve",             rd=2, preco=500,  nota="Visível sob a roupa",         mecanico=nil, ocultacao="volumoso" },
    { nome="Blindagem Tática/Corp.", ocultacao="aberto",  rd=4, preco=2000, nota="-1 Furtividade",
      mecanico={ pericia={ furtividade=-1 } } },
    { nome="Blindagem Militar Pesada",rd=6, preco=5500, nota="-2 Furtividade/Atletismo",
      mecanico={ pericia={ furtividade=-2, atletismo=-2 } }, ocultacao="aberto" },
}

--[[---------------------------------------------------------------------------
  EQUIPAMENTO GERAL / UTILIDADE e MEDTECH — Cap. 9
-----------------------------------------------------------------------------]]

E.CATEGORIAS_ITEM = { "Geral / Utilidade", "Medtech", "Suporte" }

E.ITENS = {
    -- GERAL / UTILIDADE ------------------------------------------------------
    { nome="Kit Médico",         categoria="Geral / Utilidade", preco=150,
      efeito="+2 em Primeiros Socorros · 3 cargas, uma por tratamento",
      consumivel=true, cargas=3, ocultacao="volumoso" },
    { nome="Kit de Ferramentas", categoria="Geral / Utilidade", preco=200,
      efeito="Necessário pra Mecânica e Eletrônica sem penalidade de −4",
      ocultacao="volumoso" },
    { nome="Cyberdeck Básico",   categoria="Geral / Utilidade", preco=1500,
      efeito="Necessário pra Interface; sem ele, −4", cyberdeck=true, modInterface=0,
      ocultacao="volumoso" },
    { nome="Cyberdeck Avançado", categoria="Geral / Utilidade", preco=4000,
      efeito="+1 no teste de Interface contra nós de segurança",
      cyberdeck=true, modInterface=1, ocultacao="volumoso" },
    { nome="Kit de Disfarce",    categoria="Geral / Utilidade", preco=300,
      efeito="+2 em Enganação para disfarces", ocultacao="oculto" },
    { nome="Drone Scout",        categoria="Geral / Utilidade", preco=1000,
      efeito="Explora à distância, vídeo em tempo real", ocultacao="volumoso" },
    { nome="Ganzuas/Lockpicks",  categoria="Geral / Utilidade", preco=100,
      efeito="Necessário pra Prestidigitação em fechaduras", ocultacao="oculto" },
    { nome="Rádio Criptografado",categoria="Geral / Utilidade", preco=250,
      efeito="Comunicação segura, resistente à escuta", ocultacao="oculto" },
    { nome="Corda/Escalada",     categoria="Geral / Utilidade", preco=80,
      efeito="+2 em Atletismo para escalar", ocultacao="volumoso" },

    -- MEDTECH ---------------------------------------------------------------
    { nome="Maleta de Trauma Avançada", categoria="Medtech", preco=900,
      efeito="Tratamento de Campo cura 2d6 em vez de 1d6 · 3 cargas",
      cargas=3, ocultacao="aberto" },
    { nome="Kit Cirúrgico de Campo",    categoria="Medtech", preco=2500,
      efeito="Necessário para Cirurgia de Emergência (Cap. 11)",
      ocultacao="volumoso" },
    { nome="Nanobots de Regeneração",   categoria="Medtech", preco=6000,
      efeito="Cura 1 PV por cena automaticamente · 5 usos",
      cargas=5, ocultacao="oculto" },

    -- SUPORTE — Cap. 9, pág. 23-B (novo na v3.2)
    -- "Nem todo eddie gasto vira dano. Estes itens existem pra quem joga
    --  olhando para o resto da mesa."
    -- A regra que rege a tabela inteira, no rodapé da página: "tudo que ANULA
    -- alguma coisa vem com dose ou carga contada. Só tem uso ilimitado o que
    -- MELHORA um teste." É por isso que `cargas` aparece em uns e não em outros.
    { nome="Analgésico da Fenda", categoria="Suporte", preco=50,
      efeito="Ignora a Penalidade de Ferimento por uma cena. Barato, e funciona: −1 de Humanidade a cada três usos",
      cargas=3, ocultacao="oculto",
      nota="O custo de Humanidade NÃO é automático: a ficha não sabe quantas cenas passaram. Lance na aba Cyberware quando o terceiro uso acontecer." },
    { nome="Antídoto de Largo Espectro", categoria="Suporte", preco=200,
      efeito="Remove Envenenado na hora, sem teste · 1 dose", cargas=1, ocultacao="oculto" },
    { nome="Kit de Perícia", categoria="Suporte", preco=200,
      efeito="Remove a penalidade de −4 por não ter a ferramenta exigida (Cap. 3)",
      ocultacao="volumoso",
      nota="Vale para UMA perícia, escolhida na compra — anote qual no nome da linha." },
    { nome="Analgésico de Campo", categoria="Suporte", preco=250,
      efeito="Ignora a Penalidade de Ferimento por uma cena inteira, sem custo de Humanidade · 1 dose",
      cargas=1, ocultacao="oculto" },
    { nome="Estimulante de Combate", categoria="Suporte", preco=300,
      efeito="Anula a condição Ferido por 3 rodadas. Ao acabar, −2 em tudo até um descanso completo · 1 dose",
      cargas=1, ocultacao="oculto" },
    { nome="Espuma Selante", categoria="Suporte", preco=400,
      efeito="Estanca Sangramento sem teste. Não compete com o limite de cura por combate (Cap. 11) · 3 cargas",
      cargas=3, ocultacao="oculto" },
    { nome="Rede de Contenção", categoria="Suporte", preco=500,
      efeito="O alvo atingido fica Imobilizado. Escape: teste de COR contra 12 · 1 uso",
      cargas=1, ocultacao="volumoso" },
    { nome="Cegador de Área", categoria="Suporte", preco=700,
      efeito="Todos num raio de 5 m ficam Cegos por 1 rodada. Teste de VON evita · 1 uso",
      cargas=1, ocultacao="oculto" },
    { nome="Desfibrilador de Bolso", categoria="Suporte", preco=800,
      efeito="Estabiliza alguém em PV 0 sem teste e sem gastar carga de Kit Médico · 2 cargas",
      cargas=2, ocultacao="oculto" },
    { nome="Torniquete Inteligente", categoria="Suporte", preco=1200,
      efeito="Um aliado a até 3 m para de perder PV por rodada enquanto estiver aplicado · reutilizável",
      ocultacao="oculto" },
    { nome="Scanner de Assinatura", categoria="Suporte", preco=1500,
      efeito="Detecta cyberware alheio à vista · +2 em Percepção Ativa contra quem tem implante",
      ocultacao="volumoso" },
    { nome="Marcador Tático", categoria="Suporte", preco=1600,
      efeito="Uma ação pra marcar um alvo: +1 para todo aliado que atacar ele até o fim da rodada",
      ocultacao="oculto" },
    { nome="Repetidor de Rede", categoria="Suporte", preco=2000,
      efeito="O grupo inteiro mantém rádio e transmissão dentro de uma Fissura de Grau 1",
      ocultacao="volumoso" },
    { nome="Drone Mula", categoria="Suporte", preco=2500,
      efeito="Carrega 60 kg e segue o dono sozinho · 15 PE · não luta e não atira",
      ocultacao="aberto" },
    { nome="Bancada de Campo", categoria="Suporte", preco=3500,
      efeito="Instala e ajusta cyberware fora de clínica: Eng. de Cyberware a −2 em vez de −4",
      ocultacao="aberto" },
    { nome="Drone Escudo", categoria="Suporte", preco=4000,
      efeito="Uma vez por combate, intercepta um ataque contra um aliado a até 5 m · 10 PE",
      cargas=1, ocultacao="aberto" },
    { nome="Torre Automática Portátil", categoria="Suporte", preco=5000,
      efeito="Monta em 1 ação. Age na sua iniciativa: 2d6, Valor-Alvo 11 · 10 PE",
      ocultacao="aberto" },
}

-- "Cyberdeck Básico: necessário pra Interface; SEM ELE, -4" (Cap. 9)
E.PENALIDADE_SEM_CYBERDECK = -4

--[[---------------------------------------------------------------------------
  PROGRAMAS DE NETRUNNING — Cap. 10
-----------------------------------------------------------------------------]]

-- A REGRA QUE REGE A TABELA INTEIRA (Cap. 10, pág. 25-A):
-- "Programa que ANULA um risco — uma ICE, um dano, um alerta — tem carga
--  contada: uma vez por invasão, ou por cena. Programa que só REDUZ ou MELHORA
--  um teste pode ser permanente."
-- É por isso que `cargas` aparece em uns e não em outros, e é a linha a usar
-- para qualquer programa que a mesa inventar depois.
--
-- `mecanicoNet` é o que a ficha aplica sozinha. Só entra aqui o que é numérico,
-- permanente e incondicional — o resto é texto, como no resto do projeto.
E.PROGRAMAS = {
    -- PARTE 2 — os cinco que qualquer runner tem (Cap. 10, pág. 25)
    { nome="Ataque.exe",       preco=1000, parte=2,
      efeito="2d6 de dano neural direto em netrunner ou ICE" },
    { nome="Escudo.exe",       preco=1200, parte=2,
      efeito="−2 em todo dano neural recebido", mecanicoNet={ danoNeural=-2 } },
    { nome="Fantasma.exe",     preco=1500, parte=2,
      efeito="−1 no Alerta ganho por falha (mínimo 0)", mecanicoNet={ alertaPorFalha=-1 } },
    { nome="Chave-Mestra.exe", preco=800,  parte=2,
      efeito="+2 em Interface contra fechaduras digitais",
      nota="Condicional: só contra fechadura digital. Lance como modificador no teste." },
    { nome="Backdoor.exe",     preco=2000, parte=2,
      efeito="−2 de Dificuldade em sistemas já invadidos antes",
      nota="Condicional: só em sistema já invadido. Lance na Dificuldade do nó." },

    -- PARTE 3 — o que se compra depois (Cap. 10, pág. 25-A · novo na v3.2)
    { nome="Sussurro.exe",       preco=600,  parte=3,
      efeito="Fala com um aliado dentro do mesmo sistema sem gastar ação. Não sobe Alerta" },
    { nome="Autópsia.exe",       preco=1000, parte=3,
      efeito="Lê o que um sistema morto ou derrubado ainda guardava. Interface a −2",
      nota="Condicional: só em sistema morto. Lance o −2 no teste." },
    { nome="Rastro.exe",         preco=1200, parte=3,
      efeito="Mostra quem mais esteve neste sistema nas últimas 24 h — e, com margem 5+, de onde",
      nota="Não causa dano. É ferramenta de investigação (Cap. 10)." },
    { nome="Ruído.exe",          preco=1500, parte=3,
      efeito="−2 na Interface de qualquer outro netrunner no mesmo sistema, inclusive aliado",
      nota="Atinge TODO MUNDO menos quem rodou. Não existe versão amiga." },
    { nome="Chave-Fantasma.exe", preco=1800, parte=3, cargas=1,
      efeito="Abre uma fechadura física ligada à rede, sem teste · 1 uso por invasão" },
    { nome="Espelho.exe",        preco=2000, parte=3, cargas=1,
      efeito="Devolve ao atacante um ataque neural recebido, com o mesmo dado · 1× por invasão" },
    { nome="Torniquete.exe",     preco=2000, parte=3, cargas=1,
      efeito="Restaura 1d6 de Foco Neural · 1× por cena" },
    { nome="Isca.exe",           preco=2500, parte=3, cargas=1,
      efeito="Uma ICE ataca um alvo falso em vez de alguém real · 1× por invasão" },
    { nome="Carrasco.exe",       preco=2500, parte=3,
      efeito="3d6 de dano neural direto — e sobe o Nível de Alerta em +2, sempre",
      mecanicoNet={ alertaAoUsar=2 },
      nota="O +2 de Alerta é AO USAR, não passivo: aperte o botão na aba Netrunning." },
    { nome="Cavalo.exe",         preco=3000, parte=3,
      efeito="Deixa um efeito armado no sistema, que dispara depois que você sair. Você escolhe o gatilho" },
    { nome="Máscara.exe",        preco=4000, parte=3,
      efeito="Sua assinatura fica registrada como a de outra pessoa. O Rastro.exe alheio encontra ela, não você" },
}

--[[---------------------------------------------------------------------------
  VEÍCULOS — Cap. 12
  VEL = velocidade · MAN = manobrabilidade (entra no teste de perseguição)
  PE  = pontos de estrutura · RD = redução de dano do veículo
-----------------------------------------------------------------------------]]

E.VEICULOS = {
    { nome="Carro Popular",            vel=6,  man=0,  pe=20, rd=1, preco=3000  },
    { nome="Carro Esportivo",          vel=9,  man=2,  pe=16, rd=1, preco=12000 },
    { nome="Moto",                     vel=8,  man=3,  pe=10, rd=0, preco=5000  },
    { nome="Van/Utilitário",           vel=5,  man=-1, pe=28, rd=2, preco=6000  },
    { nome="Van Blindada",             vel=5,  man=-2, pe=32, rd=4, preco=18000 },
    { nome="AV (Aerodino civil)",      vel=10, man=1,  pe=18, rd=2, preco=40000,
      aereo=true, nota="Usa Pilotagem Aérea/Drones" },
    { nome="Veículo Militar Terrestre",vel=7,  man=-1, pe=40, rd=6, preco=60000,
      nota="Preço a partir de 60.000 — o livro imprime \"60.000+\"" },
}

--[[---------------------------------------------------------------------------
  BUSCA
-----------------------------------------------------------------------------]]

local function _daCategoria(lista, categoria)
    local out = {}
    for _, it in ipairs(lista) do
        if it.categoria == categoria then out[#out + 1] = it end
    end
    return out
end

local function _porNome(lista, nome)
    for _, it in ipairs(lista) do
        if it.nome == nome then return it end
    end
    return nil
end

function E.armasDaCategoria(c) return _daCategoria(E.ARMAS, c) end
function E.itensDaCategoria(c) return _daCategoria(E.ITENS, c) end
function E.armaPorNome(n)      return _porNome(E.ARMAS,     n) end
function E.armaduraPorNome(n)  return _porNome(E.ARMADURAS, n) end
function E.itemPorNome(n)      return _porNome(E.ITENS,     n) end
function E.programaPorNome(n)  return _porNome(E.PROGRAMAS, n) end
function E.veiculoPorNome(n)   return _porNome(E.VEICULOS,  n) end

return E
