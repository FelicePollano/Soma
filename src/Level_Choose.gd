extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button_level0.connect("pressed",self,"_launch_0")
	$Button_level1.connect("pressed",self,"_launch_1")

func _launch_0():
	get_tree().change_scene("res://Level0.tscn")
func _launch_1():
	get_tree().change_scene("res://Level1.tscn")

