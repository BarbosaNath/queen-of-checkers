extends AIState
class_name BoardState

const BOARD_SIZE = 8

var board: Array[Array]
var is_white_turn: bool

func _init(_board: Array[Array], _is_white_turn: bool = true) -> void:
	self.board = _board
	self.is_white_turn = _is_white_turn

func get_children() -> Array[AIState]: return []
func get_stop_condition(): pass
func get_current_winner(_state: AIState): pass

static func get_actions(piece: Vector2) -> Array[Dictionary]: return []

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

# func pieces_moves(piece: Vector2):
# 	var _normal_moves: Array[Dictionary] = []
# 	var _eating_moves: Array[Dictionary] = []

# 	var white_directions = [Vector2(1, 1), Vector2(1, -1)]
# 	var black_directions = [Vector2(-1, -1), Vector2(-1, 1)]
# 	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

# 	for direction in directions:
# 		var pos = piece
# 		pos += direction
		
# 		if !is_valid_position(pos): continue

# 		if is_empty(pos):
# 			if is_white_turn && is_white_piece(piece):
# 				if direction in white_directions:
# 					_normal_moves.append({'initial_position': piece, 'final_position': pos, 'eaten_pieces': []})
# 			elif !is_white_turn && is_black_piece(piece):
# 				if direction in black_directions:
# 					_normal_moves.append({'initial_position': piece, 'final_position': pos, 'eaten_pieces': []})

# 		var _eaten_pieces = []
# 		while is_enemy(pos):
# 			var _eaten_piece = pos
# 			pos += direction
# 			if is_valid_position(pos) && is_empty(pos):
# 				_eaten_pieces.append(_eaten_piece)
# 				var new_board_state = move({'initial_position': piece, 'final_position': pos, 'eaten_pieces': _eaten_pieces})
# 				var subsequent_moves = new_board_state.get_moves(pos)
# 				if subsequent_moves.size() > 0:
# 					for subsequent_move in subsequent_moves:
# 						_eating_moves.append({'initial_position': piece, 'final_position': subsequent_move['final_position'], 'eaten_pieces': _eaten_pieces + subsequent_move['eaten_pieces']})
# 				else:
# 					_eating_moves.append({'initial_position': piece, 'final_position': pos, 'eaten_pieces': _eaten_pieces})
# 				break
# 			else:
# 				break

# 	return _eating_moves + _normal_moves

# TODO: Fix multijump and eating pieces
func pieces_moves(piece: Vector2) -> Array[Dictionary]:
	var normal_moves: Array[Dictionary] = []
	var eating_moves: Array[Dictionary] = []

	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]

	for direction in directions:
		var pos = piece + direction
		if is_valid_position(pos) and is_empty(pos):
			normal_moves.append({
				'initial_position': piece,
				'final_position': pos,
				'eaten_pieces': []
			})

		elif is_enemy(pos):
			var eat_pos = pos + direction
			if is_valid_position(eat_pos) and is_empty(eat_pos):
				var eaten_pieces = [pos]
				
				var new_board_state = move({
					'initial_position': piece,
					'final_position': eat_pos,
					'eaten_pieces': eaten_pieces
				})
				
				var subsequent_moves = new_board_state.get_moves(eat_pos)
				if subsequent_moves.size() > 0:
					for subsequent_move in subsequent_moves:
						eating_moves.append({
							'initial_position': piece,
							'final_position': subsequent_move['final_position'],
							'eaten_pieces': eaten_pieces + subsequent_move['eaten_pieces']
						})
				else:
					eating_moves.append({
						'initial_position': piece,
						'final_position': eat_pos,
						'eaten_pieces': eaten_pieces
					})

	return eating_moves if eating_moves.size() > 0 else normal_moves


func queen_moves(piece: Vector2):
	var _normal_moves = []
	var _eating_moves = []
	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	for direction in directions:
		var pos = piece
		pos += direction
		
		while is_valid_position(pos):
			if is_empty(pos):
				_normal_moves.append({'final_position': pos, 'eaten_pieces': []})

			var _eaten_pieces = []
			while is_enemy(pos):
				var _eaten_piece = pos
				pos += direction
				while is_valid_position(pos):
					_eaten_pieces.append(_eaten_piece)
					var new_board_state = move({'initial_position': piece, 'final_position': pos, 'eaten_pieces': _eaten_pieces})
					var subsequent_moves = new_board_state.get_moves(pos)
					if subsequent_moves.size() > 0:
						for subsequent_move in subsequent_moves:
							_eating_moves.append({'initial_position': piece, 'final_position': subsequent_move['final_position'], 'eaten_pieces': _eaten_pieces + subsequent_move['eaten_pieces']})
					else:
						_eating_moves.append({'initial_position': piece, 'final_position': pos, 'eaten_pieces': _eaten_pieces})

			pos += direction
				
	return _eating_moves + _normal_moves
