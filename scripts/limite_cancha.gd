extends Area3D

@export var modo_entrenamiento := false

func _ready():

	body_exited.connect(_on_body_exited)

	if modo_entrenamiento:
		print("🟡 LimiteCancha desactivado en entrenamiento")


func _on_body_exited(body: Node) -> void:

	if modo_entrenamiento:
		return

	if body.is_in_group("jack"):

		print("🚨 Jack salió de la cancha")
