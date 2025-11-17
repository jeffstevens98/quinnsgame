extends Node3D

@onready var particles: GPUParticles3D = $ExplosionParticles
@onready var shockwave: GPUParticles3D = $Shockwave
@onready var flash: OmniLight3D = $Flash
@onready var smoke: GPUParticles3D = $Smoke

var lifetime: float = 2.0

func _ready():
	# Trigger one-shot particles
	if particles:
		particles.emitting = true
	if shockwave:
		shockwave.emitting = true
	if smoke:
		smoke.emitting = true

	# Flash effect
	if flash:
		flash.light_energy = 5.0
		var tween = create_tween()
		tween.tween_property(flash, "light_energy", 0.0, 0.3)

	# Auto-cleanup
	await get_tree().create_timer(lifetime).timeout
	queue_free()
