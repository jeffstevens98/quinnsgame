extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_started
signal connection_failed
signal connection_succeeded

var player_info = {
	"name": "Player",
	"team": 1
}

var players = {}
var is_host = false

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func host_game(port: int = 7777, max_players: int = 16):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_players)

	if error != OK:
		print("Failed to create server: ", error)
		return false

	multiplayer.multiplayer_peer = peer
	is_host = true

	print("Server started on port ", port)
	server_started.emit()

	# Add host as player
	players[1] = player_info.duplicate()
	player_connected.emit(1, player_info)

	return true

func join_game(ip: String, port: int = 7777):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)

	if error != OK:
		print("Failed to connect to server: ", error)
		return false

	multiplayer.multiplayer_peer = peer

	print("Connecting to ", ip, ":", port)
	return true

func disconnect_from_game():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		players.clear()
		is_host = false

func _on_player_connected(id):
	print("Player connected: ", id)

	# If we're the server, wait for their info
	if is_host:
		pass

func _on_player_disconnected(id):
	print("Player disconnected: ", id)

	if players.has(id):
		players.erase(id)
		player_disconnected.emit(id)

func _on_connected_to_server():
	print("Successfully connected to server")
	connection_succeeded.emit()

	# Send our player info to server
	var my_id = multiplayer.get_unique_id()
	register_player.rpc_id(1, my_id, player_info)

func _on_connection_failed():
	print("Connection to server failed")
	multiplayer.multiplayer_peer = null
	connection_failed.emit()

@rpc("any_peer", "reliable")
func register_player(id, info):
	if not is_host:
		return

	players[id] = info
	player_connected.emit(id, info)

	# Broadcast to all players
	for peer_id in players:
		update_player.rpc_id(peer_id, id, info)

	# Send existing players to new player
	for peer_id in players:
		if peer_id != id:
			update_player.rpc_id(id, peer_id, players[peer_id])

@rpc("authority", "reliable")
func update_player(id, info):
	players[id] = info
	player_connected.emit(id, info)
