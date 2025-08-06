extends Node

var play_space_scene: PackedScene = preload("res://Scenes/mapTiler.tscn")
var play_space: MapTiler
var current_level: int = 0
var won: bool = false
@onready var victory_text: Label = $VictoryText
@onready var end_text_timer: Timer = $EndTextTimer

@onready var levels: Array[Resource]= [
	preload("res://Scenes/maps/tutorial_level.tscn"),
	preload("res://Scenes/maps/pure_food_level.tscn"),
	preload("res://Scenes/maps/some_food.tscn"),
	preload("res://Scenes/maps/pac_level.tscn"),
	preload("res://Scenes/maps/final_level.tscn")
]

func _ready():
	load_level()

func _input(event: InputEvent):
	if event.is_action_pressed("restart"):
		load_level()
		if won:
			end_text_timer.stop()
			won = false
			victory_text.visible = false
			victory_text.max_lines_visible = 0
			if play_space:
				play_space.visible = true

func _on_lose_level():
	load_level()


func _on_win_level():
	current_level += 1
	if current_level >= levels.size():
		won = true
		victory_text.visible = true
		victory_text.max_lines_visible = 0
		end_text_timer.start()
		if play_space:
			play_space.visible = false
		current_level = 0
		$FoodLeft.text = ""
		$SnakeLength.text = ""
	else:
		load_level()

func _on_updated_food(food_left: int, snake_length: int):
	$FoodLeft.text = "Food left: " + str(food_left)
	if snake_length > 1:
		$SnakeLength.text = "Snake length: " + str(snake_length)
	else:
		$SnakeLength.text = ""


func load_level():
	if play_space:
		remove_child(play_space)
	play_space = play_space_scene.instantiate()
	play_space.load(levels[current_level])
	play_space.win_level.connect(_on_win_level)
	play_space.lose_level.connect(_on_lose_level)
	play_space.update_food.connect(_on_updated_food)
	add_child(play_space)
	$FoodLeft.text = "Food left: " + str(play_space.map.count_food())
	$SnakeLength.text = ""


func _advance_end_text():
	victory_text.max_lines_visible += 1
