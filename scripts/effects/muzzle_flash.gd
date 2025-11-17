extends Node3D

@onready var particles: GPUParticles3D = $FlashParticles
@onready var light: OmniLight3D = $Light

var lifetime: float = 0.1

func _ready():
	if particles:
		particles.emitting = true

	if light:
		light.light_energy = 3.0
		var tween = create_tween()
		tween.tween_property(light, "light_energy", 0.0, 0.05)

	await get_tree().create_timer(lifetime).timeout
	queue_free()
