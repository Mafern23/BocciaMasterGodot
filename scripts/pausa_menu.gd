extends CanvasLayer

var puede_pulsar := true
var pausado := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(_delta):
	# Tecla P para pausar / reanudar
	if Input.is_key_pressed(KEY_P) and puede_pulsar:
		puede_pulsar = false
		toggle_pause()

	# Permite volver a pulsar cuando se suelta la tecla
	if not Input.is_key_pressed(KEY_P):
		puede_pulsar = true

func toggle_pause():
	pausado = !pausado
	visible = pausado

	if pausado:
		Engine.time_scale = 0
		MusicManager.play_menu()
	else:
		Engine.time_scale = 1

# Botón 1 → Continuar
func _on_button_pressed():
	toggle_pause()

# Botón 2 → Reiniciar nivel
func _on_button_2_pressed() -> void:
	Engine.time_scale = 1
	pausado = false
	visible = false

	get_tree().reload_current_scene()

# Botón 3 → Volver al menú principal
func _on_button_3_pressed() -> void:
	Engine.time_scale = 1
	pausado = false
	visible = false

	MusicManager.play_menu()
	get_tree().change_scene_to_file("res://scenas/inicio.tscn")
