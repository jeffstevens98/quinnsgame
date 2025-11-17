extends Control

@onready var host_button: Button = $MenuContainer/HostButton
@onready var join_button: Button = $MenuContainer/JoinButton
@onready var single_player_button: Button = $MenuContainer/SinglePlayerButton
@onready var ip_input: LineEdit = $MenuContainer/IPInput
@onready var port_input: LineEdit = $MenuContainer/PortInput
@onready var status_label: Label = $MenuContainer/StatusLabel

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	single_player_button.pressed.connect(_on_single_player_pressed)

	NetworkManager.server_started.connect(_on_server_started)
	NetworkManager.connection_succeeded.connect(_on_connection_succeeded)
	NetworkManager.connection_failed.connect(_on_connection_failed)

	# Set default values
	ip_input.text = "127.0.0.1"
	port_input.text = "7777"

func _on_host_pressed():
	var port = port_input.text.to_int()

	status_label.text = "Starting server..."

	if NetworkManager.host_game(port):
		status_label.text = "Server started successfully!"
	else:
		status_label.text = "Failed to start server"

func _on_join_pressed():
	var ip = ip_input.text
	var port = port_input.text.to_int()

	status_label.text = "Connecting to server..."

	if NetworkManager.join_game(ip, port):
		status_label.text = "Connecting..."
	else:
		status_label.text = "Failed to connect"

func _on_single_player_pressed():
	# Load game world directly
	status_label.text = "Starting single player..."
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _on_server_started():
	# Server started, transition to game
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _on_connection_succeeded():
	# Connected to server, transition to game
	status_label.text = "Connected! Loading game..."
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _on_connection_failed():
	status_label.text = "Connection failed!"
