class_name Player extends Node2D

signal move(x: int, y: int)
signal tail_eat(size: int)
signal undo()

@export var step = 20

@onready var head: Node2D = $HeadStart
@onready var tail: Sprite2D = $Tail

var screen_size
var head_dir: DIR
var tail_dir: DIR
var head_coords: Vector2i
var tail_coords: Vector2i
var pieces: Array[Piece]
var eating_tail: bool = false
var piece_sources :PackedStringArray = [
	"res://Assets/bodyStraight.png",
	"res://Assets/bodyCornerLeft.png",
	"res://Assets/bodyStraight.png",
	"res://Assets/bodyCornerRight.png"]
enum DIR{
	left = 2,
	right = 0,
	up = 3,
	down = 1
	}

var previous_actions: Array[Action]

func _ready():
	screen_size = get_viewport_rect().size
	head_dir = DIR.right
	tail_dir = DIR.right
	head_coords = Vector2i.ZERO
	tail_coords = Vector2i.ZERO

func spawn_at(coords: Vector2i):
	tail_coords = coords
	head_coords = coords
	head.position = coords * 20
	tail.position = coords * 20

func _input(event):
	if event.is_action_pressed("right"):
		move.emit(1, 0)
	if event.is_action_pressed("left"):
		move.emit(-1, 0)
	if event.is_action_pressed("down"):
		move.emit(0, 1)
	if event.is_action_pressed("up"):
		move.emit(0, -1)
	if event.is_action_pressed("undo"):
		undo.emit()

func can_pass(coords: Vector2i) -> bool:
	for piece in pieces:
		if piece.coords == coords:
			return false
	return  (not (tail_coords == coords and pieces.size() == 0)
			and not eating_tail)

func move_to(new_coords: Vector2i, dir: DIR, eat: bool):
	if  eat and tail_coords == head_coords:
		head.visible = false
		tail.position = head.position
		tail_coords = head_coords
		head = $HeadEat
		head.visible = true
		tail.visible = true
		rotate_part(tail, dir)
	else:
		add_piece(dir, head_dir)
	head_dir = dir
	rotate_part(head, dir)
	head_coords = new_coords
	head.position = head_coords * 20
	if head is AnimatedSprite2D:
		head.set_frame(0)
		head.play("eat")
		if(head_coords == tail_coords):
			eating_tail = true
			tail.visible = false
			var diff = head.rotation - tail.rotation
			if(diff < 0): diff+= 2*PI
			if diff <= 0.1:
				head.play("EatTailStraight")
			elif diff < PI + 0.1:
				head.play("EatTailLeft")
			else:
				head.play("EatTailRight")
	if eat:
		$FakeFood.visible = true
		$FakeFood.position = head.position
	if not eat and not eating_tail:
		tail_coords = remove_piece(tail, 0)
	if head is Sprite2D:
		tail_coords = new_coords
	previous_actions.append(Action.new(dir, eat))

func un_move(coords: Vector2i, dir: DIR, ate: bool):
	if head is Sprite2D:
		head_coords = coords
		tail_coords = coords
		head.position = head_coords * 20
		return
	if pieces.is_empty() and ate:
		head.visible = false
		head.position = tail.position
		head_coords = tail_coords
		head = $HeadStart
		head.visible = true
		tail.visible = false
		rotate_part(head, dir)
		return
	if not ate:
		add_piece(dir, tail_dir)
	head_coords = remove_piece(head, pieces.size()-1)

func rotate_part(part: Node2D, dir: DIR):
	part.rotation = dir*PI/2

func add_piece(dir: DIR, last_dir: DIR):
	var piece: Piece
	piece = Piece.new(piece_sources[(last_dir - dir) % 4])
	piece.place(head_coords, dir)
	piece.rotate(last_dir * PI/2)
	pieces.append(piece)
	add_child(piece)

func remove_piece(replacer: Node2D, index: int) -> Vector2:
	var piece: Piece = pieces.pop_at(index)
	replacer.position = piece.position
	rotate_part(replacer, piece.dir)
	remove_child(piece)
	return piece.coords

func _on_eat_finished():
	$FakeFood.visible = false
	if(eating_tail):
		tail_eat.emit(pieces.size())

func _on_eat_changed():
	$FakeFood.visible = false

class Action:
	var tail_dir: DIR
	var ate: bool
	var restart: bool
	
	func _init(_tail_dir: DIR = DIR.up,
	_ate: bool = false, _restart: bool = false) -> void:
		tail_dir = _tail_dir
		ate = _ate
		restart = _restart
