extends Resource
class_name SignatureFormulas

# Allow custom formula definitions for equipment modifiers

@export var base_heat_signature: float = 1.0

# Equipment modifiers (can be expanded)
@export_group("Jetpack Heat Generation")
@export var jetpack_heat_multiplier: float = 1.2
@export var jetpack_heat_constant: float = 5.7

@export_group("Weapon Heat Generation")
@export var weapon_fire_heat: float = 0.5  # per shot

# Functions for custom calculations
func calculate_heat_from_jetpack(base_heat: float) -> float:
	return jetpack_heat_multiplier * base_heat + jetpack_heat_constant

func calculate_heat_from_weapon_fire(shots_fired: int) -> float:
	return weapon_fire_heat * shots_fired

# Example: Afterburner Equipment
func calculate_heat_with_afterburner(base_heat: float) -> float:
	return 1.2 * base_heat + 5.7

# Example: Stealth Coating
func calculate_radar_with_stealth(base_radar: float) -> float:
	return 0.6 * base_radar - 2.0

# Example: Power Shield
func calculate_heat_with_power_shield(base_heat: float, shield_active: bool) -> float:
	if shield_active:
		return base_heat + 15.0
	return base_heat
