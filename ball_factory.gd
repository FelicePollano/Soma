class_name BallFactory

var ball = preload("res://Ball.tscn")
var rnd = RandomNumberGenerator.new()
func _init():
	rnd.randomize()
func create() -> PathFollow2D:
	var follower=PathFollow2D.new()
	follower.loop=false
	var b = ball.instance()
	var color = rnd.randi_range(0,4)
	b.set_type(color)
	follower.add_child(b)
	
	return follower
	



