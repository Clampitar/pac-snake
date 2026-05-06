class_name Level extends Node2D

@export var player_spawn: Vector2i

@onready var food: TileMapLayer = $FoodLayer
@onready var map: TileMapLayer = $MapLayer
var food_count = 0

func _ready():
	food_count = count_food()

func count_food():
	food.erase_cell(player_spawn)
	return food.get_used_cells().size()

func can_pass(coords: Vector2i) -> bool:
	return map.get_cell_atlas_coords(coords).x == 0

func has_food(coords: Vector2i) -> bool:
	return food.get_used_cells().find(coords) != -1

func eat_food(coords: Vector2i):
	food.erase_cell(coords)

func un_eat_food(coords: Vector2i):
	food.set_cell(coords, 0, Vector2i.ZERO)

func level_won(snake_length: int) -> bool:
	return snake_length >= food_count

func wrap_coords(coords: Vector2i) -> Vector2i:
	var rect: Rect2i = map.get_used_rect()
	var size = rect.size
	coords -= rect.position
	return Vector2i(posmod(coords.x, size.x), posmod(coords.y, size.y)) + rect.position
