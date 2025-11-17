extends CharacterBody3D
class_name Player

# Signals
signal hit_confirmed()
signal took_damage(amount: float)

# Config reference
var config: GameConfigResource

# Movement states
enum MovementState { NORMAL, SPRINTING, CRAWLING, DIVING, SKIING }
var movement_state: MovementState = MovementState.NORMAL

# Movement variables
var is_grounded: bool = false
var dive_direction: Vector3 = Vector3.ZERO
var dive_time: float = 0.0
var can_handspring: bool = false

# Jetpack variables
var jetpack_active: bool = false
var jetpack_fuel: float = 5.0
var jump_hold_time: float = 0.0
var time_since_jetpack_off: float = 0.0
const JETPACK_ACTIVATION_THRESHOLD: float = 0.3

# Body/aim direction with turn rate lag
var body_direction: Vector3 = Vector3.FORWARD
var aim_direction: Vector3 = Vector3.FORWARD
var cursor_world_position: Vector3 = Vector3.ZERO

# Power and heat system
var current_power_consumption: float = 0.0
var accumulated_heat: float = 0.0
var heat_signature: float = 0.0

# Shields and health
var shield_current: float = 100.0
var health_current: float = 150.0
var time_since_last_damage: float = 0.0
var shields_broken: bool = false

# Weapon system
var current_ammo: int = 45
var reserve_ammo: int = 360
var is_reloading: bool = false
var reload_timer: float = 0.0
var current_recoil: float = 0.0
var current_spread: float = 0.5
var fire_cooldown: float = 0.0

# Melee system
var melee_stab_cooldown_timer: float = 0.0
var melee_butt_cooldown_timer: float = 0.0

# Missile system
var missile_ammo: int = 12
var missile_cooldown_timer: float = 0.0
var locking_target: Node3D = null
var lock_progress: float = 0.0
var locked_target: Node3D = null

# Network sync
var player_id: int = 0
var team_id: int = 1
var player_name: String = "Player"

# References
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var weapon_raycast: RayCast3D = $WeaponRaycast
@onready var melee_area: Area3D = $MeleeArea
@onready var jetpack_particles: GPUParticles3D = $JetpackParticles

func _ready():
	config = GameConfig.get_config()

	# Initialize resources
	jetpack_fuel = config.jetpack_fuel_max
	shield_current = config.shield_max
	health_current = config.health_max
	current_ammo = config.magazine_size
	reserve_ammo = config.reserve_ammo
	missile_ammo = config.missile_ammo

	# Set up camera if it exists
	if camera_pivot and camera:
		setup_camera()

func setup_camera():
	# Position camera behind and above player (Helldivers 2 style)
	camera.position = Vector3(
		0,
		config.camera_height,
		config.camera_distance
	)
	camera.rotation_degrees = Vector3(-config.camera_angle, 0, 0)

func _physics_process(delta):
	update_movement(delta)
	update_jetpack(delta)
	update_heat_system(delta)
	update_resources(delta)
	update_weapon(delta)
	update_missile_system(delta)
	update_camera(delta)

	move_and_slide()

