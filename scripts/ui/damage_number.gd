extends Label3D

var velocity: Vector3 = Vector3.ZERO
var lifetime: float = 1.0
var fade_time: float = 0.5

func _ready():
	# Randomize upward movement
	velocity = Vector3(randf_range(-0.5, 0.5), randf_range(2.0, 4.0), randf_range(-0.5, 0.5))

	# Start fade after delay
	await get_tree().create_timer(lifetime - fade_time).timeout

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)

	await tween.finished
	queue_free()

func _process(delta):
	# Float upward
	global_position += velocity * delta

	# Slow down
	velocity *= 0.95

	# Always face camera
	if get_viewport().get_camera_3d():
		look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)
		rotate_object_local(Vector3.UP, PI)

func set_damage(damage: float, is_critical: bool = false):
	text = str(int(damage))

	if is_critical:
		modulate = Color(1.0, 0.3, 0.3)  # Red for critical
		outline_modulate = Color(0.5, 0.0, 0.0)
	else:
		modulate = Color(1.0, 1.0, 1.0)  # White for normal
		outline_modulate = Color(0.0, 0.0, 0.0)
