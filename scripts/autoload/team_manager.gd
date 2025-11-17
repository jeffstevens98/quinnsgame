extends Node

var team1_players: Array[int] = []
var team2_players: Array[int] = []

var team1_score: int = 0
var team2_score: int = 0

var player_stats: Dictionary = {}  # peer_id -> {kills, deaths, team}

func _ready():
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)

func _on_player_connected(peer_id, player_info):
	# Auto-assign to team with fewer players
	var team = get_smaller_team()

	if team == 1:
		team1_players.append(peer_id)
	else:
		team2_players.append(peer_id)

	# Initialize stats
	player_stats[peer_id] = {
		"kills": 0,
		"deaths": 0,
		"team": team
	}

	print("Assigned player ", peer_id, " to team ", team)

func _on_player_disconnected(peer_id):
	# Remove from teams
	if peer_id in team1_players:
		team1_players.erase(peer_id)
	if peer_id in team2_players:
		team2_players.erase(peer_id)

	# Remove stats
	if player_stats.has(peer_id):
		player_stats.erase(peer_id)

func get_smaller_team() -> int:
	if team1_players.size() <= team2_players.size():
		return 1
	else:
		return 2

func get_player_team(peer_id: int) -> int:
	if player_stats.has(peer_id):
		return player_stats[peer_id]["team"]
	return 1

func record_kill(killer_id: int, victim_id: int):
	if player_stats.has(killer_id):
		player_stats[killer_id]["kills"] += 1

		# Add to team score
		var team = player_stats[killer_id]["team"]
		if team == 1:
			team1_score += 1
		else:
			team2_score += 1

	if player_stats.has(victim_id):
		player_stats[victim_id]["deaths"] += 1

func get_scoreboard_data() -> Array:
	var data = []

	for peer_id in player_stats:
		var stats = player_stats[peer_id]
		var kd_ratio = 0.0

		if stats["deaths"] > 0:
			kd_ratio = float(stats["kills"]) / float(stats["deaths"])
		else:
			kd_ratio = float(stats["kills"])

		data.append({
			"peer_id": peer_id,
			"name": "Player" + str(peer_id),
			"team": stats["team"],
			"kills": stats["kills"],
			"deaths": stats["deaths"],
			"kd_ratio": kd_ratio
		})

	# Sort by kills
	data.sort_custom(func(a, b): return a["kills"] > b["kills"])

	return data

func switch_team(peer_id: int, new_team: int):
	if not player_stats.has(peer_id):
		return

	# Remove from old team
	var old_team = player_stats[peer_id]["team"]
	if old_team == 1:
		team1_players.erase(peer_id)
	else:
		team2_players.erase(peer_id)

	# Add to new team
	if new_team == 1:
		team1_players.append(peer_id)
	else:
		team2_players.append(peer_id)

	player_stats[peer_id]["team"] = new_team
	print("Player ", peer_id, " switched to team ", new_team)