func update_movement(delta):
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Handle diving state
	if movement_state == MovementState.DIVING:
		dive_time += delta
		velocity += dive_direction * config.dive_force * delta

		# Check for handspring input
		if Input.is_action_just_pressed("dive") and dive_time > 0.2:
			can_handspring = true

		# Land from dive
		if is_on_floor() and dive_time > 0.3:
			if can_handspring:
				# Perform handspring into roll
				velocity.y = config.jump_force * 0.5
				can_handspring = false
			movement_state = MovementState.NORMAL
			dive_time = 0.0

		return

	# Check for dive input
	if Input.is_action_just_pressed("dive") and is_on_floor():
		var move_dir = Vector3(input_dir.x, 0, input_dir.y).normalized()
		if move_dir.length() < 0.1:
			move_dir = body_direction
		dive_direction = move_dir
		movement_state = MovementState.DIVING
		dive_time = 0.0
		velocity.y = config.jump_force * 0.3
		return

	# Check for crawl toggle
	if Input.is_action_just_pressed("crawl"):
		if movement_state == MovementState.CRAWLING:
			movement_state = MovementState.NORMAL
		else:
			movement_state = MovementState.CRAWLING

	# Check for skiing
	var is_skiing = Input.is_action_pressed("ski")
	if is_skiing:
		movement_state = MovementState.SKIING
	elif movement_state == MovementState.SKIING:
		movement_state = MovementState.NORMAL

	# Get desired speed based on state
	var desired_speed = config.walk_speed
	var friction = config.normal_friction
	var air_control_factor = config.air_control

	match movement_state:
		MovementState.SPRINTING:
			desired_speed = config.walk_speed * config.sprint_multiplier
		MovementState.CRAWLING:
			desired_speed = config.crawl_speed
		MovementState.SKIING:
			friction = config.ski_friction
			air_control_factor = config.ski_air_control

	# Check for sprint
	if Input.is_action_pressed("sprint") and movement_state == MovementState.NORMAL:
		movement_state = MovementState.SPRINTING
	elif movement_state == MovementState.SPRINTING and not Input.is_action_pressed("sprint"):
		movement_state = MovementState.NORMAL

	# Calculate movement direction
	var move_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Update aim direction based on mouse/cursor
	update_aim_direction(delta)

	# Apply turn rate to body direction
	if move_direction.length() > 0.1:
		var target_direction = move_direction.rotated(Vector3.UP, camera_pivot.rotation.y)
		var max_turn = deg_to_rad(config.turn_rate_ground * delta)
		body_direction = body_direction.slerp(target_direction, min(max_turn, 1.0))
		body_direction = body_direction.normalized()

	# Apply movement
	is_grounded = is_on_floor()

	if is_grounded:
		# Ground movement
		var target_velocity = move_direction.rotated(Vector3.UP, camera_pivot.rotation.y) * desired_speed
		velocity.x = lerp(velocity.x, target_velocity.x, friction * delta * 10.0)
		velocity.z = lerp(velocity.z, target_velocity.z, friction * delta * 10.0)
	else:
		# Air control
		if movement_state != MovementState.SKIING:
			var target_velocity = move_direction.rotated(Vector3.UP, camera_pivot.rotation.y) * desired_speed
			velocity.x = lerp(velocity.x, target_velocity.x, air_control_factor * delta)
			velocity.z = lerp(velocity.z, target_velocity.z, air_control_factor * delta)

	# Apply gravity
	if not is_on_floor() and not jetpack_active:
		velocity.y -= config.gravity * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = config.jump_force

func update_aim_direction(delta):
	# Get mouse position in 3D world
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	# Raycast to find aim point
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # World layer
	var result = space_state.intersect_ray(query)

	if result:
		cursor_world_position = result.position
		var to_cursor = cursor_world_position - global_position
		to_cursor.y = 0
		if to_cursor.length() > 0.1:
			aim_direction = to_cursor.normalized()

func update_jetpack(delta):
	# Handle jetpack activation
	var jump_pressed = Input.is_action_pressed("jump")

	if jump_pressed and not is_on_floor():
		jump_hold_time += delta

		# Activate jetpack after threshold or if already in air
		if jump_hold_time > JETPACK_ACTIVATION_THRESHOLD or not jetpack_active:
			if jetpack_fuel > 0:
				jetpack_active = true
				time_since_jetpack_off = 0.0
	else:
		jump_hold_time = 0.0
		if jetpack_active:
			jetpack_active = false
			time_since_jetpack_off = 0.0

	# Apply jetpack thrust
	if jetpack_active and jetpack_fuel > 0:
		# Determine thrust direction
		var thrust_direction = Vector3.UP

		# If moving forward, angle thrust based on aim direction
		if Input.is_action_pressed("move_forward"):
			thrust_direction = (aim_direction + Vector3.UP).normalized()

			# Apply turn rate limitation
			var current_velocity_dir = velocity.normalized()
			if velocity.length() > 0.1:
				var max_turn = deg_to_rad(config.jetpack_turn_rate * delta)
				thrust_direction = current_velocity_dir.slerp(thrust_direction, max_turn)

		# Apply acceleration
		velocity += thrust_direction * config.jetpack_acceleration * delta

		# Consume fuel
		jetpack_fuel -= config.jetpack_fuel_consumption * delta
		jetpack_fuel = max(0, jetpack_fuel)

		# Update power consumption
		current_power_consumption = config.reactor_max_power
	else:
		jetpack_active = false
		time_since_jetpack_off += delta
		current_power_consumption = 0.0

	# Update jetpack particles
	if jetpack_particles:
		jetpack_particles.emitting = jetpack_active

func update_heat_system(delta):
	# Generate heat from power consumption
	if jetpack_active:
		var heat_generated = config.heat_from_power_use * current_power_consumption * delta
		accumulated_heat += heat_generated

	# Passive cooling when not generating heat
	if not jetpack_active:
		accumulated_heat -= config.passive_cooling_rate * delta

	# Clamp heat
	accumulated_heat = clamp(accumulated_heat, 0, config.max_heat_capacity * 1.2)

	# Apply overheat damage
	if accumulated_heat > config.max_heat_capacity:
		take_damage(config.overheat_damage_rate * delta, true)  # True = bypass shields

	# Calculate heat signature
	calculate_heat_signature()

