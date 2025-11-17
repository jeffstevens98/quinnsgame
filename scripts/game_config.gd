extends Resource
class_name GameConfigResource

# === MOVEMENT CONFIG ===
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_multiplier: float = 1.5
@export var crawl_speed: float = 1.5
@export var jump_force: float = 10.0
@export var dive_force: float = 8.0

@export_group("Skiing")
@export var ski_friction: float = 0.05
@export var normal_friction: float = 0.8
@export var ski_air_control: float = 0.3

@export_group("Jetpack")
@export var jetpack_acceleration: float = 29.4  # 3G
@export var jetpack_turn_rate: float = 90.0
@export var jetpack_fuel_max: float = 5.0
@export var jetpack_fuel_consumption: float = 0.00416

@export_group("Physics")
@export var gravity: float = 9.8
@export var air_control: float = 0.6
@export var turn_rate_ground: float = 180.0
@export var body_lag_factor: float = 0.3

# === POWER & HEAT CONFIG ===
@export_group("Power System")
@export var reactor_max_power: float = 800.0  # MW
@export var reactor_instant_heat: float = 200.0  # MW
@export var reactor_accumulated_heat: float = 6.0  # MW
@export var heat_from_power_use: float = 0.15

@export_group("Heat Management")
@export var passive_cooling_rate: float = 2.0
@export var active_cooling_rate: float = 5.0
@export var max_heat_capacity: float = 100.0
@export var overheat_damage_rate: float = 10.0
@export var heat_signature_multiplier: float = 1.0
@export var exponential_decay_rate: float = 0.5

# === RESOURCE CONFIG ===
@export_group("Shields")
@export var shield_max: float = 100.0
@export var shield_regen_rate: float = 10.0
@export var shield_regen_delay: float = 3.0
@export var shield_regen_delay_break: float = 6.0

@export_group("Health")
@export var health_max: float = 150.0
@export var health_regen_rate: float = 2.0
@export var health_regen_delay: float = 8.0

# === WEAPON CONFIG ===
@export_group("AR-45 Liberator")
@export var magazine_size: int = 45
@export var reserve_ammo: int = 360
@export var damage_per_shot: float = 60.0
@export var fire_rate: float = 640.0
@export var reload_time: float = 3.0
@export var recoil_per_shot: float = 0.8
@export var recoil_recovery: float = 5.0
@export var spread_min: float = 0.5
@export var spread_max: float = 4.0
@export var spread_increase: float = 0.3
@export var spread_recovery: float = 2.0
@export var projectile_speed: float = 800.0
@export var damage_falloff_start: float = 50.0
@export var damage_falloff_end: float = 150.0

@export_group("Melee")
@export var melee_stab_damage: float = 40.0
@export var melee_stab_cooldown: float = 0.4
@export var melee_butt_damage: float = 80.0
@export var melee_butt_cooldown: float = 1.2
@export var melee_butt_stun: float = 0.5
@export var melee_range: float = 2.0

# === SIGNATURE CONFIG ===
@export_group("Heat Signature")
@export var lock_threshold_heat: float = 150.0
@export var signature_decay_immediate: float = 0.8

# Placeholder for future signatures
@export_group("Other Signatures (Unused)")
@export var ecm_effectiveness: float = 1.0
@export var eccm_effectiveness: float = 1.0
@export var cloak_strength: float = 1.0
@export var aura_strength: float = 1.0
@export var aura_detection_range: float = 50.0

# === MISSILE CONFIG ===
@export_group("Missile Properties")
@export var missile_speed: float = 150.0
@export var missile_turn_rate: float = 120.0
@export var missile_lifetime: float = 10.0
@export var missile_fuel: float = 8.0
@export var missile_damage: float = 150.0
@export var missile_aoe_radius: float = 5.0
@export var missile_aoe_falloff: float = 0.5

@export_group("Missile Lock-On")
@export var lock_on_time: float = 2.0
@export var lock_on_range: float = 300.0
@export var lock_on_angle: float = 15.0
@export var lock_bonus_tracking: float = 1.5

@export_group("Missile Launch")
@export var missile_cooldown: float = 3.0
@export var missile_ammo: int = 12

@export_group("Missile Guidance")
@export var guidance_strength: float = 3.0
@export var signature_tracking_mult: float = 1.0

# === CAMERA CONFIG ===
@export_group("Camera")
@export var camera_distance: float = 8.0
@export var camera_height: float = 3.0
@export var camera_angle: float = 30.0  # degrees
@export var camera_lerp_factor: float = 0.15
