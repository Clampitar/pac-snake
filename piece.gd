class_name Piece extends Sprite2D

var coords: Vector2i
var dir: Player.DIR

func _init(path: String):
	texture = load(path)

func place(cell: Vector2i, new_dir: Player.DIR):
	coords = cell
	position = cell * 20
	dir = new_dir
