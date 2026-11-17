extends Node

# ==============================
# GAME MANAGER - BOCCIA MASTER
# ==============================

# ---------- MODOS ----------
enum ModoJuego {
	JUEGO_LIBRE,
	NIVEL
}

var modo_actual = ModoJuego.JUEGO_LIBRE

# ---------- ENTRENAMIENTO ----------
@export var modo_entrenamiento := false
@export var modo_salidas := false

# ---------- TURNOS ----------
var turno_actual := "rojo"
var equipo_jack := "rojo"

# ---------- BOCHAS ----------
var bochas_rojas_restantes := 6
var bochas_azules_restantes := 6
var bochas = []

# ---------- PUNTOS ----------
var puntos_rojo := 0
var puntos_azul := 0

# ---------- SETS ----------
var set_actual := 1
var max_sets := 4

# ---------- JACK ----------
var jack_actual = null

# ---------- CONTROL ----------
var lanzamiento_en_proceso := false
var bochas_en_movimiento := 0
var juego_iniciado := false
var esperando_jack := false

# ==============================
# READY
# ==============================
func _ready():

	print("🤖 GameManager listo")

	iniciar_juego()

# ==============================
# INICIAR JUEGO
# ==============================
func iniciar_juego():

	if juego_iniciado:
		print("⚠️ Juego ya iniciado")
		return

	juego_iniciado = true

	turno_actual = "rojo"

	bochas_rojas_restantes = 6
	bochas_azules_restantes = 6

	puntos_rojo = 0
	puntos_azul = 0

	set_actual = 1

	jack_actual = null

	lanzamiento_en_proceso = false
	bochas_en_movimiento = 0

	print("🎮 Juego iniciado - Set 1")

# ==============================
# JACK
# ==============================
func registrar_jack(jack):

	if jack_actual != null:
		return

	jack_actual = jack

	print("🎯 Jack registrado")

	equipo_jack = turno_actual

	print("🎯 Jack lanzado por:", equipo_jack)

	var juego = get_tree().current_scene

	if juego and juego.has_method("set_jack"):
		juego.set_jack(jack)

# ==============================
# LANZAMIENTO
# ==============================
func iniciar_lanzamiento(es_jack: bool):

	lanzamiento_en_proceso = true

	if es_jack:

		esperando_jack = true

		print("🎯 Lanzamiento JACK")

	else:

		print("⚪ Lanzamiento bocha")

func puede_lanzar_bocha() -> bool:

	return not lanzamiento_en_proceso

# ==============================
# REGISTRAR BOCHAS
# ==============================
func registrar_bocha(bocha):

	if not is_instance_valid(bocha):
		return

	# evitar duplicados
	if bochas.has(bocha):
		print("⚠️ Bocha duplicada ignorada:", bocha.name)
		return

	bochas.append(bocha)

	print("🧠 Bocha registrada:", bocha.name)

# ==============================
# BOCHAS EN MOVIMIENTO
# ==============================
func registrar_bocha_en_movimiento():

	bochas_en_movimiento += 1

# ==============================
# BOCHA DETENIDA
# ==============================
func registrar_bocha_detenida():

	bochas_en_movimiento -= 1

	if bochas_en_movimiento < 0:
		bochas_en_movimiento = 0

	print("🛑 Bocha detenida. Restantes:", bochas_en_movimiento)

	if bochas_en_movimiento == 0:

		await get_tree().create_timer(0.3).timeout

		lanzamiento_en_proceso = false

		var entrenamiento = get_tree().get_first_node_in_group("entrenamiento")

		# entrenamiento sin turnos
		if entrenamiento:
			print("🎯 Entrenamiento detectado")
			return

		cambiar_turno()

