extends Node2D

var charge_speed=200
var fire_position=56
var ball_factory = BallFactory.new()
var charging=false
var fire = false
var ball
func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouse:
		var pos = get_local_mouse_position()
		$Sprite.rotation=atan2(pos.y,pos.x)-PI/2
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			fire=true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn() 
	charging=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func spawn():
	ball=ball_factory.create_bullet()
	ball.position=Vector2(0,10)
	$Sprite.add_child(ball)
	
func _physics_process(delta: float) -> void:
	if charging:
		ball.position.y+=delta*charge_speed
	ball.position.y = min(ball.position.y,fire_position)
	if ball.position.y >= fire_position:
		charging=false
	if ball.position.y >= fire_position && fire:
		get_parent().fire(ball.get_child(0).global_position,$Sprite.rotation+PI/2,ball.type)
		$Sprite.remove_child(ball)
		ball.queue_free()
		spawn()
		charging=true
		fire=false
		
		
