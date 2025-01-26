extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 250

const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")

const BLACK_PIECE = preload("res://assets/black_piece.png")
const BLACK_QUEEN = preload("res://assets/black_queen.png")
const WHITE_PIECE = preload("res://assets/white_piece.png")
const WHITE_QUEEN = preload("res://assets/white_queen.png")

@onready var pieces = $pieces
@onready var dots = $dots
@onready var turn = $turn

#variables
# -num(black) 0 +num(white)

enum GameState {
	SELECT_MOVE,
	CONFIRM_MOVE,
}

var board: Array
var is_white_turn: bool = true
var state: GameState = GameState.SELECT_MOVE
var moves = []
var eating_moves = []
var selected_piece: Vector2
var eated_piece: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_board()
	display_board()


func start_board() -> void:
	board.append([1, 0, 1, 0, 1, 0, 1, 0])
	board.append([0, 1, 0, 1, 0, 1, 0, 1])
	board.append([1, 0, 1, 0, 1, 0, 1, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, -1, 0, -1, 0, -1, 0, -1])
	board.append([-1, 0, -1, 0, -1, 0, -1, 0])
	board.append([0, -1, 0, -1, 0, -1, 0, -1])

func display_board():

	for child in pieces.get_children():
		child.queue_free()

	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.apply_scale(Vector2(0.1,0.1))
			holder.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2), -i * CELL_WIDTH - (CELL_WIDTH / 2))
					
			match board[i][j]:
				1:  holder.texture = WHITE_PIECE
				-1: holder.texture = BLACK_PIECE
				2:  holder.texture = WHITE_QUEEN
				-2: holder.texture = BLACK_QUEEN
				_:  holder.texture = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return
			var cell_x = snapped(get_global_mouse_position().x, 0) /  CELL_WIDTH
			var cell_y = abs(snapped(get_global_mouse_position().y, 0)) /  CELL_WIDTH

			
			if state==GameState.SELECT_MOVE:
				if (is_white_turn && board[cell_y][cell_x] > 0 || !is_white_turn && board[cell_y][cell_x] < 0):
					selected_piece = Vector2(cell_y, cell_x)
					show_options()
					state = GameState.CONFIRM_MOVE
			elif state==GameState.CONFIRM_MOVE: 
				set_move(cell_y, cell_x)


func show_options():
	var move_types = get_moves()
	moves = move_types['moves']
	eating_moves = move_types['eating_moves'] 
	if moves == [] && eating_moves == []:
		state = GameState.SELECT_MOVE
		return
	show_dots()


func delete_dots():
	for dot in dots.get_children():
		dot.queue_free()

func set_move(cell_y, cell_x):
	for move in moves:
		if move.x == cell_y && move.y == cell_x:
			board[cell_y][cell_x] = board[selected_piece.x][selected_piece.y]
			board[selected_piece.x][selected_piece.y] = 0
			is_white_turn = !is_white_turn
			display_board()
			break

	for eat_move in eating_moves:
		var eat_move_position = eat_move['position']
		if eat_move_position.x == cell_y && eat_move_position.y == cell_x:
			var is_queen = abs(board[selected_piece.x][selected_piece.y]) == 2
			board[cell_y][cell_x] = board[selected_piece.x][selected_piece.y]
			board[selected_piece.x][selected_piece.y] = 0
			board[eat_move['eaten_piece'].x][eat_move['eaten_piece'].y] = 0

			delete_dots()
			display_board()

			selected_piece = Vector2(eat_move_position.x, eat_move_position.y)

			var _eat_moves = queen_moves()['eating_moves'] if is_queen else pieces_moves()['eating_moves']
			if _eat_moves == []:
				is_white_turn = !is_white_turn
				break

			moves = []
			eating_moves = _eat_moves
			show_dots()

	delete_dots()
	state = GameState.SELECT_MOVE	

func get_moves(): 
	var _moves = []
	var _eating_moves = []
	match (abs(board[selected_piece.x][selected_piece.y])):
		1: 
			var move_types = pieces_moves()
			_moves = move_types['moves']
			_eating_moves = move_types['eating_moves']
		2: _moves = queen_moves()

	return {
			'moves': _moves,
			'eating_moves':_eating_moves
		}
	
func is_valid_position(pos : Vector2):
	return pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE

func is_empty(pos : Vector2):
	return board[pos.x][pos.y] == 0

func is_enemy(pos : Vector2):
	if is_white_turn:
		return board[pos.x][pos.y] < 0
	else:
		return board[pos.x][pos.y] > 0

func pieces_moves():
	var _moves = []
	var _eating_moves = []

	var white_directions = [Vector2(1,1), Vector2(1,-1)]
	var black_directions = [Vector2(-1,-1), Vector2(-1,1)]
	var directions = [Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)]
	for direction in directions:
		var pos = selected_piece
		pos += direction
		
		if !is_valid_position(pos): continue

		if is_empty(pos):
			if is_white_turn && board[selected_piece.x][selected_piece.y] > 0:
				if direction in white_directions:
					_moves.append(pos)
			elif !is_white_turn && board[selected_piece.x][selected_piece.y] < 0:
				if direction in black_directions:
					_moves.append(pos)

		elif is_enemy(pos):
			pos += direction
			if is_valid_position(pos) && is_empty(pos):
				_eating_moves.append({'position':pos, 'eaten_piece': pos - direction })

	return {
			'moves': _moves,
			'eating_moves':_eating_moves
		}

func queen_moves():
	var _moves = []
	var directions = [Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)]
	for direction in directions:
		var pos = selected_piece
		pos += direction
		
		while is_valid_position(pos):
			if is_empty(pos):
				_moves.append(pos)
			elif is_enemy(pos):
				pos += direction
				if is_valid_position(pos) && is_empty(pos):
					_moves.append(pos)
				
	return _moves


func show_dots():
	for move in moves:
		var dot = TEXTURE_HOLDER.instantiate()
		dots.add_child(dot)
		dot.apply_scale(Vector2(0.05,0.05))
		dot.global_position = Vector2(move.y * CELL_WIDTH + (CELL_WIDTH / 2), -move.x * CELL_WIDTH - (CELL_WIDTH / 2))
		dot.texture = WHITE_PIECE if is_white_turn else BLACK_PIECE

	for eat_move in eating_moves:
		var move = eat_move['position']
		var dot = TEXTURE_HOLDER.instantiate()
		dots.add_child(dot)
		dot.apply_scale(Vector2(0.05,0.05))
		dot.global_position = Vector2(move.y * CELL_WIDTH + (CELL_WIDTH / 2), -move.x * CELL_WIDTH - (CELL_WIDTH / 2))
		dot.texture = WHITE_PIECE if is_white_turn else BLACK_PIECE


func is_mouse_out():
	return (
			get_global_mouse_position().x < 0 || get_global_mouse_position().x > (CELL_WIDTH * BOARD_SIZE)
		||  get_global_mouse_position().y > 0 || get_global_mouse_position().y < -(CELL_WIDTH * BOARD_SIZE)
		)
