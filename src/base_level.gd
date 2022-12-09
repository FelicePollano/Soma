extends Node2D

class_name BaseLevel

var ball_factory = BallFactory.new()

var bullets=[]
var paths=[]

export var bullet_speed=800

var victory_timer
var frog = preload("res://Frog.tscn")
var sounds = preload("res://LevelSounds.tscn")
var collision_happend =false #for audio effects out of physics loop
var collapse_happened =false
var play_roll = false
var sounds_instance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_paths()
	victory_timer = Timer.new()
	victory_timer.autostart=false
	victory_timer.wait_time=2.0
	victory_timer.one_shot=true
	victory_timer.connect("timeout",self,"next_level")
	add_child(victory_timer)
	sounds_instance=sounds.instance()
	add_child(sounds_instance)
	spawn_frog()
	
func fill_paths()->void:
	for child in get_children():
		if child is BasePath:
			child.connect("fast",self,"on_fast")
			child.connect("collapse",self,"on_collapsed")
			child.connect("ccollision",self,"on_collision")
			paths.append(child)

func on_fast()->void:
	play_roll=true
	
func on_collapsed()->void:
	collapse_happened=true
	
func on_collision()->void:
	collapse_happened=true

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
		
	if lost() && 0==get_balls_count():
		get_tree().change_scene("res://Level_Choose.tscn")
		
	if !lost() && 0 == get_balls_count():
		if victory_timer.is_stopped():
			victory_timer.start() #if we change level immediately, sound will stop to play
		if !sounds_instance.get_node("Victory").playing:
			sounds_instance.get_node("Victory").play()
		
		

func get_balls_count()->int:
	var count=0
	for p in paths:
			count+=p.get_balls_count()
	return count

func lost()->bool:
	for p in paths:
		if p.lost:
			return true
	return false

func _physics_process(delta: float) -> void:
	#move projectiles
	move_bullets(delta)
	

func next_level():
	var current = get_tree().get_current_scene().get_name()
	current.replace("//res://Level","")
	var nextLevel = int(current)+1
	var e = get_tree().change_scene("res://Level%s.tscn"%nextLevel)
	if e != OK:
		get_tree().change_scene("res://Level_Choose.tscn")

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
				for p in paths:
					var done = p.fit_new_ball(bullets[i],collision.collider)
					break
				bullets.remove(i)
				dirty=true
				break







