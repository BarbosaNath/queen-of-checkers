extends Node
class_name Minimax

func minimax(state: AIState, depth: int, max_player: bool):
	if (depth == 0 || state.get_stop_condition()):
		return state.get_current_winner(state)

	if max_player:
		var max_eval = -INF
		for child in state.get_children():
			var _eval = minimax(child, depth - 1, false)
			max_eval = max(max_eval, _eval)
			return max_eval

	else:
		var min_eval = INF
		for child in state.get_children():
			var _eval = minimax(child, depth - 1, true)
			min_eval = min(min_eval, _eval)
			return min_eval
