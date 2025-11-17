extends Node3D

# Spawn points for teams
@export var team1_spawns: Array[Vector3] = []
@export var team2_spawns: Array[Vector3] = []

# Player management
var players: Dictionary = {}  # peer_id -> Player
var player_scene = preload("res://scenes/player.tscn")
var hud_scene = preload("res://scenes/hud.tscn")

# Local player reference
var local_player: Player = null
var local_hud: CanvasLayer = null
var scoreboard: CanvasLayer = null
var chat_console: CanvasLayer = null

func _ready():
	# Set up default spawn points if none defined
	if team1_spawns.is_empty():
		team1_spawns = [
			Vector3(-100, 5, -100),
			Vector3(-90, 5, -100),
			Vector3(-100, 5, -90),
			Vector3(-90, 5, -90)
		]

	if team2_spawns.is_empty():
		team2_spawns = [
			Vector3(100, 5, 100),
			Vector3(90, 5, 100),
			Vector3(100, 5, 90),
			Vector3(90, 5, 90)
		]

	# Load UI scenes
	var scoreboard_scene = preload("res://scenes/scoreboard.tscn")
	scoreboard = scoreboard_scene.instantiate()
	add_child(scoreboard)

	var chat_scene = preload("res://scenes/chat_console.tscn")
	chat_console = chat_scene.instantiate()
	add_child(chat_console)
	chat_console.set_game_manager(self)

	# For single player testing, spawn a local player
	if not multiplayer.has_multiplayer_peer():
		spawn_local_player()

func spawn_local_player():
	var player = player_scene.instantiate()
	player.player_id = 1
	player.player_name = "Player1"
	player.team_id = 1
	add_child(player)

	# Position at team spawn
	var spawn_pos = team1_spawns[0]
	player.global_position = spawn_pos

	local_player = player

	# Create HUD
	local_hud = hud_scene.instantiate()
	add_child(local_hud)
	local_hud.set_player(player)

	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func get_spawn_position(team: int) -> Vector3:
	var spawns = team1_spawns if team == 1 else team2_spawns
	if spawns.is_empty():
		return Vector3(0, 5, 0)
	return spawns[randi() % spawns.size()]

func _input(event):
	# Toggle mouse capture
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Chat commands
	if event is InputEventKey and event.keycode == KEY_SLASH and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func process_chat_command(command: String):
	var parts = command.split(" ")
	var cmd = parts[0].to_lower()

	if not local_player:
		return

	match cmd:
		"/team":
			if parts.size() > 1:
				var team = parts[1].to_int()
				local_player.team_id = team
				print("Switched to team ", team)

		"/godmode":
			# Toggle godmode (infinite health/shields)
			print("Godmode toggled (not implemented yet)")

		"/refill":
			local_player.refill_resources()
			print("Resources refilled")

		"/speed":
			if parts.size() > 1:
				var mult = parts[1].to_float()
				GameConfig.config.walk_speed = 5.0 * mult
				print("Speed multiplier set to ", mult)

		"/heat":
			if parts.size() > 1:
				var value = parts[1].to_float()
				local_player.accumulated_heat = value
				print("Heat set to ", value)

		"/sig":
			if parts.size() > 1:
				var value = parts[1].to_float()
				local_player.heat_signature = value
				print("Signature set to ", value)

		"/cooldown":
			if parts.size() > 1:
				var mult = parts[1].to_float()
				GameConfig.config.passive_cooling_rate = 2.0 * mult
				print("Cooling rate multiplier set to ", mult)

		"/noclip":
			print("Noclip toggled (not implemented yet)")

		_:
			print("Unknown command: ", cmd)
