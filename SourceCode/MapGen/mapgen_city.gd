extends Node

var buildings = [preload("res://SourceCode/MapGen/City/SkyscraperA.tscn"),
				 preload("res://SourceCode/MapGen/City/SkyscraperB.tscn"),
				 preload("res://SourceCode/MapGen/City/SkyscraperC.tscn"),
				 preload("res://SourceCode/MapGen/City/SkyscraperD.tscn"),
				 preload("res://SourceCode/MapGen/City/SkyscraperE.tscn")]
				
var road_scene = preload("res://SourceCode/MapGen/City/RoadStraight.tscn")
# var half_road_scene = preload("res://SourceCode/MapGen/City/RoadStraightHalf.tscn")
var intersection_scene = preload("res://SourceCode/MapGen/City/RoadIntersection.tscn")
var crossroad_scene = preload("res://SourceCode/MapGen/City/RoadCrossroad.tscn")

func sum(accum, number):
	return accum + number

func _try_get_map_val(map_array, x, z):
	# Get an array value if the indexes are valid, otherwise return 0.
	if x < 0 or z < 0 or x >= len(map_array) or z >= len(map_array[0]):
		return 0
	else:
		return map_array[x][z]

func _ready():
	var map_array = _gen_map_array()
	
	for x in range(0, 15):
		for z in range(0, 15):
			if map_array[x][z]:
				if randf() > 0.1:
					# Place a building
					var bldg = buildings.pick_random().instantiate()
					bldg.position = Vector3((x-8)*2+randf_range(-0.2, 0.2), 1, (z-8)*2+randf_range(-0.2, 0.2))
					add_child(bldg)
			else:
				var adj_sqrs = [_try_get_map_val(map_array, x-1, z),
								_try_get_map_val(map_array, x, z-1),
								_try_get_map_val(map_array, x+1, z),
								_try_get_map_val(map_array, x, z+1)]
				match adj_sqrs:
					[0, 0, 0, 0]:
						var road = crossroad_scene.instantiate()
						road.position = Vector3((x-8)*2, 1, (z-8)*2)
						var road2 = road_scene.instantiate()
						road2.position = Vector3((x-8)*2-1, 1, (z-8)*2)
						var road3 = road_scene.instantiate()
						road3.position = Vector3((x-8)*2+1, 1, (z-8)*2)
						var road4 = road_scene.instantiate()
						road4.position = Vector3((x-8)*2, 1, (z-8)*2-1)
						road4.rotation = Vector3(0, deg_to_rad(90), 0)
						var road5 = road_scene.instantiate()
						road5.position = Vector3((x-8)*2, 1, (z-8)*2+1)
						road5.rotation = Vector3(0, deg_to_rad(90), 0)
						add_child(road)
						add_child(road2)
						add_child(road3)
						add_child(road4)
						add_child(road5)
					[0, 1, 0, 1]:
						var road = road_scene.instantiate()
						road.position = Vector3((x-8)*2-0.5, 1, (z-8)*2)
						var road2 = road_scene.instantiate()
						road2.position = Vector3((x-8)*2+0.5, 1, (z-8)*2)
						add_child(road)
						add_child(road2)
					[1, 0, 1, 0]:
						var road = road_scene.instantiate()
						road.position = Vector3((x-8)*2, 1, (z-8)*2-0.5)
						road.rotation = Vector3(0, deg_to_rad(90), 0)
						var road2 = road_scene.instantiate()
						road2.position = Vector3((x-8)*2, 1, (z-8)*2+0.5)
						road2.rotation = Vector3(0, deg_to_rad(90), 0)
						add_child(road)
						add_child(road2)
					[0, 0, 0, 1]:
						var road = intersection_scene.instantiate()
						road.position = Vector3((x-8)*2, 1, (z-8)*2)
						road.rotation = Vector3(0, deg_to_rad(180), 0)
						var road2 = road_scene.instantiate()
						road2.position = Vector3((x-8)*2, 1, (z-8)*2-1)
						road2.rotation = Vector3(0, deg_to_rad(90), 0)
						var road3 = road_scene.instantiate()
						road3.position = Vector3((x-8)*2-1, 1, (z-8)*2)
						var road4 = road_scene.instantiate()
						road4.position = Vector3((x-8)*2+1, 1, (z-8)*2)
						add_child(road)
						add_child(road2)
						add_child(road3)
						add_child(road4)
					[0, 0, 1, 0]:
						var road = intersection_scene.instantiate()
						road.position = Vector3((x-8)*2, 1, (z-8)*2)
						road.rotation = Vector3(0, deg_to_rad(270), 0)
						var road2 = road_scene.instantiate()
						road2.position = Vector3((x-8)*2, 1, (z-8)*2-1)
						road2.rotation = Vector3(0, deg_to_rad(90), 0)
						var road3 = road_scene.instantiate()
						road3.position = Vector3((x-8)*2, 1, (z-8)*2+1)
						road3.rotation = Vector3(0, deg_to_rad(90), 0)
						var road4 = road_scene.instantiate()
						road4.position = Vector3((x-8)*2-1, 1, (z-8)*2)
						add_child(road)
						add_child(road2)
						add_child(road3)
						add_child(road4)
					[0, 1, 0, 0]:
						var road = intersection_scene.instantiate()
						road.position = Vector3((x-8)*2, 1, (z-8)*2)
						var road2 = road_scene.instantiate()
						road2.position = Vector3((x-8)*2-1, 1, (z-8)*2)
						var road3 = road_scene.instantiate()
						road3.position = Vector3((x-8)*2+1, 1, (z-8)*2)
						var road4 = road_scene.instantiate()
						road4.position = Vector3((x-8)*2, 1, (z-8)*2+1)
						road4.rotation = Vector3(0, deg_to_rad(90), 0)
						add_child(road)
						add_child(road2)
						add_child(road3)
						add_child(road4)
					[1, 0, 0, 0]:
						var road = intersection_scene.instantiate()
						road.position = Vector3((x-8)*2, 1, (z-8)*2)
						road.rotation = Vector3(0, deg_to_rad(90), 0)
						add_child(road)
						var road2 = road_scene.instantiate()
						road2.position = Vector3((x-8)*2+1, 1, (z-8)*2)
						var road3 = road_scene.instantiate()
						road3.position = Vector3((x-8)*2, 1, (z-8)*2-1)
						road3.rotation = Vector3(0, deg_to_rad(90), 0)
						var road4 = road_scene.instantiate()
						road4.position = Vector3((x-8)*2, 1, (z-8)*2+1)
						road4.rotation = Vector3(0, deg_to_rad(90), 0)
						add_child(road)
						add_child(road2)
						add_child(road3)
						add_child(road4)
					_:
						pass
				
			
			# draw surrounding roads
			#var road_x = road.instantiate()
			#road_x.position = Vector3((x*3)-1.5, 1, (z*3)-0.5)
			#road_x.rotation = Vector3(0, deg_to_rad(90), 0)
			#add_child(road_x)
			#var road_x_2 = road.instantiate()
			#road_x_2.position = Vector3((x*3)-1.5, 1, (z*3)+0.5)
			#road_x_2.rotation = Vector3(0, deg_to_rad(90), 0)
			#add_child(road_x_2)
			#var road_z = road.instantiate()
			#road_z.position = Vector3((x*3)-0.5, 1, (z*3)-1.5)
			#add_child(road_z)
			#var road_z_2 = road.instantiate()
			#road_z_2.position = Vector3((x*3)+0.5, 1, (z*3)-1.5)
			#add_child(road_z_2)
			#var crossroad_1 = crossroad.instantiate()
			#crossroad_1.position = Vector3((x*3)-1.5, 1, (z*3)-1.5)
			#add_child(crossroad_1)
			
