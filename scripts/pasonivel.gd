extends Control

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenas/nivel 2.tscn")

func _on_opcions_pressed() -> void:
	get_tree().change_scene_to_file("res://scenas/ajustes.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _ready():
	MusicManager.play_menu()
