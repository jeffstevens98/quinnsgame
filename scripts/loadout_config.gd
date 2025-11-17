extends Resource
class_name LoadoutConfig

@export var loadout_name: String = "Default Knight"
@export var armor_config: GameConfigResource

# Modifiers that override base config
@export_group("Loadout Modifiers")
@export var shield_modifier: float = 1.0
@export var health_modifier: float = 1.0
@export var speed_modifier: float = 1.0
@export var heat_signature_modifier: float = 1.0
@export var jetpack_fuel_modifier: float = 1.0
@export var weapon_damage_modifier: float = 1.0

func apply_to_player(player: Player):
	# Apply modifiers to player stats
	if not armor_config:
		return

	# Modify shields
	var modified_shield_max = armor_config.shield_max * shield_modifier
	player.shield_current = modified_shield_max

	# Modify health
	var modified_health_max = armor_config.health_max * health_modifier
	player.health_current = modified_health_max

	# Modify speed (applied in movement code)
	# This would be checked in player movement

	# Note: Speed, heat signature, etc. would be applied during gameplay
	# by checking player.loadout_config in the relevant systems
