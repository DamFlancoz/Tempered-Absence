extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("../../Player").health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int, old_health: int) -> void:
	text = "HP: " + str(new_health)
