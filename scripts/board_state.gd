extends AIState
class_name BoardState

const BOARD_SIZE = 8

var board: Array[Array]
var is_white_turn: bool

func _init(_board: Array[Array], _is_white_turn: bool = true) -> void:
	self.board = _board
	self.is_white_turn = _is_white_turn

func get_children() -> Array[AIState]:
	var states: Array[AIState] = []

	for row in range(board.size()):
		for col in range(board[row].size()):
			var cell: Vector2 = Vector2(row, col)

			if (is_white_turn && is_black_piece(cell)
			|| !is_white_turn && is_white_piece(cell)
			|| is_empty(cell)): continue

			var moves = get_moves(cell)

			for movement in moves:
				var new_state = move(movement)
				new_state.is_white_turn = !new_state.is_white_turn
				states.append(new_state)

	return states

func get_stop_condition() -> bool:
	var quantity_white = 0
	var quantity_black = 0
	
	for row in board:
		for space in row:
			quantity_white += 1 if space > 0 else 0
			quantity_black += 1 if space < 0 else 0

	return quantity_white == 0 || quantity_black == 0

func get_current_winner() -> int:
	var quantity_white = 0
	var quantity_black = 0
	
	for row in board:
		for space in row:
			quantity_white += 1 if space > 0 else 0
			quantity_white += 4 if space > 1 else 0
			quantity_black += 1 if space < 0 else 0
			quantity_black += 4 if space < 1 else 0

	return quantity_white - quantity_black

# Validation functions =========================================================
func is_valid_position(pos: Vector2):
	return pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE

func is_empty(pos: Vector2):
	return is_valid_position(pos) && board[pos.x][pos.y] == 0

func is_white_piece(pos: Vector2):
	return is_valid_position(pos) && board[pos.x][pos.y] > 0

func is_black_piece(pos: Vector2):
	return is_valid_position(pos) && board[pos.x][pos.y] < 0

func is_enemy(pos: Vector2):
	return is_black_piece(pos) if is_white_turn else is_white_piece(pos)

# Move functions ===============================================================
func move(movement: Dictionary) -> BoardState:
	var new_board = board.duplicate(true)
	var initial_position = movement['initial_position']
	var final_position = movement['final_position']
	var eaten_pieces = movement['eaten_pieces']

	for eaten_piece in eaten_pieces:
		new_board[eaten_piece.x][eaten_piece.y] = 0

	new_board[final_position.x][final_position.y] = new_board[initial_position.x][initial_position.y]
	new_board[initial_position.x][initial_position.y] = 0

	return BoardState.new(new_board, is_white_turn)

static func get_move_by_position(moves: Array[Dictionary], pos: Vector2):
	for movement in moves:
		if (movement['final_position'] == pos): return movement
	return []

func get_moves(piece: Vector2):
	var _moves: Array[Dictionary] = []
	match (abs(board[piece.x][piece.y])):
		1: _moves = pieces_moves(piece)
		2: _moves = queen_moves(piece)
	return _moves

func pieces_moves(piece: Vector2, multijump: bool = false) -> Array[Dictionary]:
	var normal_moves: Array[Dictionary] = []
	var eating_moves: Array[Dictionary] = []

	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	var valid_directions: Array[Vector2]

	if (is_white_piece(piece)):
		valid_directions = [Vector2(1, 1), Vector2(1, -1)]
	elif (is_black_piece(piece)):
		valid_directions = [Vector2(-1, 1), Vector2(-1, -1)]

	for direction in directions:
		var pos = piece + direction
		if !multijump && is_valid_position(pos) && is_empty(pos) && direction in valid_directions:
			normal_moves.append({
				'initial_position': piece,
				'final_position': pos,
				'eaten_pieces': []
			})

		elif is_enemy(pos):
			var eat_pos = pos + direction
			if is_valid_position(eat_pos) and is_empty(eat_pos):
				var eaten_pieces = [pos]
				
				eating_moves.append({
					'initial_position': piece,
					'final_position': eat_pos,
					'eaten_pieces': eaten_pieces
				})

				var multijump_state = move({
					'initial_position': piece,
					'final_position': eat_pos,
					'eaten_pieces': eaten_pieces
				});
				var multijump_moves = multijump_state.pieces_moves(eat_pos, true)
				for movement in multijump_moves:
					movement['initial_position'] = piece
					movement['eaten_pieces'] += eaten_pieces
				eating_moves = multijump_moves + eating_moves
				
				
	return eating_moves if eating_moves.size() > 0 else normal_moves


func queen_moves(
	piece: Vector2, 
	multijump: bool = false,
	prev_eaten_pieces: Array = [], 
	last_direction: Vector2 = Vector2.ZERO
	):
	var normal_moves: Array[Dictionary] = []
	var eating_moves: Array[Dictionary] = []

	var directions: Array[Vector2] = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

	for direction in directions:
		var pos = piece + direction
		while is_valid_position(pos):
			if is_empty(pos):
				if (!multijump):
					normal_moves.append({
						'initial_position': piece,
						'final_position': pos,
						'eaten_pieces': [],
					})
				elif (direction == last_direction): 
					eating_moves.append({
						'initial_position': piece,
						'final_position': pos,
						'eaten_pieces': prev_eaten_pieces,
					})


			elif is_enemy(pos):
				var eat_pos = pos + direction
				if is_valid_position(eat_pos) and is_empty(eat_pos):
					var eaten_pieces = [pos] + prev_eaten_pieces
					
					eating_moves.append({
						'initial_position': piece,
						'final_position': eat_pos,
						'eaten_pieces': eaten_pieces
					})

					var multijump_state = move({
						'initial_position': piece,
						'final_position': eat_pos,
						'eaten_pieces': eaten_pieces
					});
					var multijump_moves = multijump_state.queen_moves(eat_pos, true, eaten_pieces, direction)
					for movement in multijump_moves:
						movement['initial_position'] = piece
						movement['eaten_pieces'] += eaten_pieces
					eating_moves = multijump_moves + eating_moves
			else: break
			pos = pos + direction
					
				
	return eating_moves if eating_moves.size() > 0 else normal_moves
