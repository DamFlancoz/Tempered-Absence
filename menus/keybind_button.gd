# KeybindButton.gd (Attached to the root HBoxContainer)
extends HBoxContainer

@export var action_name: String = "" # The Godot InputMap action (e.g., "jump")

@onready var action_label: Label = $Label
@onready var key_button: Button = $Button

# Signal emitted when this button is clicked and requests a rebind
signal key_rebind_requested(button: Control)

# Public function called by the main menu to set up the row
func init_action(action: String) -> void:
	action_name = action
	action_label.text = action.capitalize().replace("_", " ") # Nicer display name
	update_display()

# Updates the button text to show the currently bound key
func update_display() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	
	if events.is_empty():
		key_button.text = "UNBOUND"
	else:
		# Display the first event in the list (usually the only one)
		key_button.text = events[0].as_text().to_upper()

# Connects to the Button's 'pressed' signal
func _on_button_pressed() -> void:
	# Tell the parent menu that this button wants to start remapping
	key_rebind_requested.emit(self)