func _gen_map_array():
	var row = []
	row.resize(16)
	row.fill(0)
	var map_array = []
	for x in range(0, 15):
		map_array.append(row.duplicate())
	
	for x in range(1, 14):
		for z in range(1, 14):
			# Run the cellular automata
			var cells = [_try_get_map_val(map_array, x-1, z-1),
						 _try_get_map_val(map_array, x, z-1),
						 _try_get_map_val(map_array, x-1, z)].reduce(sum, 0)
			match cells:
				0:
					if (_try_get_map_val(map_array, x-1, z-1) == 0 and
						_try_get_map_val(map_array, x-1, z+1) == 0):
						map_array[x][z] = 1
				1:
					if (_try_get_map_val(map_array, x-1, z-1) == 0 and
						_try_get_map_val(map_array, x-1, z) == 1 and
						_try_get_map_val(map_array, x-1, z+1) == 1 and 
						_try_get_map_val(map_array, x-1, z+2) == 0 and
						randf() < 0.5):
						map_array[x][z] = 1
					elif (_try_get_map_val(map_array, x-1, z-1) == 0 and
						  _try_get_map_val(map_array, x-1, z+1) == 0 and
						  randf() < 0.5):
						map_array[x][z] = 1
				2:
					pass
				3:
					map_array[x][z] = 1

	#for x in range(0, 15):
		#var str = ""
		#for z in range(0, 15):
			#if map_array[x][z]:
				#str += "#"
			#else:
				#str += "."
		#print(str)

	return(map_array)	
