extends Node
class_name Minimax

static func minimax(
	state: AIState,
	depth: int,
	max_player: bool,
	state_list: Array = []
	):
	if (depth == 0 || state.get_stop_condition()):
		return [state.get_current_winner(), state_list]

	if max_player:
		var max_eval = -INF
		var best_state_list = []
		for child in state.get_children():
			var result = minimax(child, depth - 1, false, state_list + [child])
			var _eval = result[0]
			if _eval > max_eval:
				max_eval = _eval
				best_state_list = result[1]
		return [max_eval, best_state_list]

	else:
		var min_eval = INF
		var best_state_list = []
		for child in state.get_children():
			var result = minimax(child, depth - 1, true, state_list + [child])
			var _eval = result[0]
			if _eval < min_eval:
				min_eval = _eval
				best_state_list = result[1]
		return [min_eval, best_state_list]
