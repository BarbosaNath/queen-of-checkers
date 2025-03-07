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
@onready var pieces: Node2D = $pieces
@onready var dots: Node2D = $dots
@onready var tmp_pieces: Node2D = $tmp_pieces

# Variables
# -num(black) 0 +num(white)

enum {
	SELECT_MOVE,
	CONFIRM_MOVE,
}

var gameState: BoardState
var playerState = SELECT_MOVE
var moves: Array[Dictionary] = []
var selected_piece: Vector2
var winner = 0

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
	for piece in pieces.get_children():
		piece.queue_free()

	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var piece = TEXTURE_HOLDER.instantiate()
			pieces.add_child(piece)
			piece.apply_scale(Vector2(PIECES_SCALE, PIECES_SCALE))
			piece.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2.0), -i * CELL_WIDTH - (CELL_WIDTH / 2.0))
					
			match gameState.board[i][j]:
				1: piece.texture = WHITE_PIECE
				-1: piece.texture = BLACK_PIECE
				2: piece.texture = WHITE_QUEEN
				-2: piece.texture = BLACK_QUEEN
				_: piece.texture = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return

			var cell_x = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
			var cell_y = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
			var cell = Vector2(cell_y, cell_x)

			if playerState == SELECT_MOVE:
				if (gameState.is_white_turn && gameState.is_white_piece(cell)
				|| !gameState.is_white_turn && gameState.is_black_piece(cell)):
					selected_piece = cell
					show_options()
					playerState = CONFIRM_MOVE
					
			elif playerState == CONFIRM_MOVE:
				var movement = BoardState.get_move_by_position(moves, cell)

				if movement != null:
					gameState = gameState.move(movement)
					
					animate_eaten_pieces(!gameState.is_white_turn)
					
					if (cell_y == 7 && gameState.is_white_piece(cell)):
						gameState.board[cell.x][cell.y] = 2
					elif (cell_y == 0 && gameState.is_black_piece(cell)):
						gameState.board[cell.x][cell.y] = -2

					gameState.is_white_turn = !gameState.is_white_turn

					if (!gameState.is_white_turn && GameConfig.is_against_ai):
						ai_action()
					
				playerState = SELECT_MOVE
				display_board()
				delete_dots()

func animate_eaten_pieces(are_white_pieces: bool):
	for eaten_piece in gameState.previous_move['eaten_pieces']:
		var tmp_animation_piece = TEXTURE_HOLDER.instantiate()
		tmp_pieces.add_child(tmp_animation_piece)
		tmp_animation_piece.apply_scale(Vector2(PIECES_SCALE, PIECES_SCALE))
		tmp_animation_piece.global_position = Vector2(
			 eaten_piece.y * CELL_WIDTH + (CELL_WIDTH / 2.0),
			-eaten_piece.x * CELL_WIDTH - (CELL_WIDTH / 2.0)
		)
		tmp_animation_piece.texture = WHITE_PIECE if are_white_pieces else BLACK_PIECE
		tmp_animation_piece.die()

func ai_action():
	var result = Minimax.minimax(gameState, GameConfig.dificulty, false)
	if (result[1] == []): return
	gameState = result[1][0]
	for col in gameState.BOARD_SIZE:
		if gameState.board[0][col] == -1:
			gameState.board[0][col] = -2
	gameState.is_white_turn = true
	animate_eaten_pieces(true)

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
		dot.apply_scale(Vector2(DOTS_SCALE, DOTS_SCALE))
		dot.global_position = Vector2(move['final_position'].y * CELL_WIDTH + (CELL_WIDTH / 2.0), - move['final_position'].x * CELL_WIDTH - (CELL_WIDTH / 2.0))
		dot.texture = WHITE_PIECE if gameState.is_white_turn else BLACK_PIECE
		dot.spawn()

func delete_dots():
	for dot in dots.get_children():
		dot.die()

func is_mouse_out():
	return (get_global_mouse_position().x < 0 || get_global_mouse_position().x > (CELL_WIDTH * BOARD_SIZE)
		|| get_global_mouse_position().y > 0 || get_global_mouse_position().y < - (CELL_WIDTH * BOARD_SIZE))

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
