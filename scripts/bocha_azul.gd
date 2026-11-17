extends RigidBody3D

var equipo = ""

signal lanzada

@onready var game = get_node("/root/Game")

@export var speed_multiplier := 1.5
@export var masa_bocha := 1.0
@export var umbral_parada := 0.2

var direccion := Vector3.ZERO
var fue_lanzada := false
var ya_evaluada := false
var en_movimiento := false


func _ready():
	mass = masa_bocha

	# grupo correcto para calcular distancia
	add_to_group("azul")

	# asegurar que physics_process funcione
	set_physics_process(true)

	# registrar movimiento
	game.registrar_bocha_en_movimiento()


func lanzar(dir: Vector3, fuerza: float):

	# evitar doble lanzamiento
	if fue_lanzada:
		return

	fue_lanzada = true
	ya_evaluada = false
	en_movimiento = false

	direccion = dir.normalized()

	# lanzar realmente la bocha
	linear_velocity = direccion * fuerza * speed_multiplier
	angular_velocity = Vector3.ZERO
	sleeping = false

	emit_signal("lanzada")

	print("⚪ Lanzamiento bocha")


func _physics_process(_delta):

	if not fue_lanzada:
		return

	if ya_evaluada:
		return

	# detectar que sí empezó a moverse
	if linear_velocity.length() > 0.1:
		en_movimiento = true

	# si cayó fuera de la cancha
	if global_position.y < -5:

		ya_evaluada = true
		fue_lanzada = false
		en_movimiento = false

		print("🔵 Bocha azul fuera de cancha")

		game.registrar_bocha_detenida()

		queue_free()
		return

	# detectar parada real
	if en_movimiento and linear_velocity.length() < umbral_parada:

		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

		ya_evaluada = true
		fue_lanzada = false
		en_movimiento = false

		print("🔵 Bocha azul detenida")

		game.registrar_bocha_detenida()
