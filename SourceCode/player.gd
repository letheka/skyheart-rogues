extends CharacterBody3D

var time_stopped = false
const RAY_LENGTH = 100

@export var speed = 10
var target_pos = Vector3.ZERO

var remaining_action_time = 0
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
			target_pos = raycast_from_mouse(get_viewport().get_mouse_position(), 1).position
			target_pos.y = 1
		if Input.is_action_pressed("move_east"):
			grid_direction.x = 1
			grid_direction.z = 0
			remaining_action_time = 50
		if Input.is_action_pressed("move_west"):
			grid_direction.x = -1
			grid_direction.z = 0
			remaining_action_time = 50
		if Input.is_action_pressed("move_north"):
			grid_direction.x = 0
			grid_direction.z = -1
			remaining_action_time = 50
		if Input.is_action_pressed("move_south"):
			grid_direction.x = 0
			grid_direction.z = 1
			remaining_action_time = 50
		if Input.is_action_pressed("fire_bullet") and remaining_action_time == 0:
			grid_direction.x = 0
			grid_direction.z = 0
			self.fire_bullet(raycast_from_mouse(get_viewport().get_mouse_position(), 1).position)
			remaining_action_time = 100
			SignalBus.stop_time.emit()
			# bullet_cooldown = 100
			
	var target_dist = $Pivot.global_position.distance_to(target_pos)
	if (target_dist > 0.1):
		direction.x = -($Pivot.global_position.x - target_pos.x) / target_dist
		direction.z = -($Pivot.global_position.z - target_pos.z) / target_dist
		if remaining_action_time > 0:
			remaining_action_time -= speed
		

	if direction != Vector3.ZERO:
		# Setting the basis property will affect the rotation of the node.
		if time_stopped:
			SignalBus.start_time.emit()
		$Pivot.basis = Basis.looking_at(direction)
	elif not time_stopped:
		SignalBus.stop_time.emit()
		return
		
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

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


func fire_bullet(t_pos):
	t_pos.y = 1
	
	var clone = bullet_scene.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)

	clone.global_transform = $Pivot.global_transform
	clone.basis = Basis.looking_at(clone.position - t_pos)
	# clone.rotate_y(deg_to_rad(180))
	clone.scale = Vector3(0.25, 0.25, 0.25)
	clone.BULLET_DAMAGE = DAMAGE
