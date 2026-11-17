extends RigidBody3D

signal lanzada

@onready var game = get_tree().root.get_node("Game")

@export var speed_multiplier := 1.5
@export var masa_bocha := 1.0
@export var umbral_parada := 0.2

var direccion := Vector3.ZERO
var fue_lanzada := false

# 🔥 control de movimiento
var en_movimiento := false

# ---------- READY ----------
func _ready():
	print("🧠 Registrando jack en GameManager")
	game.registrar_jack(self)

	if masa_bocha <= 0:
		masa_bocha = 1.0

	mass = masa_bocha

	add_to_group("jack")

# ---------- LANZAR ----------
func lanzar(dir: Vector3, fuerza: float):

	Game.registrar_bocha_en_movimiento()
	if fue_lanzada:
		return

	fue_lanzada = true
	en_movimiento = false

	direccion = dir.normalized()

	# 🔥 movimiento
	linear_velocity = direccion * fuerza * speed_multiplier

	emit_signal("lanzada")

# ---------- FÍSICA ----------
func _physics_process(_delta):

	if not fue_lanzada:
		return

	# 🔥 detectar movimiento real
	if linear_velocity.length() > 0.1:
		en_movimiento = true

	# 🔥 detectar parada
	if en_movimiento and linear_velocity.length() < umbral_parada:

		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

		print("⚪ Jack detenida")

	
		fue_lanzada = false
		en_movimiento = false

		# 🔥 CLAVE: liberar sistema (SIN contador)
		game.registrar_bocha_detenida()

		set_physics_process(false)

func reset_estado():

	fue_lanzada = false
	en_movimiento = false

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
