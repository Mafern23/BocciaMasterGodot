extends Node

var musica: AudioStreamPlayer

func _ready():
	print("MUSIC MANAGER ACTIVO")
	musica = AudioStreamPlayer.new()
	add_child(musica)

func play_menu():
	print("PLAY MUSIC")

	var ruta = "res://audios/fassounds-good-night-lofi-cozy-chill-music-160166.ogg"

	if musica.playing and musica.stream != null and musica.stream.resource_path == ruta:
		return

	musica.stream = load(ruta)
	musica.volume_db = -15
	musica.play()

func stop_music():
	if musica.playing:
		musica.stop()
