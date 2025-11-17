extends Control

@onready var marker: Control = $Marker
var lifetime: float = 0.15

func _ready():
	# Show marker briefly
	marker.modulate = Color(1, 1, 1, 1)

	# Fade out
	var tween = create_tween()
	tween.tween_property(marker, "modulate:a", 0.0, lifetime)

	await tween.finished
	queue_free()
