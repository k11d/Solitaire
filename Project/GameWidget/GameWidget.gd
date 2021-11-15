extends Control


func init_grid() -> void:
	$Grid.clear_grid()
	$Grid.create_grid()

func connect_score_value(listener : Node, method : String) -> void:
	$Grid.connect("score_updated", listener, method)

func _unhandled_input(event: InputEvent) -> void:
	if get_parent().game_state == get_parent().GameRunning:
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
