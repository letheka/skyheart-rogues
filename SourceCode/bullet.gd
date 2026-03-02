extends Node3D

var time_stopped = false

var BULLET_SPEED = 10
var BULLET_DAMAGE = 15

const KILL_TIMER = 25
var timer = 0

var hit_something = false

func _ready():
	$Area3D.body_entered.connect(collided)
	SignalBus.start_time.connect(_start_time)
	SignalBus.stop_time.connect(_stop_time)

func _physics_process(delta):
	if time_stopped:
		return
	
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * BULLET_SPEED * delta)
	# print(global_transform.basis.x, global_transform.basis.y, global_transform.basis.z)

	timer += delta
	if timer >= KILL_TIMER:
		queue_free()
		
func _start_time():
	time_stopped = false

func _stop_time():
	time_stopped = true

func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)

	hit_something = true
	queue_free()
