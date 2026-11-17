extends Area3D

@export var zona_id: int = 1

var entrenamiento: Node3D = null

var jack_dentro := false
var bocha_dentro := false


# ---------- ENTRENAMIENTO ----------
func set_entrenamiento(e):
	entrenamiento = e


# ---------- RESET ----------
func reset():
	jack_dentro = false
	bocha_dentro = false


# ---------- READY ----------
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# ---------- BODY ENTER ----------
func _on_body_entered(body):

	# ---------- JACK ----------
	if body.is_in_group("jack"):

		jack_dentro = true

		if entrenamiento:
			entrenamiento.registrar_jack()

	# ---------- BOCHA ----------
	elif body.is_in_group("bocha_color"):

		bocha_dentro = true

		if entrenamiento:
			entrenamiento.registrar_bocha(body)


# ---------- BODY EXIT ----------
func _on_body_exited(body):

	# ---------- JACK ----------
	if body.is_in_group("jack"):
		jack_dentro = false

	# ---------- BOCHA ----------
	elif body.is_in_group("bocha_color"):
		bocha_dentro = false