func calculate_heat_signature():
	heat_signature = 0.0

	# Instant heat from jetpack
	if jetpack_active:
		heat_signature += config.reactor_instant_heat

	# Accumulated heat contribution
	heat_signature += accumulated_heat * config.heat_signature_multiplier

	# Apply decay when jetpack is off
	if not jetpack_active and time_since_jetpack_off < 10.0:
		var decay_factor = exp(-config.exponential_decay_rate * time_since_jetpack_off)
		heat_signature *= decay_factor

func get_heat_signature() -> float:
	return heat_signature

func update_resources(delta):
	time_since_last_damage += delta

	# Shield regeneration
	if shield_current < config.shield_max:
		var regen_delay = config.shield_regen_delay if not shields_broken else config.shield_regen_delay_break

		if time_since_last_damage >= regen_delay:
			shield_current += config.shield_regen_rate * delta
			shield_current = min(shield_current, config.shield_max)

			if shield_current >= config.shield_max:
				shields_broken = false

	# Health regeneration
	if health_current < config.health_max:
		if time_since_last_damage >= config.health_regen_delay:
			health_current += config.health_regen_rate * delta
			health_current = min(health_current, config.health_max)

func update_weapon(delta):
	fire_cooldown -= delta
	melee_stab_cooldown_timer -= delta
	melee_butt_cooldown_timer -= delta

	# Update recoil and spread recovery
	current_recoil = max(0, current_recoil - config.recoil_recovery * delta)
	current_spread = max(config.spread_min, current_spread - config.spread_recovery * delta)

	# Handle reloading
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			var ammo_needed = config.magazine_size - current_ammo
			var ammo_to_add = min(ammo_needed, reserve_ammo)
			current_ammo += ammo_to_add
			reserve_ammo -= ammo_to_add
			is_reloading = false

	# Handle firing
	if Input.is_action_pressed("fire") and not is_reloading and fire_cooldown <= 0:
		if current_ammo > 0:
			fire_weapon()
		else:
			# Auto reload on empty
			start_reload()

	# Manual reload
	if Input.is_action_just_pressed("reload") and current_ammo < config.magazine_size and reserve_ammo > 0:
		start_reload()

	# Melee attacks
	if Input.is_action_just_pressed("melee_stab") and melee_stab_cooldown_timer <= 0:
		perform_melee_stab()

	if Input.is_action_just_pressed("melee_butt") and melee_butt_cooldown_timer <= 0:
		perform_melee_butt()

func fire_weapon():
	var shots_per_second = config.fire_rate / 60.0
	fire_cooldown = 1.0 / shots_per_second

	# Play weapon fire sound
	SoundManager.play_weapon_fire("AR-45", global_position)

	# Spawn muzzle flash
	var muzzle_flash_scene = preload("res://scenes/muzzle_flash.tscn")
	var muzzle_flash = muzzle_flash_scene.instantiate()
	muzzle_flash.global_position = global_position + Vector3(0, 1.5, 0) + aim_direction * 0.5
	muzzle_flash.look_at(muzzle_flash.global_position + aim_direction, Vector3.UP)
	get_parent().add_child(muzzle_flash)

	# Calculate shot direction with spread
	var spread_angle = deg_to_rad(current_spread)
	var random_spread = Vector3(
		randf_range(-spread_angle, spread_angle),
		randf_range(-spread_angle, spread_angle),
		0
	)

	var shot_direction = (aim_direction + random_spread).normalized()

	# Raycast for hit detection
	var from = global_position + Vector3(0, 1.5, 0)
	var to = from + shot_direction * 300.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2 + 1  # Players + World
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	if result:
		# Spawn impact effect
		var impact_scene = preload("res://scenes/impact_effect.tscn")
		var impact = impact_scene.instantiate()
		impact.global_position = result.position
		get_parent().add_child(impact)
		impact.set_impact_normal(result.normal)

		if result.collider is Player:
			# Calculate damage with falloff
			var distance = global_position.distance_to(result.position)
			var damage = config.damage_per_shot

			if distance > config.damage_falloff_start:
				var falloff_range = config.damage_falloff_end - config.damage_falloff_start
				var falloff_amount = (distance - config.damage_falloff_start) / falloff_range
				falloff_amount = clamp(falloff_amount, 0, 1)
				damage *= lerp(1.0, 0.5, falloff_amount)

			result.collider.take_damage(damage)

			# Emit hit confirmation for hit marker
			hit_confirmed.emit()

	# Apply recoil and spread
	current_recoil += config.recoil_per_shot
	current_spread = min(config.spread_max, current_spread + config.spread_increase)

	# Consume ammo
	current_ammo -= 1

func start_reload():
	if not is_reloading:
		is_reloading = true
		reload_timer = config.reload_time
		SoundManager.play_weapon_reload(global_position)

