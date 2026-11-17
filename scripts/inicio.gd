extends Control
@onready var control: VBoxContainer = $control
@onready var panel: Panel = $Panel


func _ready():
	control.visible = true
	panel.visible = false
	MusicManager.play_menu()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenas/nivel.tscn")

func _on_opcions_pressed() -> void:
	print("ajustes")
	control.visible = false
	panel.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_volver_pressed() -> void:
	_ready()


func _on_volumen_value_changed(value: float) -> void:

	print(value)

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		value
	)
