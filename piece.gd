class_name Piece extends Sprite2D

var coords: Vector2i
var to_dir: Player.DIR
var from_dir: Player.DIR

func _init(path: String):
	texture = load(path)

func place(cell: Vector2i, new_dir: Player.DIR, old_dir: Player.DIR):
	coords = cell
	position = cell * 20
	to_dir = new_dir
	from_dir = old_dir
