extends Area3D

@export var jack: RigidBody3D

@onready var Game = get_node("/root/Game")

# tamaño real de la cancha
@export var limite_x := 6.0
@export var limite_z := 12.0

func _ready():
	body_exited.connect(_on_body_exited)

func _on_body_exited(body: Node) -> void:

	if not body is RigidBody3D:
		return

	# esperar un frame para confirmar
	await get_tree().process_frame

	if not is_instance_valid(body):
		return

	# 🔥 comprobar que realmente salió
	var fuera = (
		abs(body.global_position.x) > limite_x
		or abs(body.global_position.z) > limite_z
	)

	if not fuera:
		return

	# =========================
	# JACK FUERA
	# =========================
	if body == jack:

		print("🚨 Jack salió de la cancha")

		Game.jack_fuera()

		return

	# =========================
	# BOCHA FUERA
	# =========================
	if body.is_in_group("bocha_roja") or body.is_in_group("bocha_azul"):

		print("🚨 BOCHA FUERA")

		var juego = get_tree().current_scene

		if juego and juego.has_method("mostrar_fuera"):
			juego.mostrar_fuera()

		Game.registrar_bocha_detenida()

		body.queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bocha_roja") or body.is_in_group("bocha_azul"):

		print("🚨 BOCHA FUERA")

		var juego = get_tree().current_scene

		if juego and juego.bochas.has(body):
			juego.bochas.erase(body)

		if juego and juego.has_method("mostrar_fuera"):
			juego.mostrar_fuera()

		body.queue_free()
