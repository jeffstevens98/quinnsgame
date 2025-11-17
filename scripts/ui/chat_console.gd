extends CanvasLayer

@onready var chat_input: LineEdit = $Panel/ChatInput
@onready var panel: Panel = $Panel

var game_manager: Node3D = null

func _ready():
	visible = false
	chat_input.text_submitted.connect(_on_text_submitted)

func _input(event):
	# Open console with Enter or /
	if event is InputEventKey and not event.pressed:
		if event.keycode == KEY_SLASH or event.keycode == KEY_ENTER:
			if not visible:
				open_console()
				if event.keycode == KEY_SLASH:
					chat_input.text = "/"

	# Close console with Escape
	if event is InputEventKey and event.keycode == KEY_ESCAPE and visible:
		close_console()

func open_console():
	visible = true
	chat_input.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_console():
	visible = false
	chat_input.text = ""
	chat_input.release_focus()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_text_submitted(text: String):
	if text.strip_edges().is_empty():
		close_console()
		return

	# Process command
	if game_manager:
		game_manager.process_chat_command(text)
	else:
		print("No game manager to process command")

	close_console()

func set_game_manager(manager: Node3D):
	game_manager = manager
