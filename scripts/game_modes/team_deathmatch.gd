extends GameModeBase
class_name TeamDeathmatch

# Team Deathmatch game mode

var team1_score: int = 0
var team2_score: int = 0
var score_limit: int = 50

func _ready():
	super._ready()

func start_match():
	super.start_match()
	team1_score = 0
	team2_score = 0

func on_player_killed(killer: Player, victim: Player):
	# Award point to killer's team
	if killer and killer.team_id == 1:
		team1_score += 1
	elif killer and killer.team_id == 2:
		team2_score += 1

	# Check for win condition
	if team1_score >= score_limit:
		announce_winner(1)
		end_match()
	elif team2_score >= score_limit:
		announce_winner(2)
		end_match()

func announce_winner(team: int):
	print("Team ", team, " wins!")

func get_match_state() -> Dictionary:
	var state = super.get_match_state()
	state["team1_score"] = team1_score
	state["team2_score"] = team2_score
	state["score_limit"] = score_limit
	return state
