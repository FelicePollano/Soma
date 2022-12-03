extends Node2D

var ball_factory = BallFactory.new()
var main_strip =[]  #the main pulling strip. pulling ball
					#is at index 0
var pull_speed = 100.0
var ball_distance = 32
var level_max_balls = 150
var lost = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_balls(ball_distance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
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
