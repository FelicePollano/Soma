extends Node2D

var ball_factory = BallFactory.new()
var main_strip =[]  #the main pulling strip. pulling ball
var bullets=[]
					#is at index 0
var pull_speed = 100.0
var bullet_speed=800
var ball_distance = 32
var level_max_balls = 150
var lost = false;
var frog = preload("res://Frog.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_balls(ball_distance)
	spawn_frog()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	move_bullets(delta)
	if main_strip.size()>0:
		#adjust speed
		var adjusted_speed = 0 
		
		if not lost:
			adjusted_speed = pull_speed+max(0,(300-main_strip.size()*12))
		else: 
			adjusted_speed=800
		#move pulling ball
		main_strip[0].offset += adjusted_speed*delta
		#let other follow
		var last_offset=main_strip[0].offset
		for i in range(1,main_strip.size()):
			last_offset=main_strip[i-1].offset-ball_distance
			main_strip[i].offset = last_offset
		if last_offset >= ball_distance && level_max_balls>0:
			spawn_balls(last_offset)
		if main_strip[0].unit_offset == 1.0:
			main_strip.remove(0)
			lost=true

func spawn_balls(distance):
	var howmany = (distance/ball_distance ) as int
	for i in range(0,howmany):
		var ball=ball_factory.create()
		main_strip.append(ball)
		$Path2D.add_child(ball)	
	level_max_balls-=howmany
func spawn_frog():
	var frog_instance=frog.instance()
	frog_instance.position=$FrogPosition.position
	add_child(frog_instance)
	
func fire(pos,angle,type):
	var b = ball_factory.create_bullet()
	b.set_type(type)
	b.position=to_local(pos)
	b.fire_angle=angle
	bullets.append(b)
	add_child(b)
	
	
func move_bullets(delta):
	for i in range(0,bullets.size()):
		var v = Vector2(Vector2(cos(bullets[i].fire_angle), sin(bullets[i].fire_angle)))
		bullets[i].get_child(0).move_and_collide(v*bullet_speed*delta)
		
