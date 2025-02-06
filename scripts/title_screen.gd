extends Control

func _on_pvp_pressed() -> void:
	GameConfig.is_against_ai = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_pvia_pressed() -> void:
	GameConfig.is_against_ai = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")



func _on_quit_pressed() -> void:
	get_tree().quit()