# ==============================
# CAMBIAR TURNO
# ==============================
func cambiar_turno():

	if modo_entrenamiento:
		return

	var players = get_tree().get_nodes_in_group("player")

	if not players.is_empty():

		var player = players[0]

		player.ya_lanzo = false

	var juego = get_tree().current_scene

	if juego == null:
		return

	print("Jack actual:", jack_actual)

	# FIN DEL SET
	if bochas_rojas_restantes <= 0 and bochas_azules_restantes <= 0:

		fin_de_set()

		return

	print("🔍 rojas restantes:", bochas_rojas_restantes)
	print("🔍 azules restantes:", bochas_azules_restantes)

	# PRIMER TURNO
	if bochas_rojas_restantes == 6 and bochas_azules_restantes == 6:

		turno_actual = equipo_jack

		print("🔄 Primer turno:", turno_actual)

		if juego.has_method("mostrar_turno"):
			juego.mostrar_turno(turno_actual.capitalize())

		aplicar_turno()

		return

	# ROJO SIN BOCHAS
	if bochas_rojas_restantes <= 0:

		turno_actual = "azul"

		print("🔄 Turno forzado: azul")

		if juego.has_method("mostrar_turno"):
			juego.mostrar_turno("🔵")

		aplicar_turno()

		return

	# AZUL SIN BOCHAS
	if bochas_azules_restantes <= 0:

		turno_actual = "rojo"

		print("🔄 Turno forzado: rojo")

		if juego.has_method("mostrar_turno"):
			juego.mostrar_turno("🔴")

		aplicar_turno()

		return

	# SIN JACK
	if jack_actual == null:

		turno_actual = "rojo"

		if juego.has_method("mostrar_turno"):
			juego.mostrar_turno("🔴")

		aplicar_turno()

		return

	var dist_rojo = juego.mejor_distancia("rojo")
	var dist_azul = juego.mejor_distancia("azul")

	if dist_rojo == INF and dist_azul == INF:

		turno_actual = "rojo"

	elif dist_azul == INF:

		turno_actual = "azul"

	elif dist_rojo == INF:

		turno_actual = "rojo"

	elif dist_rojo < dist_azul:

		turno_actual = "azul"

	else:

		turno_actual = "rojo"

	print("🔄 Nuevo turno:", turno_actual)

	if juego.has_method("mostrar_turno"):

		if turno_actual == "rojo":
			juego.mostrar_turno("🔴")
		else:
			juego.mostrar_turno("🔵")

	aplicar_turno()

# ==============================
# ACTIVAR IA
# ==============================
func aplicar_turno():

	var ias = get_tree().get_nodes_in_group("ia")

	for ia in ias:

		if turno_actual == "azul":

			if ia.has_method("reset_turno"):
				ia.reset_turno()

# ==============================
# JACK FUERA
# ==============================
func jack_fuera():

	print("🚨 Jack fuera")

	if modo_actual == ModoJuego.NIVEL:

		reiniciar_jack()

	elif modo_actual == ModoJuego.JUEGO_LIBRE:

		turno_actual = "azul"

		aplicar_turno()

func reiniciar_jack():

	if not is_instance_valid(jack_actual):
		return

	jack_actual.linear_velocity = Vector3.ZERO
	jack_actual.angular_velocity = Vector3.ZERO
	jack_actual.global_position = Vector3(0, 0.5, 0)

# ==============================
# FIN DE SET
# ==============================
func fin_de_set():

	print("🏁 Fin del set:", set_actual)

	# 🔥 calcular puntos ANTES de limpiar
	calcular_puntos()
	var juego = get_tree().current_scene

	if juego and juego.has_method("mostrar_puntaje"):
		juego.mostrar_puntaje(puntos_rojo, puntos_azul)
		print("🏆 Marcador actual:",

		puntos_rojo, "-", puntos_azul)

	# 🔥 subir set primero
	set_actual += 1

	# fin del juego
	if set_actual > max_sets:

		fin_del_juego()
		return

	# 🔥 limpiar después
	reiniciar_set()

