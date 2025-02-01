extends Sprite2D

# Constants
const BOARD_SIZE = 8
const CELL_WIDTH = 250
const PIECES_SCALE = 0.1
const DOTS_SCALE = 0.05

const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")

const BLACK_PIECE = preload("res://assets/black_piece.png")
const BLACK_QUEEN = preload("res://assets/black_queen.png")
const WHITE_PIECE = preload("res://assets/white_piece.png")
const WHITE_QUEEN = preload("res://assets/white_queen.png")

# References
@onready var pieces = $pieces
@onready var dots = $dots
@onready var turn = $turn

# Variables
# -num(black) 0 +num(white)

enum {
	SELECT_MOVE,
	CONFIRM_MOVE,
}

var gameState: BoardState
var is_white_turn: bool = true
var playerState = SELECT_MOVE
var moves: Array[Dictionary] = []
var selected_piece: Vector2
@export var is_against_ai: bool = true

# Methods
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_board()
	display_board()


func start_board() -> void:
	var board_array: Array[Array] = []
	board_array.append([1, 0, 1, 0, 1, 0, 1, 0])
	board_array.append([0, 1, 0, 1, 0, 1, 0, 1])
	board_array.append([1, 0, 1, 0, 1, 0, 1, 0])
	board_array.append([0, 0, 0, 0, 0, 0, 0, 0])
	board_array.append([0, 0, 0, 0, 0, 0, 0, 0])
	board_array.append([0, -1, 0, -1, 0, -1, 0, -1])
	board_array.append([-1, 0, -1, 0, -1, 0, -1, 0])
	board_array.append([0, -1, 0, -1, 0, -1, 0, -1])
	gameState = BoardState.new(board_array)

func display_board():

	for child in pieces.get_children():
		child.queue_free()

	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.apply_scale(Vector2(PIECES_SCALE,PIECES_SCALE))
			holder.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2.0), -i * CELL_WIDTH - (CELL_WIDTH / 2.0))
					
			match gameState.board[i][j]:
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
			var cell = Vector2(cell_y, cell_x)

			if playerState==SELECT_MOVE:
				if (is_white_turn && is_white_piece(cell) 
				|| !is_white_turn && is_black_piece(cell)):
					selected_piece = cell
					show_options()
					playerState = CONFIRM_MOVE
					
			elif playerState==CONFIRM_MOVE:
				var movement = BoardState.get_move_by_position(moves, cell)
				if 'final_position' in movement: 
					gameState = gameState.move(movement)
					if (cell_y == 7 && gameState.is_white_piece(cell)):
						gameState.board[cell.x][cell.y] = 2
					elif (cell_y == 0 && gameState.is_black_piece(cell)):
						gameState.board[cell.x][cell.y] = -2
					is_white_turn = !is_white_turn
					gameState.is_white_turn = is_white_turn

					if (!is_white_turn && is_against_ai):
						var result = Minimax.minimax(gameState, 5, false)
						gameState = result[1][0]
						is_white_turn = true
						gameState.is_white_turn = true
				playerState=SELECT_MOVE
				display_board()
				delete_dots()


func show_options():
	moves = gameState.get_moves(selected_piece)
	if moves == []:
		playerState = SELECT_MOVE
		return
	show_dots()

func show_dots():
	for move in moves:
		var dot = TEXTURE_HOLDER.instantiate()
		dots.add_child(dot)
		dot.apply_scale(Vector2(DOTS_SCALE,DOTS_SCALE))
		dot.global_position = Vector2(move['final_position'].y * CELL_WIDTH + (CELL_WIDTH / 2.0), -move['final_position'].x * CELL_WIDTH - (CELL_WIDTH / 2.0))
		dot.texture = WHITE_PIECE if is_white_turn else BLACK_PIECE

func delete_dots():
	for dot in dots.get_children():
		dot.queue_free()

func is_mouse_out():
	return (get_global_mouse_position().x < 0 || get_global_mouse_position().x > (CELL_WIDTH * BOARD_SIZE)
		||  get_global_mouse_position().y > 0 || get_global_mouse_position().y < -(CELL_WIDTH * BOARD_SIZE))

func is_valid_position(pos : Vector2):
	return pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE

func is_white_piece(pos : Vector2):
	return is_valid_position(pos) && gameState.board[pos.x][pos.y] > 0

func is_black_piece(pos : Vector2):
	return is_valid_position(pos) && gameState.board[pos.x][pos.y] < 0
	
#TODO: Indicador de jogador. Vencedor atual. Calcular possiveis açoes. ^^
