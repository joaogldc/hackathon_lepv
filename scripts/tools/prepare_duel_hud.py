"""Extract reusable HUD artwork; live labels and energy are drawn by Godot."""
from copy import deepcopy
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
NS = 'http://www.w3.org/2000/svg'
ET.register_namespace('', NS)
source = ET.parse(ROOT / 'assets/ui/cartas/hud-cartas.svg').getroot()
info = next(c for c in source if c.get('id') == 'informacoes-da-partida')
player = next(c for c in info if c.get('id') == 'energy-player')
for name, bounds, elements in [
    ('painel-jogador', '28 24 290 79', list(player)[:2]),
    ('painel-turno', '478 24 324 79', [c for c in info if c.tag.endswith('rect')][:2]),
]:
    svg = ET.Element('{' + NS + '}svg', width=bounds.split()[2], height=bounds.split()[3], viewBox=bounds)
    for element in elements:
        svg.append(deepcopy(element))
    ET.ElementTree(svg).write(ROOT / ('assets/ui/cartas/' + name + '.svg'), encoding='utf-8', xml_declaration=True)
