extends Node
class_name GameModeBase

# Base class for game modes

signal round_ended
signal match_ended

var is_active: bool = false
var match_time: float = 0.0
var match_duration: float = 600.0  # 10 minutes default

func _ready():
	pass

func start_match():
	is_active = true
	match_time = 0.0
	print("Match started: ", get_class())

func end_match():
	is_active = false
	match_ended.emit()
	print("Match ended")

func _process(delta):
	if is_active:
		match_time += delta

		# Check time limit
		if match_time >= match_duration:
			end_match()

func on_player_killed(killer: Player, victim: Player):
	# Override in derived classes
	pass

func on_player_spawned(player: Player):
	# Override in derived classes
	pass

func get_match_state() -> Dictionary:
	return {
		"time_remaining": match_duration - match_time,
		"is_active": is_active
	}
