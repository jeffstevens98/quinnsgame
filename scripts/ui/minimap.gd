extends Control

@onready var map_texture: TextureRect = $MapTexture
@onready var player_marker: Control = $MapTexture/PlayerMarker
@onready var markers_container: Control = $MapTexture/Markers

var player: Player = null
var map_size: float = 500.0  # Size of game world
var minimap_size: float = 200.0  # Size of minimap in pixels
var zoom: float = 1.0

# Marker scenes
var enemy_marker_scene = preload("res://scenes/ui/minimap_marker.tscn") if ResourceLoader.exists("res://scenes/ui/minimap_marker.tscn") else null

var tracked_entities: Dictionary = {}  # node -> marker

func _ready():
	# Set up minimap background
	if map_texture:
		map_texture.custom_minimum_size = Vector2(minimap_size, minimap_size)

func set_player(p: Player):
	player = p

func _process(_delta):
	if not player:
		return

	update_minimap()

func update_minimap():
	# Update player marker position (always center)
	if player_marker:
		player_marker.position = Vector2(minimap_size / 2, minimap_size / 2)
		player_marker.rotation = atan2(player.aim_direction.x, player.aim_direction.z)

	# Update other entities
	update_entity_markers()

func update_entity_markers():
	# Get all players
	var all_players = get_tree().get_nodes_in_group("players")

	for entity in all_players:
		if entity == player or not entity is Player:
			continue

		# Calculate position relative to player
		var relative_pos = entity.global_position - player.global_position
		var map_pos = world_to_minimap(relative_pos)

		# Check if in minimap bounds
		if is_in_minimap_bounds(map_pos):
			# Create or update marker
			if not tracked_entities.has(entity):
				create_marker_for_entity(entity)

			var marker = tracked_entities[entity]
			if marker:
				marker.position = map_pos

				# Color by team
				if entity.team_id == player.team_id:
					marker.modulate = Color(0.5, 0.5, 1.0)  # Blue for friendlies
				else:
					marker.modulate = Color(1.0, 0.5, 0.5)  # Red for enemies
		else:
			# Remove marker if out of bounds
			if tracked_entities.has(entity):
				var marker = tracked_entities[entity]
				if marker:
					marker.queue_free()
				tracked_entities.erase(entity)

	# Clean up markers for dead/removed entities
	cleanup_markers()

func create_marker_for_entity(entity: Node):
	var marker = ColorRect.new()
	marker.custom_minimum_size = Vector2(6, 6)
	marker.color = Color.WHITE

	markers_container.add_child(marker)
	tracked_entities[entity] = marker

func world_to_minimap(world_pos: Vector3) -> Vector2:
	# Convert 3D world position to 2D minimap position
	var x = (world_pos.x / map_size) * minimap_size * zoom
	var y = (world_pos.z / map_size) * minimap_size * zoom

	# Center on player
	x += minimap_size / 2
	y += minimap_size / 2

	return Vector2(x, y)

func is_in_minimap_bounds(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x <= minimap_size and pos.y >= 0 and pos.y <= minimap_size

func cleanup_markers():
	var to_remove = []

	for entity in tracked_entities:
		if not is_instance_valid(entity):
			to_remove.append(entity)

	for entity in to_remove:
		var marker = tracked_entities[entity]
		if marker:
			marker.queue_free()
		tracked_entities.erase(entity)

func set_zoom(new_zoom: float):
	zoom = clamp(new_zoom, 0.5, 2.0)
