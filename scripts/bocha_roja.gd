extends RigidBody3D

var equipo = ""

signal lanzada

@onready var game = get_tree().root.get_node("Game")

@export var speed_multiplier := 1.5
@export var masa_bocha := 1.0
@export var umbral_parada := 0.2

var direccion := Vector3.ZERO
var fue_lanzada := false
var ya_evaluada := false


# 🔥 CLAVE
var en_movimiento := false

func _ready():
	if masa_bocha <= 0:
		masa_bocha = 1.0

	mass = masa_bocha
	add_to_group("bocha_roja")

# ---------- LANZAR ----------
func lanzar(dir: Vector3, fuerza: float):

	# ❌ NO bloquear aquí (esto rompe el flujo)
	if fue_lanzada:
		return

	fue_lanzada = true
	ya_evaluada = false
	en_movimiento = false

	direccion = dir.normalized()

	# 🔥 movimiento
	linear_velocity = direccion * fuerza * speed_multiplier
	angular_velocity = direccion.cross(Vector3.UP) * fuerza * 2.0

	emit_signal("lanzada")

	# 🔥 SOLO AQUÍ se registra
	game.registrar_bocha_en_movimiento()

# ---------- FÍSICA ----------
func _physics_process(_delta):

	if not fue_lanzada:
		return

	if ya_evaluada:
		return

	# 🔥 detectar movimiento real
	if linear_velocity.length() > 0.1:
		en_movimiento = true

	# 🔥 detectar parada real
	if en_movimiento and linear_velocity.length() < umbral_parada:

		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

		ya_evaluada = true
		fue_lanzada = false
		en_movimiento = false

		print("🔴 Bocha roja detenida")

		game.registrar_bocha_detenida()

		set_physics_process(false)
