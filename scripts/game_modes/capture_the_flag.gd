extends GameModeBase
class_name CaptureTheFlag

# Capture the Flag game mode

var team1_score: int = 0
var team2_score: int = 0
var captures_to_win: int = 3

# Flag states
var team1_flag_position: Vector3 = Vector3(-100, 0, -100)
var team2_flag_position: Vector3 = Vector3(100, 0, 100)
var team1_flag_carrier: Player = null
var team2_flag_carrier: Player = null
var team1_flag_at_base: bool = true
var team2_flag_at_base: bool = true

# Flag nodes
var team1_flag: Node3D = null
var team2_flag: Node3D = null

func _ready():
	super._ready()
	spawn_flags()

func start_match():
	super.start_match()
	team1_score = 0
	team2_score = 0
	reset_flags()

func spawn_flags():
	# Create flag objects
	team1_flag = create_flag_object(team1_flag_position, Color.RED)
	team2_flag = create_flag_object(team2_flag_position, Color.BLUE)

func create_flag_object(position: Vector3, color: Color) -> Node3D:
	var flag = Node3D.new()
	flag.global_position = position

	# Create visual (simple pole + flag)
	var pole = CSGCylinder3D.new()
	pole.radius = 0.1
	pole.height = 3.0
	pole.position = Vector3(0, 1.5, 0)
	flag.add_child(pole)

	var flag_mesh = CSGBox3D.new()
	flag_mesh.size = Vector3(1.5, 1.0, 0.1)
	flag_mesh.position = Vector3(0.75, 2.5, 0)
	flag_mesh.material = StandardMaterial3D.new()
	flag_mesh.material.albedo_color = color
	flag.add_child(flag_mesh)

	# Add area for detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 2.0
	collision.shape = shape
	area.add_child(collision)
	flag.add_child(area)

	get_tree().root.add_child(flag)
	return flag

func reset_flags():
	team1_flag_at_base = true
	team2_flag_at_base = true
	team1_flag_carrier = null
	team2_flag_carrier = null

	if team1_flag:
		team1_flag.global_position = team1_flag_position
	if team2_flag:
		team2_flag.global_position = team2_flag_position

func _process(delta):
	super._process(delta)

	if not is_active:
		return

	# Update flag positions if carried
	if team1_flag_carrier:
		team1_flag.global_position = team1_flag_carrier.global_position + Vector3(0, 2, 0)
	if team2_flag_carrier:
		team2_flag.global_position = team2_flag_carrier.global_position + Vector3(0, 2, 0)

	# Check for flag captures (simplified)
	check_flag_captures()

func check_flag_captures():
	# Check if players are near flags
	# This is simplified - would need proper collision detection
	pass

func on_player_killed(killer: Player, victim: Player):
	# Drop flag if carrier is killed
	if victim == team1_flag_carrier:
		drop_flag(1)
	elif victim == team2_flag_carrier:
		drop_flag(2)

func drop_flag(team: int):
	if team == 1 and team1_flag_carrier:
		team1_flag.global_position = team1_flag_carrier.global_position
		team1_flag_carrier = null
	elif team == 2 and team2_flag_carrier:
		team2_flag.global_position = team2_flag_carrier.global_position
		team2_flag_carrier = null

func capture_flag(team: int):
	if team == 1:
		team1_score += 1
		print("Team 1 captured the flag! Score: ", team1_score)
	else:
		team2_score += 1
		print("Team 2 captured the flag! Score: ", team2_score)

	reset_flags()

	# Check win condition
	if team1_score >= captures_to_win:
		announce_winner(1)
		end_match()
	elif team2_score >= captures_to_win:
		announce_winner(2)
		end_match()

func announce_winner(team: int):
	print("Team ", team, " wins by capturing all flags!")

func get_match_state() -> Dictionary:
	var state = super.get_match_state()
	state["team1_score"] = team1_score
	state["team2_score"] = team2_score
	state["captures_to_win"] = captures_to_win
	state["team1_has_flag"] = team1_flag_carrier != null
	state["team2_has_flag"] = team2_flag_carrier != null
	return state
