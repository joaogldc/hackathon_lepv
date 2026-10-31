extends Node2D
const ART := preload("res://scenes/world/commerce_art.tscn")

func _ready() -> void:
	# The imported scene is visual only; players and travel remain server-owned.
	add_child(ART.instantiate())

func _draw() -> void:
	var exit_point:=Vector2(576,615)
	load("res://scripts/world/ground_arrow.gd").paint(self,exit_point,0.0)
