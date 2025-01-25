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

enum GameStateEnum {
	SELECT_MOVE,
	CONFIRM_MOVE,
}

var board: Array
var is_white_turn: bool
var state: GameStateEnum
var moves = []
var selected_piece: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board.append([1, 0, 1, 0, 1, 0, 1, 0])
	board.append([0, 1, 0, 1, 0, 1, 0, 1])
	board.append([1, 0, 1, 0, 1, 0, 1, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, -1, 0, -1, 0, -1, 0, -1])
	board.append([-1, 0, -1, 0, -1, 0, -1, 0])
	board.append([0, -1, 0, -1, 0, -1, 0, -1])

	display_board()

func display_board():
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.apply_scale(Vector2(0.1,0.1))
			holder.global_position = Vector2((j-4) * CELL_WIDTH + (CELL_WIDTH / 2), (-i+3) * CELL_WIDTH + (CELL_WIDTH / 2))
					
			match board[i][j]:
				1:
					holder.texture = WHITE_PIECE
				-1:
					holder.texture = BLACK_PIECE
				2:
					holder.texture = WHITE_QUEEN
				-2:
					holder.texture = BLACK_QUEEN
				_:
					holder.texture = null
