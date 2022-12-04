extends Node2D

class_name BaseLevel

var ball_factory = BallFactory.new()
var main_strip =[]  #the main pulling strip. pulling ball
					#is at index 0
var small_strips=[]
var bullets=[]

export var pull_speed = 50.0
export var bullet_speed=800
export var ball_distance = 32
export var level_max_balls = 60
var lost = false;
var frog = preload("res://Frog.tscn")
var sounds = preload("res://LevelSounds.tscn")
var collision_happend =false #for audio effects out of physics loop
var collapse_happened =false
var play_roll = false
var sounds_instance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sounds_instance=sounds.instance()
	add_child(sounds_instance)
	spawn_balls(ball_distance)
	spawn_frog()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if collision_happend:
		sounds_instance.get_node("Clack").play()
		collision_happend=false
	if collapse_happened:
		sounds_instance.get_node("Strike").play()
		collapse_happened=false
	if !play_roll:
		sounds_instance.get_node("Rolling").stop()
	if play_roll && !sounds_instance.get_node("Rolling").playing:
		sounds_instance.get_node("Rolling").play()
		play_roll=false
	pass

func _physics_process(delta: float) -> void:
	#move projectiles
	move_bullets(delta)
	arrange_strips()
	collapse_residuals()
	#adjust speed
	var adjusted_speed = 0 
	#move main strip
	if main_strip.size()>0:
		
		
		if not lost:
			if level_max_balls > 20:
				adjusted_speed = pull_speed+max(0,(300-main_strip.size()*12))
			else:
				adjusted_speed=pull_speed
		else: 
			adjusted_speed=800
		if adjusted_speed>300:
			play_roll=true
		var last_offset=move_a_strip(main_strip,adjusted_speed,delta)
		#spawn new balls
		if last_offset >= ball_distance && level_max_balls>0:
			spawn_balls(last_offset)
		if main_strip[0].unit_offset == 1.0:
			main_strip.remove(0)
			lost=true
	#move residual strips
	for i in range(0,small_strips.size()):
		adjusted_speed = pull_speed +max(0,(300-small_strips[i].size()*12))
		#if adjusted_speed>100:
		#	play_roll=true
		move_a_strip(small_strips[i],-adjusted_speed,delta)

func move_a_strip(strip,speed,delta) -> float:
	#move pulling ball
	strip[0].offset += speed*delta
		#let other follow
	var last_offset=strip[0].offset
	for i in range(1,strip.size()):
		last_offset=strip[i-1].offset-ball_distance
		strip[i].offset = last_offset	
	return last_offset


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
	var dirty=true
	while dirty:
		dirty = false
		for i in range(0,bullets.size()):
			var v = Vector2(Vector2(cos(bullets[i].fire_angle), sin(bullets[i].fire_angle)))
			var collision = bullets[i].get_child(0).move_and_collide(v*bullet_speed*delta)
			if collision:
				collision_happend=true
				fit_new_ball(bullets[i],collision.collider)
				bullets.remove(i)
				dirty=true
				break
				
				
func fit_new_ball(ball,target):
	var new = ball_factory.create()
	new.get_child(0).set_type(ball.type)
	var done = false
	#looks for the path follower from KinematicBody child
	var follower = target.get_node("../../")
	done = fit_in_strip(follower,main_strip,new)
	collision_happend=done
	for i in range(0,small_strips.size()):
			if fit_in_strip(follower,small_strips[i],new):
				collision_happend=true
				break
	remove_child(ball)

func fit_in_strip(follower,strip,ball)->bool:
	var done = false
	for i in range(0,strip.size()):
		if(strip[i] == follower ):
			if i==0:
				ball.offset=strip[0].offset
			strip.insert(i,ball)
			mark_matches(i,strip)
			strip[0].offset+=ball_distance #make longer one ball
			done = true
			$Path2D.add_child(ball)
			break
	return done

func mark_matches(index,vector):
	var type = vector[index].get_child(0).type
	var _min = index
	var _max = index
	
	for i in range(index,vector.size()):
		if vector[i].get_child(0).type != type:
			_max = i-1
			break;
	
	for i in range(index,-1,-1):
		if vector[i].get_child(0).type != type:
			_min = i+1
			break;
	
	if _max-_min >= 2:
		var ts = OS.get_ticks_msec()
		for i in range(_min,_max+1):
			vector[i].get_child(0).set_match(ts)
		
	
func arrange_strips():
	var dirty = true
	var ts = OS.get_ticks_msec()
	var from=-1
	var to=-1
	for i in range (0,main_strip.size()):
		if main_strip[i].get_child(0).is_match && ts - main_strip[i].get_child(0).timestamp > 500:
			from=i
			break
	if from != - 1:
		for i in range (from,main_strip.size()):
			if !main_strip[i].get_child(0).is_match:
				to=i-1
				break
	if to > from:
		#slice array
		var temp = main_strip.slice(0,from-1)
		var throw = main_strip.slice(from,to)
		main_strip=main_strip.slice(to+1,main_strip.size()-1)
		if from > 0:
			small_strips.append(temp)
		for i in range(0,throw.size()):
			$Path2D.remove_child(throw[i]);
			throw[i].queue_free()
		
func collapse_residuals():
	var dirty=true
	while dirty:
		dirty=false
		for i in range(0,small_strips.size()):
			if small_strips[i][small_strips[i].size()-1].offset-ball_distance<=main_strip[0].offset:
				var new_main=[]
				dirty=true
				collapse_happened=true
				#small strip is in reverse order, the puller will be the last index
				for q in range(0,small_strips[i].size()):
					new_main.append(small_strips[i][q])
				small_strips.remove(i)
				var contact_index=new_main.size()-1
				for q in range(0,main_strip.size()):
					new_main.append(main_strip[q])
				main_strip=new_main
				mark_matches(contact_index,main_strip)
		
