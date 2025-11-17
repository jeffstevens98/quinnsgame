extends Node3D

@onready var particles: GPUParticles3D = $ImpactParticles
@onready var sparks: GPUParticles3D = $Sparks

var lifetime: float = 0.5

func _ready():
	if particles:
		particles.emitting = true
	if sparks:
		sparks.emitting = true

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_impact_normal(normal: Vector3):
	# Orient particles away from impact surface
	look_at(global_position + normal, Vector3.UP)
