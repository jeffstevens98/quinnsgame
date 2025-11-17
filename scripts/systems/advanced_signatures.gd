extends Node
class_name AdvancedSignatures

# Advanced signature detection system
# Implements radar, visual, and aura signatures

var config: GameConfigResource

# Signature components for a player
class SignatureProfile:
	var heat_signature: float = 0.0
	var radar_signature: float = 0.0
	var visual_signature: float = 0.0
	var aura_signature: float = 0.0
	var total_signature: float = 0.0

	func calculate_total() -> float:
		total_signature = heat_signature + radar_signature + visual_signature + aura_signature
		return total_signature

func _init():
	config = GameConfig.get_config()

# Calculate radar signature
# Affected by ECM/ECCM systems
func calculate_radar_signature(player: Player, has_ecm: bool = false, has_eccm: bool = false) -> float:
	var base_radar = 50.0  # Base radar cross-section

	# ECM reduces radar signature
	if has_ecm:
		base_radar *= (1.0 - config.ecm_effectiveness)

	# ECCM increases radar signature (anti-stealth)
	if has_eccm:
		base_radar *= (1.0 + config.eccm_effectiveness)

	# Movement increases radar signature
	var velocity_factor = player.velocity.length() / 20.0  # Normalize to ~20 m/s max
	base_radar *= (1.0 + velocity_factor * 0.5)

	return base_radar

# Calculate visual signature
# Affected by cloaking and visibility
func calculate_visual_signature(player: Player, is_cloaked: bool = false) -> float:
	var base_visual = 100.0

	# Cloaking reduces visual signature
	if is_cloaked:
		base_visual *= (1.0 - config.cloak_strength)

	# Distance affects visibility (closer = more visible)
	# This would be calculated per-observer

	# Movement increases visual signature (motion detection)
	var movement_factor = player.velocity.length() / 20.0
	base_visual *= (1.0 + movement_factor * 0.3)

	# Jetpack massively increases visual signature (bright flames)
	if player.jetpack_active:
		base_visual *= 2.0

	return base_visual

# Calculate aura signature
# Magic/energy-based detection
func calculate_aura_signature(player: Player, aura_strength: float = 1.0) -> float:
	var base_aura = aura_strength * config.aura_strength

	# Power usage increases aura
	var power_factor = player.current_power_consumption / config.reactor_max_power
	base_aura *= (1.0 + power_factor)

	# Accumulated heat affects aura
	var heat_factor = player.accumulated_heat / config.max_heat_capacity
	base_aura *= (1.0 + heat_factor * 0.5)

	return base_aura

# Calculate complete signature profile for a player
func calculate_signature_profile(player: Player, equipment_modifiers: Dictionary = {}) -> SignatureProfile:
	var profile = SignatureProfile.new()

	# Heat signature (already calculated by player)
	profile.heat_signature = player.get_heat_signature()

	# Radar signature
	var has_ecm = equipment_modifiers.get("has_ecm", false)
	var has_eccm = equipment_modifiers.get("has_eccm", false)
	profile.radar_signature = calculate_radar_signature(player, has_ecm, has_eccm)

	# Visual signature
	var is_cloaked = equipment_modifiers.get("is_cloaked", false)
	profile.visual_signature = calculate_visual_signature(player, is_cloaked)

	# Aura signature
	var aura_power = equipment_modifiers.get("aura_power", 1.0)
	profile.aura_signature = calculate_aura_signature(player, aura_power)

	profile.calculate_total()

	return profile

# Check if target is detectable by observer
func is_detectable(observer: Player, target: Player, detection_type: String = "any") -> bool:
	var target_profile = calculate_signature_profile(target)
	var distance = observer.global_position.distance_to(target.global_position)

	match detection_type:
		"heat":
			return target_profile.heat_signature > config.lock_threshold_heat

		"radar":
			# Radar has longer range but can be jammed
			var radar_range = 200.0
			return distance < radar_range and target_profile.radar_signature > 30.0

		"visual":
			# Visual has medium range and requires line of sight
			var visual_range = 100.0
			if distance > visual_range:
				return false
			return target_profile.visual_signature > 50.0

		"aura":
			# Aura detection works through walls but has short range
			return distance < config.aura_detection_range and target_profile.aura_signature > 20.0

		"any":
			# Detectable by any means
			return (target_profile.heat_signature > config.lock_threshold_heat or
					target_profile.radar_signature > 30.0 or
					target_profile.visual_signature > 50.0 or
					(distance < config.aura_detection_range and target_profile.aura_signature > 20.0))

	return false

# Get signature strength for UI display
func get_signature_display_value(player: Player) -> Dictionary:
	var profile = calculate_signature_profile(player)

	return {
		"heat": profile.heat_signature,
		"radar": profile.radar_signature,
		"visual": profile.visual_signature,
		"aura": profile.aura_signature,
		"total": profile.total_signature
	}
