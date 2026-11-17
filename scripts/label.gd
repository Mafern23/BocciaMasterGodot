extends RichTextLabel

@export var tiempo_visible := 5.0

func _ready():
	await get_tree().create_timer(tiempo_visible).timeout
	hide()
