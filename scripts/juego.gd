extends Node3D

# ---------- REFERENCIA GLOBAL ----------
@onready var Game = get_node("/root/Game")

# ---------- NODOS ----------
@onready var player = get_node("player")
@onready var player_ia = get_node("player IA")

# ---------- UI ----------
@onready var aviso_inicio = $CanvasLayer/Control/Label
@onready var label_rojo = $puntos/Control/Labelrojo
@onready var label_azul = $puntos/Control/Labelazul

# ---------- DATOS ----------
var bochas := []
var jack: Node3D = null

var bochas_jugador := 6
var bochas_ia := 6

var juego_iniciado := false

# ---------- SETS ----------
var set_actual := 1
var max_sets := 4

var puntos_jugador := 0
var puntos_ia := 0

# =========================================================
# READY
# =========================================================
func _ready():

	print("🎮 Juego iniciado")

	Game.turno_actual = "rojo"

	MusicManager.stop_music()

	Game.modo_actual = Game.ModoJuego.JUEGO_LIBRE

	print("🟡 MODO NIVEL ACTIVADO")

	aviso_inicio.text = "Comienza la partida"
	aviso_inicio.visible = true

	await get_tree().create_timer(1.0).timeout

	aviso_inicio.text = "Jack"

	await get_tree().create_timer(1.0).timeout

	aviso_inicio.visible = false

	mostrar_puntaje(0, 0)

# =========================================================
# MOSTRAR TURNOS
# =========================================================
func mostrar_turno(turno):

	print("Mostrar turno:", turno)

	if turno.to_lower() == "rojo":
		aviso_inicio.text = "🔴"

	elif turno.to_lower() == "azul":
		aviso_inicio.text = "🔵"

	else:
		aviso_inicio.text = turno

	aviso_inicio.visible = true

	await get_tree().create_timer(2.0).timeout

	aviso_inicio.visible = false

# =========================================================
# MOSTRAR FUERA
# =========================================================
func mostrar_fuera():

	aviso_inicio.text = "🚨 BOCHA FUERA"

	aviso_inicio.visible = true

	await get_tree().create_timer(2.0).timeout

	aviso_inicio.visible = false

# =========================================================
# MOSTRAR PUNTAJE
# =========================================================
func mostrar_puntaje(p_rojo, p_azul):

	label_rojo.text = "🔴 Rojo: " + str(p_rojo)

	label_azul.text = "🔵 Azul: " + str(p_azul)

# =========================================================
# REGISTRAR BOCHA
# =========================================================
func registrar_bocha(bocha):

	if not is_instance_valid(bocha):
		return

	# evitar duplicados
	if bochas.has(bocha):
		print("⚠️ Bocha duplicada ignorada:", bocha.name)
		return

	bochas.append(bocha)

	print("🧠 Bocha registrada:", bocha.name)

# =========================================================
# JACK
# =========================================================
func set_jack(j):

	jack = j

	juego_iniciado = true

	print("🎯 Jack asignado:", jack)

# =========================================================
# TODAS DETENIDAS
# =========================================================
func todas_detenidas():

	for b in bochas:

		if is_instance_valid(b) and b is RigidBody3D:

			if b.linear_velocity.length() > 0.1:
				return false

	return true

# =========================================================
# MEJOR DISTANCIA
# =========================================================
func mejor_distancia(color):

	print("🧠 Calculando distancia para:", color)
	print("🧠 Total bochas registradas:", bochas.size())

	if jack == null:

		print("❌ Jack no asignado")

		return INF

	var mejor = INF

	for b in bochas:

		if not is_instance_valid(b):
			continue

		print("Revisando bocha:", b.name)
		print("Grupos:", b.get_groups())

		# 🔴 ROJO
		if color == "rojo" and b.is_in_group("bocha_roja"):

			var d_rojo = b.global_position.distance_to(
				jack.global_position
			)

			print("🔴 Dist encontrada:", d_rojo)

			mejor = min(mejor, d_rojo)

		# 🔵 AZUL
		if color == "azul" and b.is_in_group("bocha_azul"):

			var d_azul = b.global_position.distance_to(
				jack.global_position
			)

			print("🔵 Dist encontrada:", d_azul)

			mejor = min(mejor, d_azul)

	return mejor

