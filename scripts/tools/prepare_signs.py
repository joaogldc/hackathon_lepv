"""Extract original vector signs, leaving lettering to Godot's font renderer."""
from copy import deepcopy
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/cenario/placas/fonte/placas.svg'
NS = 'http://www.w3.org/2000/svg'
ET.register_namespace('', NS)
catalog = {
    'math': 'placa_esquerda_bosque_bambus',
    'science': 'placa_direita_foguete_ciencias',
    'language': 'placa_sul_barco_portugues',
    'commerce': 'placa_norte_area_comercial',
}
source = ET.parse(SOURCE).getroot()
for key, name in catalog.items():
    layer = deepcopy(next(c for c in source if c.get('id') == 'sprite_' + name))
    layer.set('transform', 'translate(150,300)')
    for group in layer.iter():
        for child in list(group):
            if len(child.get('d', '')) > 500 and child.get('style') in ('fill:#f3d6a8', 'fill:#4a2a10'):
                group.remove(child)
    svg = ET.Element('{' + NS + '}svg', width='300', height='320', viewBox='0 0 300 320')
    svg.append(layer)
    ET.ElementTree(svg).write(ROOT / ('assets/cenario/placas/placa_' + key + '.svg'), encoding='utf-8', xml_declaration=True)
