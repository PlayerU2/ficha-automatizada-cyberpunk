#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Completa Rajdhani e Orbitron com os glifos que elas não têm e o português usa.

O PROBLEMA: nem Rajdhani nem Orbitron desenham `º` (U+00BA) e `ª` (U+00AA) —
não é subsetting, é ausência real nas fontes originais do Google Fonts. O livro
imprime "1º ataque", "2º ataque", "3ª edição"; a ficha imprime "1º/2º/3º". Sem
esses glifos o renderizador troca de fonte no meio da palavra, e aparece um
"º" de outra família no meio de um rótulo — o tipo de defeito que ninguém
reporta, só acha feio.

ORBITRON FOI DESCARTADA por causa disto: o til dela é um traço reto e "PROGRESSÃO"
sai lendo "PROGRESSÀO". Numa ficha em português isso aparece em duas abas. A
verificação abaixo não pega esse caso — ela confere se o glifo EXISTE, não se
está desenhado direito. Esse continua sendo trabalho de olhar a tela.

A SOLUÇÃO: os ordinais são, literalmente, um "o" e um "a" pequenos e elevados.
Aqui eles são gerados como glifos COMPOSTOS — referência ao glifo base com uma
matriz de escala e um deslocamento vertical. Não há desenho novo: o traço é o
mesmo da fonte, então o peso e o estilo acompanham cada variante.

    python3 completar_glifos.py            # completa fontes/ttf/*.ttf no lugar
    python3 completar_glifos.py --conferir # só relata o que falta
"""
import argparse
import pathlib
import sys

from fontTools.ttLib import TTFont
from fontTools.ttLib.tables._g_l_y_f import Glyph, GlyphComponent

AQUI = pathlib.Path(__file__).parent
# no repositório os .ttf ficam em fontes/ttf; dentro do plugin ficam ao lado
# deste arquivo, em night-city-noir/fonts/
TTF = AQUI / "ttf" if (AQUI / "ttf").is_dir() else AQUI

# glifo novo -> (codepoint, glifo base, escala, altura relativa ao topo do base)
SINTETICOS = {
    "ordmasculine": (0x00BA, "o", 0.62, 0.98),
    "ordfeminine":  (0x00AA, "a", 0.62, 0.98),
    "periodcentered": (0x00B7, "period", 1.0, 0.62),
}

# o que precisa existir no fim — se faltar, o script sai com erro
EXIGIDOS = "áàâãéêíóôõúüçÁÀÂÃÉÊÍÓÔÕÚÜÇºª·–—“”’"


def nome_do_glifo(fonte, codepoint):
    return fonte.getBestCmap().get(codepoint)


def altura_do_glifo(fonte, nome):
    glyf = fonte["glyf"]
    if nome not in glyf: return None
    g = glyf[nome]
    if g.numberOfContours == 0: return 0
    g.recalcBounds(glyf)
    return g.yMax


def sintetizar(fonte, novo, codepoint, base_char, escala, topo_rel):
    cmap = fonte.getBestCmap()
    if codepoint in cmap:
        return False                      # a fonte já desenha este
    base = nome_do_glifo(fonte, ord(base_char)) if len(base_char) == 1 else base_char
    if base is None or base not in fonte["glyf"]:
        base = base_char if base_char in fonte["glyf"] else None
    if base is None:
        return None                       # não há de onde compor

    altura_x = altura_do_glifo(fonte, base) or 0
    unidades = fonte["head"].unitsPerEm
    # topo do glifo maiúsculo é a referência de "elevado"
    nome_maiusc = nome_do_glifo(fonte, ord("O")) or base
    topo = altura_do_glifo(fonte, nome_maiusc) or unidades * 0.7
    desloca_y = int(topo * topo_rel - altura_x * escala)

    comp = GlyphComponent()
    comp.glyphName = base
    comp.x, comp.y = 0, desloca_y
    comp.transform = [[escala, 0], [0, escala]]
    comp.flags = 0x04                      # ROUND_XY_TO_GRID

    g = Glyph()
    g.numberOfContours = -1
    g.components = [comp]
    fonte["glyf"].glyphs[novo] = g
    fonte.getGlyphOrder().append(novo)

    largura, lsb = fonte["hmtx"][base]
    fonte["hmtx"][novo] = (int(round(largura * escala)), int(round(lsb * escala)))

    for tabela in fonte["cmap"].tables:
        if tabela.isUnicode():
            tabela.cmap[codepoint] = novo
    return True


def conferir(caminho):
    f = TTFont(str(caminho))
    cmap = f.getBestCmap()
    return [c for c in EXIGIDOS if ord(c) not in cmap]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--conferir", action="store_true")
    a = ap.parse_args()

    arquivos = sorted(TTF.glob("*.ttf"))
    if not arquivos:
        print("nenhum .ttf em %s" % TTF); return 1

    if a.conferir:
        ruim = 0
        for p in arquivos:
            faltam = conferir(p)
            print("  %-30s %s" % (p.name, "OK" if not faltam else "FALTA " + "".join(faltam)))
            ruim += bool(faltam)
        print("\n%s" % ("SEM FALHAS — cobertura completa" if not ruim
                        else ">>> %d fonte(s) incompleta(s) <<<" % ruim))
        return 1 if ruim else 0

    for p in arquivos:
        f = TTFont(str(p))
        feitos = []
        for novo, (cp, base, esc, topo) in SINTETICOS.items():
            r = sintetizar(f, novo, cp, base, esc, topo)
            if r is True: feitos.append(chr(cp))
            elif r is None: print("  %s: sem glifo base para U+%04X" % (p.name, cp))
        if feitos:
            # o glifo composto precisa dos limites calculados antes de o maxp
            # ser recalculado — sem isso ele sai sem bounding box
            glyf = f["glyf"]
            for novo in SINTETICOS:
                if novo in glyf.glyphs:
                    glyf[novo].recalcBounds(glyf)
            f["maxp"].recalc(f)
            f.save(str(p))
            print("  %-30s + %s" % (p.name, " ".join(feitos)))
        else:
            print("  %-30s nada a fazer" % p.name)

    print("\nconferindo o resultado:")
    ruim = 0
    for p in arquivos:
        faltam = conferir(p)
        if faltam:
            ruim += 1
            print("  %-30s AINDA FALTA %s" % (p.name, "".join(faltam)))
    if ruim:
        print("\n>>> %d fonte(s) incompleta(s) <<<" % ruim)
        return 1
    print("  SEM FALHAS — as %d fontes cobrem o português inteiro" % len(arquivos))
    return 0


if __name__ == "__main__":
    sys.exit(main())
