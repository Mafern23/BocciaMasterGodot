extends Control



func _on_juego_libre_pressed() -> void:
	get_tree().change_scene_to_file("res://scenas/juego.tscn")



func _ready():
	MusicManager.play_menu()


func _on_nivel_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenas/nivel 1.tscn")
