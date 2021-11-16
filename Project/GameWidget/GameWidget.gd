extends Control
class_name GameWidget

func init_grid() -> Node:
	$Grid.clear_grid()
	$Grid.create_grid()
	return $Grid

func connect_signal(sig : String, listener : Node, method : String) -> void:
	$Grid.connect(sig, listener, method)

func mouse_down(pos):
	$Grid.select_at(pos)

func mouse_up(pos):
	$Grid.try_move_picked_at(pos)

func _on_GameWidget_item_rect_changed() -> void:
	var grid_view_size = $Grid.grid_size * $Grid.ball_size
	var available_size = get_rect().size
	var delta = available_size - grid_view_size
	$Grid.position = delta / 2
