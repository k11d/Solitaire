tool
extends Area2D
class_name Ball



export(Color) var edge_color setget _set_edge_color
export(Color) var fill_color_0 setget _set_fill_color_0
export(Color) var fill_color_1 setget _set_fill_color_1

signal update_edge_color(color)
signal update_fill_color_0(color)
signal update_fill_color_1(color)

signal mouse_hovering(me)


func _on_Base_mouse_entered() -> void:
	emit_signal("mouse_hovering", self)

func apply_colors() -> void:
	if $Sprites/Edge:	
		$Sprites/Edge.modulate = edge_color
	if $Sprites/Fill0:
		$Sprites/Fill0.modulate = fill_color_0
	if $Sprites/Fill1:
		$Sprites/Fill1.modulate = fill_color_1

func _set_edge_color(col) -> void:
	edge_color = col
	emit_signal("update_edge_color", col)

func _set_fill_color_0(col) -> void:
	fill_color_0 = col
	emit_signal("update_fill_color_0", col)

func _set_fill_color_1(col) -> void:
	fill_color_1 = col
	emit_signal("update_fill_color_1", col)

