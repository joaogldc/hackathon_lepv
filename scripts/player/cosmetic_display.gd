extends Node2D
const COSMETICS := preload("res://scripts/player/cosmetics.gd")
var outfit:="none"
var outfits: Dictionary={}
var direction:="right"
var source: AnimatedSprite2D
func _process(_delta: float) -> void:
	queue_redraw()
func _draw() -> void:
	for item in ([outfit] if outfits.is_empty() else [outfits.get("body","none"),outfits.get("neck","none"),outfits.get("head","none")]):
		COSMETICS.paint(self,item,direction,Vector2.ZERO,1.0,float(source.frame)*0.5 if is_instance_valid(source) else 0.0)
