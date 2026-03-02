extends Node2D

@onready var player = get_node("../../Player")
@onready var energy_bar = get_node("EnergyBarNode/EnergyBar")
@onready var health_bar = get_node("HealthBarNode/HealthBar")

func _process(delta):
	position = get_viewport().get_camera_3d().unproject_position(player.position)
	energy_bar.value = player.charge_meter
	health_bar.value = player.health
