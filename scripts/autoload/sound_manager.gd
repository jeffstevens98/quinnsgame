extends Node

# Sound pools for different categories
var weapon_sounds: Dictionary = {}
var explosion_sounds: Dictionary = {}
var ui_sounds: Dictionary = {}
var movement_sounds: Dictionary = {}

# Volume settings
var master_volume: float = 1.0
var sfx_volume: float = 0.7
var music_volume: float = 0.5

func _ready():
	# Initialize sound categories
	# Placeholder - would load actual audio files in production
	print("Sound Manager initialized")

func play_weapon_fire(weapon_name: String = "AR-45", position: Vector3 = Vector3.ZERO):
	play_3d_sound("weapon_fire", position, 0.6)

func play_weapon_reload(position: Vector3 = Vector3.ZERO):
	play_3d_sound("weapon_reload", position, 0.4)

func play_explosion(position: Vector3 = Vector3.ZERO):
	play_3d_sound("explosion", position, 1.0)

func play_jetpack_loop(player: Node3D):
	# Would create/update looping jetpack sound
	pass

func stop_jetpack_loop(player: Node3D):
	# Would stop looping jetpack sound
	pass

func play_hit_marker():
	play_2d_sound("hit_marker", 0.5)

func play_missile_launch(position: Vector3 = Vector3.ZERO):
	play_3d_sound("missile_launch", position, 0.8)

func play_missile_lock():
	play_2d_sound("missile_lock", 0.6)

func play_shield_break(position: Vector3 = Vector3.ZERO):
	play_3d_sound("shield_break", position, 0.7)

func play_footstep(position: Vector3 = Vector3.ZERO):
	play_3d_sound("footstep", position, 0.3)

func play_ui_click():
	play_2d_sound("ui_click", 0.3)

func play_ui_hover():
	play_2d_sound("ui_hover", 0.2)

# Internal sound playing functions
func play_2d_sound(sound_name: String, volume: float = 1.0):
	var player = AudioStreamPlayer.new()
	player.volume_db = linear_to_db(volume * sfx_volume * master_volume)

	# Create simple sine wave as placeholder
	# In production, would load actual audio files
	var stream = create_placeholder_sound(sound_name)
	player.stream = stream

	add_child(player)
	player.play()

	# Auto-cleanup
	player.finished.connect(func(): player.queue_free())

func play_3d_sound(sound_name: String, position: Vector3, volume: float = 1.0):
	var player = AudioStreamPlayer3D.new()
	player.global_position = position
	player.volume_db = linear_to_db(volume * sfx_volume * master_volume)
	player.max_distance = 100.0
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

	var stream = create_placeholder_sound(sound_name)
	player.stream = stream

	# Add to scene root
	get_tree().root.add_child(player)
	player.play()

	# Auto-cleanup
	player.finished.connect(func(): player.queue_free())

func create_placeholder_sound(sound_name: String) -> AudioStream:
	# Create simple audio stream as placeholder
	# In production, would return actual loaded audio files

	# For now, return null - sounds will be silent but system is in place
	# This prevents errors while the framework is functional
	return null

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
