class_name Player extends Node2D

signal move(x: int, y: int)
signal tail_eat(size: int)

@export var step = 20

@onready var head: Node2D = $HeadStart
@onready var tail: Node2D = $Tail

var screen_size
var tail_coords: Vector2i
var head_coords: Vector2i
var pieces: Array[Piece]
var firstmove: bool = true
var eating_tail: bool = false
var piece_sources :PackedStringArray = ["res://Assets/bodyStraight.png",
	"res://Assets/bodyCornerLeft.png", "res://Assets/bodyStraight.png",  "res://Assets/bodyCornerRight.png"]
enum DIR{
	left = 2,
	right = 0,
	up = 3,
	down = 1
	}

var last_dir: DIR = DIR.right
var tail_dir

func _ready():
	screen_size = get_viewport_rect().size
	tail_coords = Vector2i.ZERO
	head_coords = Vector2i.ZERO

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

func can_pass(coords: Vector2i) -> bool:
	for piece in pieces:
		if piece.coords == coords:
			return false
	return  (not (tail_coords == coords and pieces.size() == 0)
			and not eating_tail)

func move_to(new_coords: Vector2i, dir: DIR, eat: bool):
	if firstmove and eat:
		firstmove = false
		last_dir = dir
		head.visible = false
		tail.position = head.position
		tail_coords = head_coords
		head = $HeadEat
		head.visible = true
		tail.visible = true
		rotate_part(tail, dir)
	elif not firstmove:
		var piece: Piece
		piece = Piece.new(piece_sources[(last_dir - dir) % 4])
		piece.place(head_coords, dir)
		piece.rotate(last_dir * PI/2)
		pieces.append(piece)
		add_child(piece)
		last_dir = dir
	rotate_part(head, dir)
	head_coords = new_coords
	if firstmove:
		tail_coords = new_coords
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
	if not eat and not firstmove and not eating_tail:
			tail_coords = pieces[0].coords
			tail.position = pieces[0].position
			rotate_part(tail, pieces[0].dir)
			remove_child(pieces[0])
			pieces.pop_front()

func rotate_part(part: Node2D, dir: DIR):
	part.rotation = dir*PI/2

func _on_eat_finished():
	$FakeFood.visible = false
	if(eating_tail):
		tail_eat.emit(pieces.size())

func _on_eat_changed():
	$FakeFood.visible = false