# =========================================================
# CONTADORES
# =========================================================
func usar_bocha_jugador():

	bochas_jugador -= 1

	print("🔴 Restantes jugador:", bochas_jugador)

func usar_bocha_ia():

	bochas_ia -= 1

	print("🔵 Restantes IA:", bochas_ia)

# =========================================================
# CALCULAR PUNTOS
# =========================================================
func calcular_puntos():

	print("ENTRÓ A calcular_puntos")

	if bochas.size() == 0:

		print("Aún no hay bochas lanzadas")

		return

	var mejor_rojo = mejor_distancia("rojo")
	var mejor_azul = mejor_distancia("azul")

	print("Dist rojo:", mejor_rojo)
	print("Dist azul:", mejor_azul)

	var nuevo_turno = ""

	# quien juega ahora
	if mejor_azul < mejor_rojo:

		nuevo_turno = "rojo"

	elif mejor_rojo < mejor_azul:

		nuevo_turno = "azul"

	print("Nuevo turno:", nuevo_turno)

	mostrar_turno(nuevo_turno.capitalize())

	# puntos
	if mejor_rojo < mejor_azul:

		puntos_jugador += 1

		print("🏆 Punto para JUGADOR")

	elif mejor_azul < mejor_rojo:

		puntos_ia += 1

		print("🏆 Punto para IA")

	print("🏆 Marcador:", puntos_jugador, "-", puntos_ia)

	mostrar_puntaje(puntos_jugador, puntos_ia)

# =========================================================
# SIGUIENTE SET
# =========================================================
func siguiente_set():

	set_actual += 1

	if set_actual > max_sets:

		fin_juego()

		return

	print("➡️ Inicia set", set_actual)

	bochas.clear()

	bochas_jugador = 6
	bochas_ia = 6

	juego_iniciado = false

	Game.turno_actual = "rojo"

# =========================================================
# LIMPIAR CANCHA
# =========================================================
func limpiar_cancha():

	print("🧹 LIMPIANDO CANCHA")

	# limpiar bochas
	for b in bochas:

		if is_instance_valid(b):
			b.queue_free()

	bochas.clear()

	# eliminar jacks
	for j in get_tree().get_nodes_in_group("jack"):

		if is_instance_valid(j):

			print("💥 eliminando jack:", j.name)

			j.queue_free()

	# limpiar referencia
	if Game:

		Game.jack_actual = null

	# limpiar bochas rojas
	for b in get_tree().get_nodes_in_group("bocha_roja"):

		if is_instance_valid(b):
			b.queue_free()

	# limpiar bochas azules
	for b in get_tree().get_nodes_in_group("bocha_azul"):

		if is_instance_valid(b):
			b.queue_free()

# =========================================================
# FIN DEL JUEGO
# =========================================================
func fin_juego():

	print("🏁 FIN DEL JUEGO")

	print("🔴 Jugador:", puntos_jugador)
	print("🔵 IA:", puntos_ia)

	if puntos_jugador > puntos_ia:

		print("🏆 GANA JUGADOR")

	elif puntos_ia > puntos_jugador:

		print("🏆 GANA IA")

	else:

		print("🤝 EMPATE")


func _on_limite_cancha_body_entered(body: Node3D) -> void:
	if body.is_in_group("bocha_roja") or body.is_in_group("bocha_azul"):

		print("🚨 BOCHA FUERA")

		mostrar_fuera()

		# detener bocha
		if body is RigidBody3D:
			body.linear_velocity = Vector3.ZERO
			body.angular_velocity = Vector3.ZERO

		# mover fuera del mapa
		body.global_position = Vector3(999, -999, 999)
