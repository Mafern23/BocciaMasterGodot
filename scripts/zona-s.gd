extends Area3D

@export var zona_id: int = 1
var entrenamiento: Node3D = null

func set_entrenamiento(e):
	entrenamiento = e
	print("[Zona] Entrenamiento asignado zona", zona_id)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if entrenamiento == null:
		return

	if body.is_in_group("jack"):
		entrenamiento.registrar_jack(zona_id)

	elif body.is_in_group("bocha_color"):
		entrenamiento.registrar_bocha(zona_id)
