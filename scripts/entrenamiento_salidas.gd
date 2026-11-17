extends Node3D

@export var zonas: Array[Area3D]
@export var zona_objetivo_id: int = 1
@export var label_zona: Label

var jack: RigidBody3D = null

var jack_lanzada := false
var bocha_lanzada := false

var aciertos := 0
var aciertos_para_pasar := 3

var jack_pos_inicial: Vector3 = Vector3.ZERO


# =====================================
# READY
# =====================================
func _ready():

	for z in zonas:

		if z and z.has_method("set_entrenamiento"):
			z.set_entrenamiento(self)

	iniciar_nivel()


# =====================================
# RECIBIR JACK DESDE PLAYER
# =====================================
func set_jack(nueva_jack):

	jack = nueva_jack

	jack_lanzada = true

	# guardar posición inicial
	jack_pos_inicial = Vector3(0, 1.5, 0)

	print("🎯 Jack registrada en:", jack_pos_inicial)

	# esperar un momento y lanzar bocha
	await get_tree().create_timer(1.0).timeout

	lanzar_bocha()


# =====================================
# INICIO NIVEL
# =====================================
func iniciar_nivel():

	jack_lanzada = false
	bocha_lanzada = false

	for z in zonas:

		if z and z.has_method("reset"):
			z.reset()

	actualizar_label()

	print("🎯 [Nivel 1 - Salidas] Zona objetivo:", zona_objetivo_id)


# =====================================
# UI
# =====================================
func actualizar_label():

	if label_zona:

		label_zona.text = "🎯 Apunta a la zona " + str(zona_objetivo_id)


# =====================================
# REGISTROS
# =====================================
func registrar_jack():

	jack_lanzada = true


func registrar_bocha():

	if bocha_lanzada:
		return

	bocha_lanzada = true

	evaluar_salida()


# =====================================
# LANZAR BOCHA
# =====================================
func lanzar_bocha():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:

		print("❌ No existe player en grupo")

		return

	print("🚨 LLAMANDO A _launch_current")



# =====================================
# EVALUAR SALIDA
# =====================================
func evaluar_salida():

	var zona_objetivo = null

	for z in zonas:

		if z and z.zona_id == zona_objetivo_id:

			zona_objetivo = z

			break

	if zona_objetivo == null:

		push_error("❌ Zona objetivo no encontrada")

		return

	# salida correcta
	if zona_objetivo.jack_dentro and zona_objetivo.bocha_dentro:

		print("✅ SALIDA CORRECTA")

		aciertos += 1

		print("🏆 Aciertos:", aciertos, "/", aciertos_para_pasar)

		if aciertos >= aciertos_para_pasar:

			pasar_nivel()

	else:

		print("❌ SALIDA FALLIDA")

		reiniciar_jack()

	# siguiente intento
	zona_objetivo_id = randi_range(1, zonas.size())

	iniciar_nivel()


# =====================================
# REINICIAR JACK
# =====================================
func reiniciar_jack():

	if jack == null or not is_instance_valid(jack):

		print("⚠️ No hay jack para reiniciar")

		return

	jack.linear_velocity = Vector3.ZERO
	jack.angular_velocity = Vector3.ZERO

	jack.global_position = jack_pos_inicial

	print("🔁 Jack reiniciada")


# =====================================
# PASAR NIVEL
# =====================================
func pasar_nivel():

	print("🎉 NIVEL COMPLETADO")

	get_tree().change_scene_to_file("res://scenas/pasonivel2.tscn")
