"""Extract existing fish poses; no generative image operations.
The source checkerboard is RGB pixels, so blue outlines enclose the cutout mask.
Run from repository root with Pillow installed.
"""
from pathlib import Path
from collections import deque
from PIL import Image, ImageFilter
SOURCE = Path('assets/Cute Flying Fish Sprite Sheet.png')
OUTPUT = Path('assets/pets/flying_fish')
POSES = {
 'front': (18,20,247,190),
 'side_1': (18,200,245,356),
 'side_2': (260,200,490,356),
 'side_3': (503,200,735,356),
 'side_4': (749,200,977,356),
 'back_1': (17,375,247,520),
 'back_2': (16,535,246,674),
}
def extract(image, rect):
    original = image.crop(rect).convert('RGB')
    width, height = original.size
    blue = Image.new('L', original.size)
    blue.putdata([255 if b-r>18 and b-g>5 else 0 for r,g,b in original.getdata()])
    # Close 1-pixel breaks in the outline before filling enclosed light details.
    barrier = blue.filter(ImageFilter.MaxFilter(3))
    walls = barrier.load()
    exterior = set()
    queue = deque([(x,0) for x in range(width)]+[(x,height-1) for x in range(width)]+[(0,y) for y in range(height)]+[(width-1,y) for y in range(height)])
    while queue:
        x,y = queue.popleft()
        if not (0<=x<width and 0<=y<height) or (x,y) in exterior or walls[x,y]:
            continue
        exterior.add((x,y))
        queue.extend([(x-1,y),(x+1,y),(x,y-1),(x,y+1)])
    mask = Image.new('L',original.size)
    mask.putdata([0 if (x,y) in exterior else 255 for y in range(height) for x in range(width)])
    rgba = original.convert('RGBA')
    rgba.putalpha(mask)
    rgba = rgba.crop(mask.getbbox())
    rgba.thumbnail((116,102), Image.Resampling.LANCZOS)
    canvas = Image.new('RGBA',(128,128))
    canvas.alpha_composite(rgba,((128-rgba.width)//2,(128-rgba.height)//2))
    return canvas
if __name__ == '__main__':
    OUTPUT.mkdir(parents=True,exist_ok=True)
    source = Image.open(SOURCE)
    for name,rect in POSES.items():
        sprite = extract(source,rect)
        sprite.save(OUTPUT/(name+'.png'))
        print(name, sprite.getbbox())
