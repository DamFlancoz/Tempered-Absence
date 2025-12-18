# KeybindsMenu.gd (Attached to the root Control node)
extends Control

@onready var controls_vbox: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var prompt_panel: PanelContainer = $PanelContainer

# The scene used for each rebindable action (see section 2)
const KEYBIND_BUTTON_SCENE = preload("res://menus/keybind_button.tscn")

# Store the currently active KeybindButton instance waiting for input
var current_rebind_button: Control = null

func _ready() -> void:
	# 1. Populate the menu on startup
	populate_keybinds_list()
	
	# 2. Hide the key-press prompt
	prompt_panel.hide()

func populate_keybinds_list() -> void:
	# Clear existing controls
	for child in controls_vbox.get_children():
		child.queue_free()

	# Get a list of the actions we want to expose to the player
	# **NOTE:** These actions MUST be defined in Project Settings -> InputMap
	var rebindable_actions: Array[String] = [
		"move_up",
		"move_down",
		"move_left",
		"move_right",
		"jump",
		"attack",
		"dash"
	]
	
	# Instance a button row for each action
	for action_name in rebindable_actions:
		print(action_name)
		var keybind_button = KEYBIND_BUTTON_SCENE.instantiate()
		controls_vbox.add_child(keybind_button)
		
		# Initialize the button with the action name
		keybind_button.init_action(action_name)
		
		# Connect the signal the button emits when it's clicked
		keybind_button.key_rebind_requested.connect(_on_key_rebind_requested)

# --- Global Input Handling ---

func _on_key_rebind_requested(button: Control) -> void:
	# 1. Set the active button and show the prompt
	current_rebind_button = button
	prompt_panel.show()
	# Pause the game's main input loop if necessary
	get_tree().paused = true

# This function automatically receives all input events when visible
func _input(event: InputEvent) -> void:
	# Check if we are currently waiting for a new key
	if current_rebind_button:
		# We only care about key or mouse button presses
		if event is InputEventKey or event is InputEventMouseButton:
			
			# --- Perform the Rebind ---
			
			# 1. Clear the old binding for this action
			InputMap.action_erase_events(current_rebind_button.action_name)
			
			# 2. Add the new key/button to the InputMap
			InputMap.action_add_event(current_rebind_button.action_name, event)
			
			# 3. Inform the button to update its display text
			current_rebind_button.update_display()
			
			# 4. Cleanup and return to normal state
			current_rebind_button = null
			prompt_panel.hide()
			get_tree().paused = false
			
			# Optional: Save the new bindings immediately (see section 3)
			# GlobalSettings.save_keybinds()
			
			# Consume the event so it doesn't trigger other menus
			get_viewport().set_input_as_handled()

##################### Save global script:
## GlobalSettings.gd (Autoload)
## ... other settings logic ...
#
#const KEYBINDS_SAVE_PATH = "user://keybinds.cfg"
#
## Saves the current InputMap to a file
#func save_keybinds() -> void:
	#var config = ConfigFile.new()
	#
	#for action in InputMap.get_actions():
		#var events = InputMap.action_get_events(action)
		#
		## Store all events for the action in an array
		#var event_array = []
		#for event in events:
			#event_array.append(event)
		#
		## Write the array to the config file
		#config.set_value("Keybinds", action, event_array)
#
	#config.save(KEYBINDS_SAVE_PATH)
#
## Loads keybinds on game startup
#func load_keybinds() -> void:
	#var config = ConfigFile.new()
	#var err = config.load(KEYBINDS_SAVE_PATH)
	#
	#if err != OK:
		## No saved file, use default project settings
		#return
#
	## Clear all default bindings before loading custom ones
	#for action in InputMap.get_actions():
		#InputMap.action_erase_events(action)
	#
	## Load and apply the saved keybinds
	#var keybinds_section = config.get_section_keys("Keybinds")
	#for action in keybinds_section:
		#var events = config.get_value("Keybinds", action)
		#
		#if events is Array:
			#for event in events:
				#if event is InputEvent:
					#InputMap.action_add_event(action, event)
#
## You would call this function when the game starts (e.g., in _ready of the Autoload)
## and after the player successfully rebinds a key.
