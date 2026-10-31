"""Remove the two small boarding ropes; retain the delivered ship and rigging."""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[2]
source=ROOT/'assets/cenario/glacial_runtime/navio-polar.png'
image=Image.open(source).convert('RGBA')
# Coordinates refer to the 640px runtime asset, before any scene transform.
mask=Image.new('L',image.size); draw=ImageDraw.Draw(mask)
draw.polygon([(86,359),(100,367),(114,371),(127,369),(136,363),(138,370),(128,376),(113,379),(98,375),(86,367)],fill=255)
# This rope lies over the snowy landing. Heal it from the snow immediately above.
pixels=image.load()
for y in range(image.height):
 for x in range(image.width):
  if mask.getpixel((x,y)):
   pixels[x,y]=(241,245,249,255)
# Outer rope between the left landing post and the gangway post lies over water.
mask=Image.new('L',image.size); ImageDraw.Draw(mask).polygon([(85,349),(92,345),(101,336),(105,331),(109,334),(105,341),(97,349),(87,354)],fill=255)
for y in range(image.height):
 for x in range(image.width):
  if mask.getpixel((x,y)): pixels[x,y]=(0,0,0,0)
image.save(source.with_name('navio-polar-aberto.png'))
