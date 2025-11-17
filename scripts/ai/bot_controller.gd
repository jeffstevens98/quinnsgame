extends Player
class_name BotPlayer

# AI states
enum AIState { IDLE, PATROL, CHASE, ATTACK, EVADE }
var ai_state: AIState = AIState.PATROL

# AI variables
var target_player: Player = null
var patrol_target: Vector3 = Vector3.ZERO
var patrol_timer: float = 0.0
var think_timer: float = 0.0
var reaction_time: float = 0.3

# AI configuration
var detection_range: float = 100.0
var attack_range: float = 50.0
var preferred_distance: float = 30.0
var skill_level: float = 0.5  # 0-1, affects accuracy and reaction

func _ready():
	super._ready()

	# Set bot name
	player_name = "Bot" + str(randi() % 1000)

	# Initialize patrol
	choose_new_patrol_point()

func _physics_process(delta):
	think_timer += delta

	# AI thinks at intervals
	if think_timer >= reaction_time:
		think_timer = 0.0
		update_ai_state()

	# Execute current state
	execute_ai_behavior(delta)

	# Call parent physics
	super._physics_process(delta)

func update_ai_state():
	# Find nearest enemy player
	target_player = find_nearest_enemy()

	if target_player:
		var distance = global_position.distance_to(target_player.global_position)

		if distance <= attack_range:
			ai_state = AIState.ATTACK
		elif distance <= detection_range:
			ai_state = AIState.CHASE
		else:
			ai_state = AIState.PATROL
	else:
		ai_state = AIState.PATROL

func execute_ai_behavior(delta):
	match ai_state:
		AIState.PATROL:
			execute_patrol(delta)
		AIState.CHASE:
			execute_chase(delta)
		AIState.ATTACK:
			execute_attack(delta)
		AIState.EVADE:
			execute_evade(delta)

func execute_patrol(delta):
	patrol_timer += delta

	# Move toward patrol point
	var to_patrol = patrol_target - global_position
	to_patrol.y = 0
	var distance = to_patrol.length()

	if distance < 5.0 or patrol_timer > 10.0:
		choose_new_patrol_point()
		patrol_timer = 0.0

	# Simulate movement input
	if distance > 1.0:
		var move_dir = to_patrol.normalized()
		simulate_movement_input(move_dir)

func execute_chase(delta):
	if not target_player:
		ai_state = AIState.PATROL
		return

	var to_target = target_player.global_position - global_position
	to_target.y = 0
	var distance = to_target.length()

	# Move toward target
	if distance > preferred_distance:
		var move_dir = to_target.normalized()
		simulate_movement_input(move_dir)

		# Use jetpack occasionally to close distance
		if randf() < 0.1 and jetpack_fuel > 2.0:
			simulate_jetpack_input(true)
	else:
		# At preferred distance, strafe
		var strafe_dir = to_target.normalized().rotated(Vector3.UP, PI / 2)
		simulate_movement_input(strafe_dir)

func execute_attack(delta):
	if not target_player:
		ai_state = AIState.PATROL
		return

	var to_target = target_player.global_position - global_position
	to_target.y = 0
	var distance = to_target.length()

	# Aim at target
	aim_direction = to_target.normalized()

	# Fire weapon with skill-based accuracy
	if current_ammo > 0 and randf() < skill_level:
		# Simulate firing
		if fire_cooldown <= 0:
			fire_weapon()

	# Reload if low on ammo
	if current_ammo < 10 and not is_reloading:
		start_reload()

	# Strafe while attacking
	if distance > 5.0:
		var strafe_dir = to_target.normalized().rotated(Vector3.UP, PI / 2)
		if randf() < 0.5:
			strafe_dir = -strafe_dir
		simulate_movement_input(strafe_dir)

	# Maintain distance
	if distance < 15.0:
		# Too close, back up
		simulate_movement_input(-to_target.normalized())
	elif distance > attack_range:
		# Too far, move closer
		simulate_movement_input(to_target.normalized())

func execute_evade(delta):
	# Evade incoming threats (missiles, etc.)
	# For now, just move erratically
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	simulate_movement_input(random_dir)

	# Use jetpack to evade
	if randf() < 0.3:
		simulate_jetpack_input(true)

func simulate_movement_input(direction: Vector3):
	# Simulate WASD input by setting velocity direction
	# This is a simplified AI movement
	var move_speed = config.walk_speed

	if is_on_floor():
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

func simulate_jetpack_input(activate: bool):
	if activate and jetpack_fuel > 0.5:
		jetpack_active = true
	else:
		jetpack_active = false

func find_nearest_enemy() -> Player:
	var nearest: Player = null
	var nearest_distance = INF

	# Find all players in scene
	for node in get_tree().get_nodes_in_group("players"):
		if node is Player and node != self and node.team_id != team_id:
			var distance = global_position.distance_to(node.global_position)
			if distance < nearest_distance and distance <= detection_range:
				nearest = node
				nearest_distance = distance

	return nearest

func choose_new_patrol_point():
	# Choose random point in arena
	patrol_target = Vector3(
		randf_range(-100, 100),
		0,
		randf_range(-100, 100)
	)

func set_skill_level(skill: float):
	skill_level = clamp(skill, 0.0, 1.0)

	# Adjust AI parameters based on skill
	reaction_time = lerp(0.5, 0.1, skill_level)
	detection_range = lerp(50.0, 150.0, skill_level)
	attack_range = lerp(30.0, 60.0, skill_level)
