extends RigidBody3D
class_name Missile

var config: GameConfigResource

# Missile properties
var target: Player = null
var was_locked_on: bool = true
var lifetime: float = 0.0
var fuel_remaining: float = 0.0
var shooter: Player = null

# Tracking
var last_target_position: Vector3 = Vector3.ZERO

@onready var trail_particles: GPUParticles3D = $TrailParticles
@onready var explosion_area: Area3D = $ExplosionArea

func _ready():
	config = GameConfig.get_config()
	fuel_remaining = config.missile_fuel
	lifetime = 0.0

	# Set up physics
	gravity_scale = 0.5  # Slight gravity effect
	linear_damp = 0.1
	angular_damp = 2.0

	# Initial velocity
	linear_velocity = -global_transform.basis.z * config.missile_speed

func initialize(target_player: Player, shooter_player: Player):
	target = target_player
	shooter = shooter_player
	was_locked_on = true

func _physics_process(delta):
	lifetime += delta
	fuel_remaining -= delta

	# Check lifetime
	if lifetime >= config.missile_lifetime:
		explode()
		return

	# Update guidance if fuel remains
	if fuel_remaining > 0:
		update_guidance(delta)
	else:
		# Ballistic mode after fuel runs out
		gravity_scale = 1.0

	# Check for collision
	check_collision()

func update_guidance(delta):
	if not target or not is_instance_valid(target):
		# Lost target, continue ballistic
		return

	# Check if target signature is detectable
	var target_signature = target.get_heat_signature()
	var detection_strength = target_signature / config.lock_threshold_heat

	# Lock bonus helps maintain tracking
	if was_locked_on:
		detection_strength *= config.lock_bonus_tracking

	# If signature too low, lose track
	if detection_strength < 0.3:
		target = null
		return

	# Proportional navigation guidance
	var to_target = target.global_position - global_position
	var distance = to_target.length()

	if distance < 1.0:
		# Very close, explode
		explode()
		return

	# Calculate desired direction
	var desired_direction = to_target.normalized()

	# Predict target position based on velocity
	if target.velocity.length() > 0.1:
		var time_to_intercept = distance / config.missile_speed
		var predicted_position = target.global_position + target.velocity * time_to_intercept
		desired_direction = (predicted_position - global_position).normalized()

	# Current direction
	var current_direction = -global_transform.basis.z

	# Calculate turn needed
	var turn_needed = current_direction.angle_to(desired_direction)

	# Apply turn rate limitation
	var max_turn = deg_to_rad(config.missile_turn_rate * delta)

	if turn_needed > 0.01:
		# Calculate axis of rotation
		var turn_axis = current_direction.cross(desired_direction).normalized()

		# Apply proportional navigation with signature strength
		var turn_amount = min(turn_needed, max_turn) * config.guidance_strength * detection_strength

		# Rotate the missile
		var rotation_quat = Quaternion(turn_axis, turn_amount)
		global_transform.basis = Basis(rotation_quat) * global_transform.basis

		# Update velocity to match new direction
		var current_speed = linear_velocity.length()
		linear_velocity = -global_transform.basis.z * current_speed

	# Maintain speed
	var current_speed = linear_velocity.length()
	if current_speed < config.missile_speed:
		linear_velocity = linear_velocity.normalized() * config.missile_speed

func check_collision():
	# Raycast ahead to check for impact
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = global_position + linear_velocity.normalized() * 2.0

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 3  # World + Players
	query.exclude = [self, shooter]

	var result = space_state.intersect_ray(query)

	if result:
		if result.collider is Player:
			# Direct hit
			explode()
		elif result.collider is StaticBody3D or result.collider is CSGShape3D:
			# Hit terrain
			explode()

func explode():
	# Deal damage in area of effect
	if explosion_area:
		var bodies = explosion_area.get_overlapping_bodies()
		for body in bodies:
			if body is Player and body != shooter:
				var distance = global_position.distance_to(body.global_position)
				var damage = calculate_damage(distance)
				body.take_damage(damage)

	# Create explosion visual effect
	var explosion_scene = preload("res://scenes/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)

	print("Missile exploded at ", global_position)

	queue_free()

func calculate_damage(distance: float) -> float:
	if distance <= config.missile_aoe_radius:
		# Calculate falloff
		var falloff = 1.0 - (distance / config.missile_aoe_radius)
		falloff = max(falloff, config.missile_aoe_falloff)
		return config.missile_damage * falloff

	return 0.0

func _on_body_entered(body):
	if body is Player and body != shooter:
		explode()
	elif body is StaticBody3D or body is CSGShape3D:
		explode()
