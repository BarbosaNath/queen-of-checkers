extends Control

@onready var easy: Button = $VBoxContainer/easy
@onready var medium: Button = $VBoxContainer/medium
@onready var hard: Button = $VBoxContainer/hard
@onready var impossible: Button = $VBoxContainer/impossible
@onready var margin_container: MarginContainer = $VBoxContainer/MarginContainer
@onready var back: Button = $VBoxContainer/MarginContainer/back

@onready var pvp: Button = $VBoxContainer/pvp
@onready var pvia: Button = $VBoxContainer/pvia
@onready var quit: Button = $VBoxContainer/quit

@onready var main_buttons: Array[Button] = [pvp, pvia, quit]
@onready var dificulty_buttons: Array[Button] = [easy, medium, hard, impossible, back]

func _on_pvp_pressed() -> void:
	GameConfig.is_against_ai = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_pvia_pressed() -> void:
	GameConfig.is_against_ai = true
	for button in main_buttons:
		button.visible = false
		
	margin_container.visible = true
	for button in dificulty_buttons:
		button.visible = true
		
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_easy_pressed() -> void:
	GameConfig.dificulty = 1
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_medium_pressed() -> void:
	GameConfig.dificulty = 2
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_hard_pressed() -> void:
	GameConfig.dificulty = 3
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_impossible_pressed() -> void:
	GameConfig.dificulty = 4
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed() -> void:
	for button in main_buttons:
		button.visible = true
		
	margin_container.visible = false
	for button in dificulty_buttons:
		button.visible = false
