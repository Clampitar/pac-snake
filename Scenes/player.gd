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
		rotate_part(head, dir)
	elif not firstmove:
		var piece: Piece
		var rotation: float = 0
		if dir == DIR.left:
			rotation = PI
			match last_dir:
				DIR.left:
					piece = gets()
				DIR.up:
					piece = getl()
					rotation = -PI/2
				DIR.down:
					piece = getr()
					rotation = PI/2
				_:
					print("left from right?")
			last_dir = DIR.left
			head.rotation = -PI
		elif dir == DIR.right:
			match last_dir:
				DIR.right:
					piece = gets()
				DIR.up:
					piece = getr()
					rotation = -PI/2
				DIR.down:
					piece = getl()
					rotation = PI/2
				_:
					print("right from left?")
			last_dir = DIR.right
			head.rotation = 0
		elif  dir == DIR.down:
			match last_dir:
				DIR.right:
					piece = getr()
				DIR.down:
					piece = gets()
					rotation = PI/2
				DIR.left:
					piece = getl()
					rotation = PI
			last_dir = DIR.down
			head.rotation = PI/2
		elif  dir == DIR.up:
			match last_dir:
				DIR.right:
					piece = getl()
				DIR.left:
					piece = getr()
					rotation = PI
				DIR.up:
					piece = gets()
					rotation = -PI/2
			last_dir = DIR.up
			head.rotation = -PI/2
		if(piece):
			piece.place(head_coords, last_dir)
			piece.rotate(rotation)
			pieces.append(piece)
			add_child(piece)

	head_coords = new_coords
	if firstmove:
		tail_coords = new_coords
	head.position = head_coords * 20
	if head is AnimatedSprite2D:
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
			pieces.remove_at(0)

func rotate_part(part: Node2D, dir: DIR):
	if dir == DIR.right:
		part.rotation = 0
	elif dir == DIR.left:
		part.rotation = PI
	elif dir == DIR.down:
		part.rotation = PI/2
	elif dir == DIR.up:
		part.rotation = -PI/2

func gets()  -> Sprite2D:
	return Piece.new("res://Assets/bodyStraight.png")

func getl()  -> Sprite2D:
	return Piece.new("res://Assets/bodyCornerLeft.png")

func getr()  -> Sprite2D:
	return Piece.new("res://Assets/bodyCornerRight.png")


func _on_eat_finished():
	$FakeFood.visible = false
	if(eating_tail):
		tail_eat.emit(pieces.size())

func _on_eat_changed():
	$FakeFood.visible = false
