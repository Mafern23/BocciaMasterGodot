extends CharacterBody3D

@onready var Game = get_tree().root.get_node("Game")

# ---------- CONFIG ----------
@export var bocha_scene: PackedScene
@export var jack_scene: PackedScene

@export var fuerza_base := 1.0
@export var fuerza_max := 9.0

# ---------- ESTADO ----------
var puede_lanzar := true
var ya_lanzo := false

# ==============================
# READY
# ==============================
func _ready():

	print("🤖 IA lista")

	add_to_group("ia")

# ==============================
# OBTENER JACK
# ==============================
func obtener_jack():

	return Game.jack_actual

# ==============================
# INTENTAR LANZAR
# ==============================
func intentar_lanzar():

	# 🔒 esperar físicas
	if not Game.puede_lanzar_bocha():
		return

	print("🚀 IA intentando lanzar...")

	if not puede_lanzar:
		return

	if ya_lanzo:
		return

	var jack = obtener_jack()

	if jack == null:
		print("❌ no hay jack")
		return

	if bocha_scene == null:
		print("❌ bocha_scene NULL")
		return

	ya_lanzo = true
	puede_lanzar = false

	Game.bochas_azules_restantes -= 1
	Game.iniciar_lanzamiento(false)

	# ---------- POSICIÓN ----------
	var origen = global_transform.origin + Vector3(2.9, 1.2, 0.3)

	# ---------- OBJETIVO ----------
	var objetivo = jack.global_transform.origin

	# ---------- DIRECCIÓN ----------
	var direccion = (objetivo - origen)

	direccion.y = 0.15

	direccion = direccion.normalized()

	# ---------- FUERZA ----------
	var distancia = origen.distance_to(objetivo)

	var fuerza = clamp(
		distancia * fuerza_base,
		4.0,
		fuerza_max
	)

	# ---------- CREAR BOCHA ----------
	var bocha = bocha_scene.instantiate()

	bocha.equipo = "azul"

	bocha.name = "bocha azul"

	bocha.add_to_group("bocha_azul")

	get_tree().current_scene.add_child(bocha)

	bocha.global_position = origen

	var juego = get_tree().current_scene

	if juego.has_method("registrar_bocha"):
		juego.registrar_bocha(bocha)

	Game.registrar_bocha(bocha)

	# ---------- LANZAR ----------
	if bocha.has_method("lanzar"):
		bocha.lanzar(direccion, fuerza)
	else:
		bocha.linear_velocity = direccion * fuerza

	print("🤖 IA lanzó")

# ==============================
# LANZAR JACK
# ==============================
func lanzar_jack():

	if jack_scene == null:
		print("❌ jack_scene NULL")
		return

	print("🎯 IA lanzando JACK...")

	# 🔒 bloquear temporalmente
	puede_lanzar = false
	ya_lanzo = true

	var jack = jack_scene.instantiate()

	get_tree().current_scene.add_child(jack)

	jack.name = "jack"

	var origen = global_transform.origin + Vector3(2.7, 1.5, 0.2)

	jack.global_position = origen

	# ---------- DIRECCIÓN ----------
	var direccion = Vector3(3.0, 1.5, 0.5)

	# ---------- LANZAR ----------
	if jack.has_method("lanzar"):
		jack.lanzar(direccion, 1)
	else:
		jack.linear_velocity = direccion * 1.0

	Game.registrar_jack(jack)

	Game.iniciar_lanzamiento(true)

	print("🎯 JACK lanzado")

	# ⏳ esperar
	await get_tree().create_timer(2.0).timeout

	ya_lanzo = false
	puede_lanzar = true

# ==============================
# TURNO
# ==============================
func reset_turno():

	ya_lanzo = false
	puede_lanzar = true

	# ⏳ pequeña pausa IA
	await get_tree().create_timer(1.5).timeout

	if not Game.puede_lanzar_bocha():
		return

	intentar_lanzar()
