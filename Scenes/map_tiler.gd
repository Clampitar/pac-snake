class_name MapTiler extends Node2D

@export var map_width_half: int
@export var tile_size: int
@onready var player: Player = $Player
var map: Level
var pieces: Array[Node2D]
const DATA_LAYER_NAME: String = "collision_id"
var firstmove: bool = true

signal win_level
signal lose_level
signal update_food(food_count: int, snake_length: int)

func _ready():
	player.spawn_at(map.player_spawn)

func load(new_map_scene: PackedScene):
	map = new_map_scene.instantiate()
	add_child(map)

func tesselate3():
	dupe(2, -1, 90)
	dupe(1, 1, 270)
	dupe(2, 3, 180)
	dupe(1, 2, 90)
	dupe(-2, 2, 270)
	dupe(0, 1, 180)

func dupe(x: int, y: int, deg: int):
	var map2: Node2D = map.duplicate()
	map2.position += Vector2( x * map_width_half, y *  map_width_half)
	map2.rotate(deg_to_rad(deg))
	add_child(map2)


func _on_player_move(x, y):
	var new_coords: Vector2i = Vector2i(x, y) + player.head_coords
	if map.can_pass(new_coords) and player.can_pass(new_coords):
		var dir: Player.DIR = Player.DIR.up
		if x < 0:
			dir = Player.DIR.left
		elif x > 0:
			dir = Player.DIR.right
		elif y > 0:
			dir = Player.DIR.down
		player.move_to(new_coords, dir, map.has_food(new_coords))
		map.eat_food(new_coords)
		player.head_coords = new_coords
		update_food.emit(map.count_food(), 1 if player.firstmove else player.pieces.size() + 2)

func on_tail_eat(snake_length: int):
	if map.level_won(snake_length):
		win_level.emit()
	else:
		lose_level.emit()
