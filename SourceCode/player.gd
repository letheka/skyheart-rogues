extends CharacterBody3D

var time_stopped = false
const RAY_LENGTH = 100

@export var move_speed = 10
var target_pos = Vector3.ZERO

@export var health_max = 100
var health = 100

@export var charge_meter_max = 100
var charge_meter = 100
@export var charge_speed = 2 # The max should always be divisible by this

var grid_direction = Vector3.ZERO
var target_velocity = Vector3.ZERO

# var bullet_cooldown = 0
var bullet_scene = preload("bullet.tscn")
const DAMAGE = 15

func _ready():
	SignalBus.start_time.connect(_start_time)
	SignalBus.stop_time.connect(_stop_time)
	target_pos = $Pivot.global_position
	pass

func _physics_process(delta):
	var direction = Vector3.ZERO

	if direction == Vector3.ZERO:
		if Input.is_action_pressed("move_to_mouse_pos"):
			var mouse_ray = raycast_from_mouse(get_viewport().get_mouse_position(), 0b1111)
			if mouse_ray.has("position"):
				var mouse_pos = mouse_ray.position
				mouse_pos.y = 1
				var target_ray = raycast_from_player(mouse_pos, 0b1111)
				if target_ray.has("position"):
					target_pos = target_ray.position
					target_pos.y = 1
					# Move the target pos a short distance away from the collider
					var dist = position.distance_to(target_pos)
					target_pos = position.lerp(target_pos, 1-(1/dist/2))
				else:
					# We did not collide with anything, so just move to the mouse position
					target_pos = mouse_ray.position
			else:
				target_pos = position
		if Input.is_action_pressed("fire_bullet") and charge_meter == charge_meter_max:
			grid_direction.x = 0
			grid_direction.z = 0
			var mouse_pos = raycast_from_mouse(get_viewport().get_mouse_position(), 0b0110).position
			mouse_pos.y = 1
			# Move the origin pos a short distance away from us
			var dist = position.distance_to(mouse_pos)
			var bullet_origin_pos = position.lerp(mouse_pos, 1/dist/2)
			self.fire_bullet(mouse_pos, bullet_origin_pos)
			charge_meter = 0
			SignalBus.stop_time.emit()
			# bullet_cooldown = 100
			
	var target_dist = $Pivot.global_position.distance_to(target_pos)
	if (target_dist > 0.1):
		direction.x = -($Pivot.global_position.x - target_pos.x) / target_dist
		direction.z = -($Pivot.global_position.z - target_pos.z) / target_dist
		if Input.is_action_pressed("move_to_mouse_pos"):
			# to prevent visual weirdness, change pivot rotation only if target_pos was changed
			$Pivot.basis = Basis.looking_at(direction)
			
	if (direction != Vector3.ZERO) and (abs(direction.x) + abs(direction.y) + abs(direction.z) > 0.1):
		if time_stopped:
			SignalBus.start_time.emit()
		if charge_meter < charge_meter_max:
			charge_meter += charge_speed
	elif not time_stopped:
		# target_pos = position # clear the target pos to prevent stuttering
		SignalBus.stop_time.emit()
		return
		
	# Ground Velocity
	target_velocity.x = direction.x * move_speed
	target_velocity.z = direction.z * move_speed

	# Moving the Character
	velocity = target_velocity
	move_and_slide()


func _start_time():
	time_stopped = false
	
	
func _stop_time():
	time_stopped = true


func raycast_from_mouse(m_pos, collision_mask):
	var cam = get_viewport().get_camera_3d()
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * RAY_LENGTH
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)
	
	
func raycast_from_player(t_pos, collision_mask):
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(position, t_pos, collision_mask)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)


func fire_bullet(t_pos, o_pos):
	t_pos.y = 1
	
	var clone = bullet_scene.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)

	clone.global_transform = $Pivot.global_transform
	clone.position = o_pos
	clone.basis = Basis.looking_at(clone.position - t_pos)
	# clone.rotate_y(deg_to_rad(180))
	clone.scale = Vector3(0.25, 0.25, 0.25)
	clone.BULLET_DAMAGE = DAMAGE
