extends CanvasLayer

@onready var scoreboard_panel: Panel = $ScoreboardPanel
@onready var team1_label: Label = $ScoreboardPanel/VBoxContainer/Team1Score
@onready var team2_label: Label = $ScoreboardPanel/VBoxContainer/Team2Score
@onready var player_list: VBoxContainer = $ScoreboardPanel/VBoxContainer/ScrollContainer/PlayerList

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("scoreboard"):
		visible = true
		update_scoreboard()
	elif event.is_action_released("scoreboard"):
		visible = false

func update_scoreboard():
	# Update team scores
	team1_label.text = "Team 1: %d" % TeamManager.team1_score
	team2_label.text = "Team 2: %d" % TeamManager.team2_score

	# Clear player list
	for child in player_list.get_children():
		child.queue_free()

	# Get scoreboard data
	var data = TeamManager.get_scoreboard_data()

	# Add header
	var header = Label.new()
	header.text = "%-20s  %-10s  %-10s  %-10s  %-10s" % ["Name", "Team", "Kills", "Deaths", "K/D"]
	player_list.add_child(header)

	# Add players
	for player_data in data:
		var label = Label.new()
		label.text = "%-20s  %-10d  %-10d  %-10d  %-10.2f" % [
			player_data["name"],
			player_data["team"],
			player_data["kills"],
			player_data["deaths"],
			player_data["kd_ratio"]
		]

		# Color by team
		if player_data["team"] == 1:
			label.modulate = Color(1.0, 0.5, 0.5)  # Red
		else:
			label.modulate = Color(0.5, 0.5, 1.0)  # Blue

		player_list.add_child(label)
