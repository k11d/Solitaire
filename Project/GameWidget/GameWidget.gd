extends Control

func _ready() -> void:
	$Grid.create_grid()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			$Grid.select_at(event.position)
		else:
			$Grid.try_move_picked_at(event.position)

func _on_GameWidget_item_rect_changed() -> void:
	var grid_view_size = $Grid.grid_size * $Grid.ball_size
	var available_size = get_rect().size
	var delta = available_size - grid_view_size
	$Grid.position = delta / 2

