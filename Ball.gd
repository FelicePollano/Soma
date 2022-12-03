extends Node2D

var type
var fire_angle=0.0


func set_type(t):
	type=t
	match t:
		0:
			$KinematicBody2D/MeshInstance2D.modulate=Color(1,0,0,1)
		1:
			$KinematicBody2D/MeshInstance2D.modulate=Color(0,1,0,1)
		2:
			$KinematicBody2D/MeshInstance2D.modulate=Color(1,1,0,1)
		3:
			$KinematicBody2D/MeshInstance2D.modulate=Color(0,0,1,1)
		4:
			pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