func perform_melee_stab():
	melee_stab_cooldown_timer = config.melee_stab_cooldown

	# Check for targets in melee range
	var targets = melee_area.get_overlapping_bodies()
	for target in targets:
		if target is Player and target != self:
			target.take_damage(config.melee_stab_damage)
			break

func perform_melee_butt():
	melee_butt_cooldown_timer = config.melee_butt_cooldown

	# Check for targets in melee range
	var targets = melee_area.get_overlapping_bodies()
	for target in targets:
		if target is Player and target != self:
			target.take_damage(config.melee_butt_damage)
			# Apply knockback/stun (implement later)
			break

func update_missile_system(delta):
	missile_cooldown_timer -= delta

	# Handle missile lock-on
	if Input.is_action_pressed("missile_lock"):
		# Find potential target under cursor
		var potential_target = find_target_under_cursor()

		if potential_target and potential_target.get_heat_signature() >= config.lock_threshold_heat:
			if locking_target == potential_target:
				# Continue locking
				lock_progress += delta / config.lock_on_time

				if lock_progress >= 1.0:
					locked_target = potential_target
					lock_progress = 1.0
			else:
				# Start new lock
				locking_target = potential_target
				lock_progress = 0.0
		else:
			# No valid target
			locking_target = null
			lock_progress = 0.0
	else:
		# Cancel lock if button released before complete
		if lock_progress < 1.0:
			locking_target = null
			locked_target = null
		lock_progress = 0.0

	# Fire missile
	if Input.is_action_just_released("missile_lock") and locked_target and missile_ammo > 0 and missile_cooldown_timer <= 0:
		fire_missile(locked_target)
		locked_target = null
		locking_target = null

func find_target_under_cursor() -> Player:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * config.lock_on_range

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2  # Players layer
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	if result and result.collider is Player:
		return result.collider

	return null

func fire_missile(target: Player):
	# Load and instantiate missile
	var missile_scene = preload("res://scenes/missile.tscn")
	var missile = missile_scene.instantiate()

	# Position missile slightly in front of player
	missile.global_position = global_position + Vector3(0, 1.5, 0) + aim_direction * 2.0

	# Orient missile toward target
	var to_target = target.global_position - missile.global_position
	missile.look_at(missile.global_position + to_target, Vector3.UP)

	# Initialize missile
	missile.initialize(target, self)

	# Add to scene
	get_parent().add_child(missile)

	# Update ammo and cooldown
	missile_ammo -= 1
	missile_cooldown_timer = config.missile_cooldown

	print("Fired missile at ", target.player_name)

func update_camera(delta):
	if not camera_pivot:
		return

	# Camera follows player smoothly
	var target_position = global_position
	camera_pivot.global_position = camera_pivot.global_position.lerp(
		target_position,
		config.camera_lerp_factor
	)

	# Camera rotates to follow aim direction with lag
	var target_rotation = atan2(aim_direction.x, aim_direction.z)
	camera_pivot.rotation.y = lerp_angle(
		camera_pivot.rotation.y,
		target_rotation,
		config.body_lag_factor
	)

func take_damage(amount: float, bypass_shields: bool = false):
	time_since_last_damage = 0.0

	# Spawn damage number
	var damage_number_scene = preload("res://scenes/damage_number.tscn")
	var damage_number = damage_number_scene.instantiate()
	damage_number.global_position = global_position + Vector3(0, 2.0, 0)
	get_parent().add_child(damage_number)
	damage_number.set_damage(amount)

	# Emit signal
	took_damage.emit(amount)

	if not bypass_shields and shield_current > 0:
		# Damage shields first
		shield_current -= amount
		if shield_current <= 0:
			var overflow = -shield_current
			shield_current = 0
			shields_broken = true
			health_current -= overflow
		else:
			return
	else:
		# Damage health directly
		health_current -= amount

	health_current = max(0, health_current)

	if health_current <= 0:
		die()

func die():
	print(player_name, " died")

	# Notify team manager of death
	# TeamManager would track this in multiplayer

	# Respawn after delay
	await get_tree().create_timer(3.0).timeout
	respawn()

func respawn():
	# Reset position to spawn
	if get_parent() and get_parent().has_method("get_spawn_position"):
		global_position = get_parent().get_spawn_position(team_id)
	else:
		global_position = Vector3(0, 5, 0)

	# Reset resources
	refill_resources()

	print(player_name, " respawned")

func refill_resources():
	jetpack_fuel = config.jetpack_fuel_max
	shield_current = config.shield_max
	health_current = config.health_max
	current_ammo = config.magazine_size
	reserve_ammo = config.reserve_ammo
	missile_ammo = config.missile_ammo
	accumulated_heat = 0.0
