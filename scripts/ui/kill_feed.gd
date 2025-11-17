extends VBoxContainer

const MAX_ENTRIES = 5
const ENTRY_LIFETIME = 5.0

func add_kill(killer_name: String, victim_name: String, weapon: String = "AR-45"):
	# Create kill entry
	var entry = Label.new()
	entry.text = "%s  [%s]  %s" % [killer_name, weapon, victim_name]
	entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Color based on if local player is involved
	# (would need player reference to implement)
	entry.modulate = Color(1.0, 1.0, 1.0, 1.0)

	add_child(entry)
	move_child(entry, 0)  # Add to top

	# Fade out and remove
	await get_tree().create_timer(ENTRY_LIFETIME - 1.0).timeout

	var tween = create_tween()
	tween.tween_property(entry, "modulate:a", 0.0, 1.0)

	await tween.finished
	entry.queue_free()

	# Maintain max entries
	while get_child_count() > MAX_ENTRIES:
		get_child(get_child_count() - 1).queue_free()

func add_death(player_name: String, cause: String = ""):
	var entry = Label.new()

	if cause.is_empty():
		entry.text = "%s died" % player_name
	else:
		entry.text = "%s died (%s)" % [player_name, cause]

	entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	entry.modulate = Color(0.8, 0.8, 0.8, 1.0)

	add_child(entry)
	move_child(entry, 0)

	# Fade out
	await get_tree().create_timer(ENTRY_LIFETIME - 1.0).timeout

	var tween = create_tween()
	tween.tween_property(entry, "modulate:a", 0.0, 1.0)

	await tween.finished
	entry.queue_free()

	while get_child_count() > MAX_ENTRIES:
		get_child(get_child_count() - 1).queue_free()
