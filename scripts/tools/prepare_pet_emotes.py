"""Extract the eight supplied expressions from each original pet sheet."""
from pathlib import Path
from collections import deque
from PIL import Image, ImageFilter
ROOT = Path(__file__).resolve().parents[2]
NAMES = ['happy','love','star','surprise','confused','sad','angry','sleep']
for species, source in [('flying_fish','Cute Flying Fish Sprite Sheet.png'),('parrot','Cute Teal Parrot Sprite Sheet.png')]:
    image=Image.open(ROOT/'assets'/source).convert('RGB')
    folder=ROOT/'assets/pets'/species/'emotes'
    folder.mkdir(parents=True,exist_ok=True)
    bounds=[0,198,394,566,763,958,1160,1348,1536] if species=='flying_fish' else [0,216,410,587,781,981,1180,1363,1536]
    for index,name in enumerate(NAMES):
        crop=image.crop((bounds[index],674 if species=='flying_fish' else 700,bounds[index+1],865))
        width,height=crop.size
        barrier=Image.new('L',crop.size)
        barrier.putdata([255 if max(r,g,b)-min(r,g,b)>35 or max(r,g,b)<95 else 0 for r,g,b in crop.getdata()])
        wall=barrier.filter(ImageFilter.MaxFilter(3)).load()
        exterior=set()
        queue=deque([(x,y) for x in range(width) for y in [0,height-1]]+[(x,y) for y in range(height) for x in [0,width-1]])
        while queue:
            x,y=queue.popleft()
            if not (0<=x<width and 0<=y<height) or (x,y) in exterior or wall[x,y]: continue
            exterior.add((x,y))
            queue.extend([(x-1,y),(x+1,y),(x,y-1),(x,y+1)])
        alpha=Image.new('L',crop.size)
        alpha.putdata([0 if (x,y) in exterior else 255 for y in range(height) for x in range(width)])
        sprite=crop.convert('RGBA'); sprite.putalpha(alpha)
        sprite=sprite.crop(alpha.getbbox())
        sprite.thumbnail((146,140),Image.Resampling.LANCZOS)
        canvas=Image.new('RGBA',(160,160))
        canvas.alpha_composite(sprite,((160-sprite.width)//2,(160-sprite.height)//2))
        canvas.save(folder/(name+'.png'))
print('Extracted 16 original pet expressions')
