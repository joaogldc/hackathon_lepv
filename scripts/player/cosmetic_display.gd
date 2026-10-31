extends Node2D
const COSMETICS := preload("res://scripts/player/cosmetics.gd")
var outfit:="none"
var direction:="right"
var source: AnimatedSprite2D
func _process(_delta: float) -> void:
	queue_redraw()
func _draw() -> void:
	COSMETICS.paint(self,outfit,direction,Vector2.ZERO,1.0,float(source.frame)*0.5 if is_instance_valid(source) else 0.0)
