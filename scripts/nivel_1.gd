extends Node3D

@onready var Game = get_tree().root.get_node("Game")

# =========================================================
# ZONAS
# =========================================================
# 1 2 3
# 4 5 6
# 7 8 9
#
# Vista desde la V hacia atrás
# =========================================================

@export var zonas: Array[Area3D]
@export var zona_objetivo_id := 1

# =========================================================
# UI
# =========================================================
@export var tutoria_label: RichTextLabel
@export var zona_label: Label

# =========================================================
# JACK
# =========================================================
@export var spawn_jack: Node3D

var jack: RigidBody3D = null
var jack_lanzado := false

# =========================================================
# ESTADO
# =========================================================
var primera_bocha := false
var aciertos := 0
var bochas := []

# =========================================================
# READY
# =========================================================
func _ready():

	Game.modo_actual = Game.ModoJuego.NIVEL

	# Configurar zonas
	for z in zonas:

		if z and z.has_method("set_entrenamiento"):
			z.set_entrenamiento(self)

	iniciar(zona_objetivo_id)

	print("🎯 [Nivel 1] Zona objetivo:", zona_objetivo_id)

	MusicManager.stop_music()

	# UI inicial
	if tutoria_label:
		tutoria_label.visible = true

	if zona_label:
		zona_label.visible = false

	actualizar_label()

	await get_tree().create_timer(8.0).timeout

	if tutoria_label:
		tutoria_label.visible = false

	if zona_label:
		zona_label.visible = true

	actualizar_zona()

# =========================================================
# RECIBIR JACK DEL PLAYER
# =========================================================
func set_jack(nueva_jack):

	print("🧠 JACK RECIBIDA EN NIVEL 1")

	jack = nueva_jack

# =========================================================
# INICIAR
# =========================================================
func iniciar(zona_id: int):

	zona_objetivo_id = zona_id

	jack_lanzado = false
	primera_bocha = false

	# Resetear zonas
	for z in zonas:

		if z and z.has_method("reset"):
			z.reset()

	actualizar_label()
	actualizar_zona()

# =========================================================
# UI TUTORIAL
# =========================================================
func actualizar_label():

	if tutoria_label == null:
		return

	var texto := ""

	texto += "🎯 NIVEL 1 - SALIDAS\n\n"

	texto += "📘 COMO JUGAR\n"
	texto += "Lanza la JACK y luego la BOCHA\n"
	texto += "a la misma zona objetivo.\n\n"

	texto += "✅ Si ambas quedan dentro:\n"
	texto += "SALIDA CORRECTA\n\n"

	texto += "❌ Si fallas:\n"
	texto += "SALIDA FALLIDA\n\n"

	texto += "🎮 CONTROLES\n"
	texto += "ESPACIO = Lanzar\n"
	texto += "B = Cambiar bocha\n"
	texto += "P = Pausa\n"
	texto += "mouse = movimiento de cámara\n\n"

	texto += "🗺️ ZONAS\n\n"

	texto += "7 8 9\n"
	texto += "4 5 6\n"
	texto += "1 2 3\n\n"

	texto += "Las zonas van desde\n"
	texto += "la V hacia atrás.\n\n"

	texto += "🎯 ZONA OBJETIVO:\n"
	texto += str(zona_objetivo_id)

	tutoria_label.text = texto

# =========================================================
# UI GAMEPLAY
# =========================================================
func actualizar_zona():

	if zona_label == null:
		return

	zona_label.text = "🎯 Lanza a la Zona " + str(zona_objetivo_id)

# =========================================================
# REGISTRAR JACK
# =========================================================
func registrar_jack():

	jack_lanzado = true

	print("🎯 Jack lanzada")

# =========================================================
# REGISTRAR BOCHA
# =========================================================
func registrar_bocha(bocha):

	if bocha not in bochas:
		bochas.append(bocha)

	print("🧠 Bocha registrada:", bocha.name)

	# Debe existir jack
	if jack == null or not is_instance_valid(jack):

		print("⚠️ Lanza primero la jack")
		return

	# Solo evaluar una vez
	if primera_bocha:
		return

	primera_bocha = true

	evaluar_salida()

# =========================================================
# EVALUAR
# =========================================================
func evaluar_salida():

	var zona_objetivo: Area3D = null

	for z in zonas:

		if z and z.zona_id == zona_objetivo_id:

			zona_objetivo = z
			break

	if zona_objetivo == null:

		push_error("❌ Zona objetivo no encontrada")
		return

	# VALIDAR JACK + BOCHA
	if zona_objetivo.jack_dentro and zona_objetivo.bocha_dentro:

		aciertos += 1

		print("✅ SALIDA CORRECTA")

	else:

		print("❌ SALIDA FALLIDA")

	# Cambiar zona
	cambiar_zona_objetivo()

# =========================================================
# CAMBIAR ZONA
# =========================================================
func cambiar_zona_objetivo():

	var nueva := zona_objetivo_id

	if zonas.size() <= 1:
		return

	while nueva == zona_objetivo_id:

		nueva = randi_range(1, zonas.size())

	iniciar(nueva)

# =========================================================
# REUBICAR JACK
# =========================================================
func reubicar_jack():

	if spawn_jack == null:

		print("❌ No existe SpawnJack")
		return

	if jack == null or not is_instance_valid(jack):

		print("❌ Jack inválida")
		return

	jack.linear_velocity = Vector3.ZERO
	jack.angular_velocity = Vector3.ZERO

	jack.global_position = spawn_jack.global_position

	jack_lanzado = false

	print("🔁 Jack reubicada")

# =========================================================
# PROCESS
# =========================================================
func _process(_delta):

	if not jack_lanzado:
		return

	if jack == null or not is_instance_valid(jack):
		return
# Detectar caída real
	print("📍 Y JACK:", jack.global_position.y)

	if jack.global_position.y < 0:

		print("⬇️ Jack cayó al vacío")

	reubicar_jack()
