extends Marker3D

@export var min_x: float = 0
@export var max_x: float = 0
@export var min_z: float = 0
@export var max_z: float = 0

@onready var player_node = get_node("../Player") 

func _process(delta: float) -> void:
	var target_position = player_node.position
	position = Vector3(
			clamp(target_position.x, min_x, max_x),
			position.y,
			clamp(target_position.z, min_z, max_z)
		)