# ==============================
# CALCULAR PUNTOS
# ==============================
func calcular_puntos():

	if not is_instance_valid(jack_actual):
		return

	var dist_rojo = []
	var dist_azul = []

	# limpiar bochas destruidas
	var bochas_validas = []

	for bocha in bochas:

		if is_instance_valid(bocha):
			bochas_validas.append(bocha)

	bochas = bochas_validas

	# recorrer TODAS las bochas
	for bocha in bochas:

		if not is_instance_valid(bocha):
			continue

		var dist = bocha.global_position.distance_to(
			jack_actual.global_position
		)

		# detectar equipo
		if bocha.is_in_group("bocha_roja"):

			dist_rojo.append(dist)

		elif bocha.is_in_group("bocha_azul"):

			dist_azul.append(dist)

	# ordenar
	dist_rojo.sort()
	dist_azul.sort()

	print("🔴 Distancias rojo:", dist_rojo)
	print("🔵 Distancias azul:", dist_azul)

	# evitar errores
	if dist_rojo.is_empty() and dist_azul.is_empty():
		return

	var mejor_rojo = INF
	var mejor_azul = INF

	if not dist_rojo.is_empty():
		mejor_rojo = dist_rojo[0]

	if not dist_azul.is_empty():
		mejor_azul = dist_azul[0]

	var puntos = 0

	# ROJO gana
	if mejor_rojo < mejor_azul:

		for d in dist_rojo:

			if d < mejor_azul:
				puntos += 1

		puntos_rojo += puntos

		print("🔴 ROJO gana", puntos, "puntos")

	# AZUL gana
	elif mejor_azul < mejor_rojo:

		for d in dist_azul:

			if d < mejor_rojo:
				puntos += 1

		puntos_azul += puntos

		print("🔵 AZUL gana", puntos, "puntos")

	print("🏆 Marcador actual:", puntos_rojo, "-", puntos_azul)

# ==============================
# REINICIAR SET
# ==============================
func reiniciar_set():

	print("➡️ llamando limpiar_cancha")

	var juego = get_tree().current_scene

	if juego and juego.has_method("limpiar_cancha"):
		juego.limpiar_cancha()

	bochas.clear()

	if is_instance_valid(jack_actual):
		jack_actual.queue_free()

	jack_actual = null

	bochas_rojas_restantes = 6
	bochas_azules_restantes = 6

	bochas_en_movimiento = 0
	lanzamiento_en_proceso = false

	# alternar jack
	if set_actual % 2 == 0:

		turno_actual = "azul"

		print("🎯 Jack inicial para IA")

	else:

		turno_actual = "rojo"

		print("🎯 Jack inicial para Jugador")

		var players = get_tree().get_nodes_in_group("player")

		if not players.is_empty():

			var player = players[0]

			player.jack_lanzado = false
			player.lanzar_jack = true
			player.ya_lanzo = false

	print("➡️ Nuevo set:", set_actual)

	# mostrar mensaje en pantalla
	if juego and juego.has_method("mostrar_turno"):

		if turno_actual == "rojo":
			juego.mostrar_turno("🔴 ROJO - JACK")

		else:
			juego.mostrar_turno("🔵 AZUL - JACK")

	# IA lanza jack automáticamente
	if turno_actual == "azul":

		var ias = get_tree().get_nodes_in_group("ia")

		print("IAS ENCONTRADAS:", ias.size())

		for bot in ias:

			print("IA encontrada:", bot.name)
			print("Ruta:", bot.get_path())

			if bot.has_method("lanzar_jack"):

				print("🤖 IA lanzando JACK...")

				bot.lanzar_jack()
# ==============================
# FIN DEL JUEGO
# ==============================
func fin_del_juego():

	print("🏆 FIN DEL JUEGO")

	if puntos_rojo > puntos_azul:

		print("🔴 GANA ROJO")

	elif puntos_azul > puntos_rojo:

		print("🔵 GANA AZUL")

	else:

		print("🤝 EMPATE")
