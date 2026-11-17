extends CharacterBody3D

@onready var Game = get_tree().root.get_node("Game")

# 🎥 Cámara del mundo
@onready var camera_mundo: Camera3D = null

# ---------- ESCENAS ----------
@export var jack_scene: PackedScene
@export var bocha_roja_scene: PackedScene

# ---------- FUERZA ----------
@export var min_force := 0.5
@export var max_force := 50.0
@export var charge_speed := 25.0
@export var max_red_balls := 6

# ---------- SPAWN ----------
@export var distancia_delante := 1.5
@export var altura_spawn := 1.2

# ---------- CONTROL ----------
@export var usar_switch_camera := true
@export var usar_toggle_jack := false

# ---------- CÁMARA ----------
@export var mouse_sensitivity := 0.002

var rotation_y := 0.0
var camara_activa := true

# ---------- NODOS ----------
@onready var camera_player: Camera3D = $CamaraPivot/Camera3D

# ---------- ESTADO ----------
var jack_lanzado := false
var red_balls_thrown := 0

var charging := false
var current_force := 0.0

var lanzar_jack := true
var ya_lanzo := false

# =========================
# READY
# =========================
func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	camera_player.make_current()

	if camera_mundo is Camera3D:
		camera_mundo.current = false

	add_to_group("player")

	print("🎥 Cámara mundo:", camera_mundo)

# =========================
# INPUT
# =========================
func _unhandled_input(event):

	# ---------- PAUSA ----------
	if event.is_action_pressed("pause_game"):

		get_tree().paused = !get_tree().paused

		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("⏸️ Juego pausado")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			print("▶️ Juego reanudado")

		return

	# ---------- CAMBIO CÁMARA ----------
	if event.is_action_pressed("switch_camera") and usar_switch_camera:

		if Game.modo_actual == Game.ModoJuego.JUEGO_LIBRE:

			camara_activa = !camara_activa

			if camara_activa:

				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

				if camera_mundo is Camera3D:
					camera_mundo.current = false

				camera_player.make_current()

			else:

				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

				camera_player.current = false

				if camera_mundo is Camera3D:
					camera_mundo.make_current()

		return

	# ---------- CAMBIO BOCHA ----------
	if event.is_action_pressed("toggle_jack"):

		if Game.modo_actual == Game.ModoJuego.NIVEL:

			lanzar_jack = !lanzar_jack

			if lanzar_jack:
				print("⚪ Jack")
			else:
				print("🔴 Bocha")

		return

	# ---------- SOLO TURNO ROJO ----------
	if Game.turno_actual != "rojo":
		return

	# ---------- BLOQUEO ----------
	if not Game.puede_lanzar_bocha():
		return

	# ---------- CARGAR ----------
	if event.is_action_pressed("ui_accept"):
		charging = true

	# ---------- LANZAR ----------
	if event.is_action_released("ui_accept"):

		charging = false

		_launch_current()

		current_force = 0.0

# =========================
# CARGA
# =========================
func _process(delta):

	if charging and Game.puede_lanzar_bocha():

		current_force += charge_speed * delta

		current_force = clamp(
			current_force,
			min_force,
			max_force
		)

# =========================
# CÁMARA
# =========================
func _input(event):

	if not camara_activa:
		return

	if event is InputEventMouseMotion:

		rotation_y -= event.relative.x * mouse_sensitivity

		rotation.y = rotation_y

# =========================
# LANZAMIENTO
# =========================
func _launch_current():

	print("🚨 LLAMANDO A _launch_current")

	if current_force <= 0:
		current_force = min_force

	var forward = -camera_player.global_transform.basis.z

	forward.y = 0.35

	forward = forward.normalized()

	if forward == Vector3.ZERO:
		return

	var spawn = (
		camera_player.global_position
		+ forward * distancia_delante
		+ Vector3(0, altura_spawn, 0)
	)

	# =====================
	# JACK
	# =====================
	if lanzar_jack and not jack_lanzado:

		var jack = jack_scene.instantiate()

		get_tree().current_scene.add_child(jack)

		var nivel = get_tree().current_scene

		if nivel.has_method("set_jack"):
			nivel.set_jack(jack)

		jack.global_position = spawn

		Game.registrar_jack(jack)

		Game.iniciar_lanzamiento(true)

		if jack.has_method("lanzar"):
			jack.lanzar(forward, current_force)

		jack.set_physics_process(true)

		jack_lanzado = true
		lanzar_jack = false

		return

	# =====================
	# BOCHA
	# =====================

	if Game.bochas_rojas_restantes <= 0:

		print("⚠️ Sin bochas")

		return

	var obj = bocha_roja_scene.instantiate()

	obj.equipo = "rojo"

	obj.add_to_group("bocha_roja")

	obj.name = "bocha roja"

	get_tree().current_scene.add_child(obj)

	obj.global_position = spawn

	obj.add_collision_exception_with(self)

	var juego = get_tree().current_scene

	if juego.has_method("registrar_bocha"):
		juego.registrar_bocha(obj)

	Game.registrar_bocha(obj)

	if obj.has_method("lanzar"):

		obj.lanzar(forward, current_force)

	_enable_collision_later(obj)

	red_balls_thrown += 1

	print("🔴 Restantes:", max_red_balls - red_balls_thrown)

	Game.bochas_rojas_restantes -= 1

	Game.iniciar_lanzamiento(false)
# =========================
# COLISIÓN
# =========================
func _enable_collision_later(obj):

	await get_tree().create_timer(0.15).timeout

	if is_instance_valid(obj):

		obj.set_deferred("collision_layer", 1)
		obj.set_deferred("collision_mask", 1)
