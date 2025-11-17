extends CanvasLayer

var player: Player = null
var config: GameConfigResource

# HUD element references
@onready var shield_bar: ProgressBar = $HUDContainer/BottomCenter/ResourceBars/LeftSide/ShieldBar
@onready var health_bar: ProgressBar = $HUDContainer/BottomCenter/ResourceBars/LeftSide/HealthBar
@onready var shield_label: Label = $HUDContainer/BottomCenter/ResourceBars/LeftSide/ShieldBar/Label
@onready var health_label: Label = $HUDContainer/BottomCenter/ResourceBars/LeftSide/HealthBar/Label

@onready var heat_gauge: ProgressBar = $HUDContainer/BottomCenter/ResourceBars/Center/HeatGauge
@onready var heat_label: Label = $HUDContainer/BottomCenter/ResourceBars/Center/HeatGauge/Label

@onready var signature_bar: ProgressBar = $HUDContainer/BottomCenter/ResourceBars/RightSide/SignatureBar
@onready var power_label: Label = $HUDContainer/BottomCenter/ResourceBars/RightSide/PowerLabel

@onready var fuel_label: Label = $HUDContainer/TopRight/FuelLabel
@onready var ammo_label: Label = $HUDContainer/BottomRight/AmmoLabel
@onready var speed_label: Label = $HUDContainer/BottomLeft/SpeedLabel

@onready var crosshair: Control = $HUDContainer/CenterContainer/Crosshair
@onready var lock_indicator: Label = $HUDContainer/CenterContainer/LockIndicator
@onready var missile_warning: Label = $HUDContainer/TopCenter/MissileWarning

func _ready():
	config = GameConfig.get_config()

	# Configure progress bars
	if shield_bar:
		shield_bar.max_value = config.shield_max
	if health_bar:
		health_bar.max_value = config.health_max
	if heat_gauge:
		heat_gauge.max_value = 120  # Percentage (can go over 100%)
	if signature_bar:
		signature_bar.max_value = 300  # MW

func set_player(p: Player):
	player = p

	# Connect to player signals
	if player:
		player.hit_confirmed.connect(_on_hit_confirmed)

func _process(_delta):
	if not player:
		return

	update_hud()

func update_hud():
	# Update shields
	if shield_bar and shield_label:
		shield_bar.value = player.shield_current
		shield_label.text = "%d / %d" % [int(player.shield_current), int(config.shield_max)]

		# Flash red when taking damage
		if player.time_since_last_damage < 0.2:
			shield_bar.modulate = Color(1, 0.3, 0.3)
		else:
			shield_bar.modulate = Color(1, 1, 1)

	# Update health
	if health_bar and health_label:
		health_bar.value = player.health_current
		health_label.text = "%d / %d" % [int(player.health_current), int(config.health_max)]

		# Pulse when critical
		if player.health_current < config.health_max * 0.3:
			var pulse = (sin(Time.get_ticks_msec() / 200.0) + 1.0) / 2.0
			health_bar.modulate = Color(1, pulse * 0.3, pulse * 0.3)
		else:
			health_bar.modulate = Color(1, 1, 1)

	# Update heat gauge
	if heat_gauge and heat_label:
		var heat_percentage = (player.accumulated_heat / config.max_heat_capacity) * 100.0
		heat_gauge.value = heat_percentage
		heat_label.text = "%d%%" % int(heat_percentage)

		# Color gradient based on heat
		if heat_percentage < 50:
			heat_gauge.modulate = Color(0.3, 0.5, 1.0)  # Blue
		elif heat_percentage < 80:
			heat_gauge.modulate = Color(1.0, 1.0, 0.3)  # Yellow
		elif heat_percentage < 100:
			heat_gauge.modulate = Color(1.0, 0.6, 0.2)  # Orange
		else:
			# Flashing red when overheating
			var flash = (sin(Time.get_ticks_msec() / 100.0) + 1.0) / 2.0
			heat_gauge.modulate = Color(1.0, flash * 0.2, flash * 0.2)

	# Update heat signature
	if signature_bar:
		signature_bar.value = player.heat_signature

	# Update power consumption
	if power_label:
		power_label.text = "Power: %d MW" % int(player.current_power_consumption)

	# Update fuel
	if fuel_label:
		fuel_label.text = "Fuel: %.2f kg" % player.jetpack_fuel

	# Update ammo
	if ammo_label:
		ammo_label.text = "%d / %d\nMissiles: %d" % [
			player.current_ammo,
			player.reserve_ammo,
			player.missile_ammo
		]

	# Update speed
	if speed_label:
		var speed = Vector3(player.velocity.x, 0, player.velocity.z).length()
		speed_label.text = "Speed: %.1f m/s" % speed

	# Update lock indicator
	if lock_indicator:
		if player.locking_target:
			var lock_percent = int(player.lock_progress * 100)
			lock_indicator.text = "LOCKING... %d%%" % lock_percent
			lock_indicator.visible = true
		elif player.locked_target:
			lock_indicator.text = "LOCKED"
			lock_indicator.visible = true
		else:
			lock_indicator.visible = false

func _on_hit_confirmed():
	# Show hit marker
	var hit_marker_scene = preload("res://scenes/hit_marker.tscn")
	var hit_marker = hit_marker_scene.instantiate()
	add_child(hit_marker)

	# Position at screen center
	hit_marker.position = get_viewport().get_visible_rect().size / 2.0
