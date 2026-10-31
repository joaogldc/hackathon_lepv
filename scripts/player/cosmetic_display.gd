extends Node2D
const COSMETICS := preload("res://scripts/player/cosmetics.gd")
var outfit:="none"
var direction:="right"
func _draw() -> void:
	COSMETICS.paint(self,outfit,direction)
