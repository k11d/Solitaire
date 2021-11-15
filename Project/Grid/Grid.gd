extends Node2D

const OVERLAY := [
		['0','0','0','#','#','#','0','0','0'],
		['0','0','0','#','#','#','0','0','0'],
		['0','0','0','#','#','#','0','0','0'],
		['#','#','#','#','#','#','#','#','#'],
		['#','#','#','#','1','#','#','#','#'],
		['#','#','#','#','#','#','#','#','#'],
		['0','0','0','#','#','#','0','0','0'],
		['0','0','0','#','#','#','0','0','0'],
		['0','0','0','#','#','#','0','0','0'],
]
export(PackedScene) onready var ball_base_scene


const ball_size := Vector2(64,64)
const grid_size := Vector2(len(OVERLAY), len(OVERLAY[0]))
var mouse_click_pos : Vector2
var hovering_ball = null
var picked_ball = null
var balls := {}



func _on_mouse_hovering_ball(ball : Ball) -> void:
	hovering_ball = ball

func select_at(pos):
	mouse_click_pos = pos
	picked_ball = hovering_ball

func try_move_picked_at(pos):
	var intent_move = Vector2.ZERO
	var dhorizontal = pos.x - mouse_click_pos.x
	var dvertical = pos.y - mouse_click_pos.y
	if abs(dhorizontal) > abs(dvertical):
		if dhorizontal < 0:
			intent_move.x = -1
		else:
			intent_move.x = 1
	else:
		if dvertical < 0:
			intent_move.y = -1
		else:
			intent_move.y = 1
	move_ball(picked_ball, intent_move)

func real2grid(pos : Vector2) -> Vector2:
	var gpos = pos / ball_size
	gpos.x = int(gpos.x)
	gpos.y = int(gpos.y)
	return gpos

func grid2real(gpos : Vector2) -> Vector2:
	return gpos * ball_size + ball_size / 2

func create_grid() -> void:
	for y in range(grid_size.y):
		for x in range(grid_size.y):
			if OVERLAY[y][x] == '1':
				balls[Vector2(x,y)] = null
			elif OVERLAY[y][x] == '#':
				if !(Vector2(x,y) in balls):
					balls[Vector2(x,y)] = spawn_entity(ball_base_scene, Vector2(x,y))

func spawn_entity(scene : PackedScene, gpos : Vector2) -> Ball:
	var b : Ball = scene.instance()
	add_child(b)
	b.connect("mouse_hovering", self, "_on_mouse_hovering_ball")
	balls[gpos] = b
	b.position = grid2real(gpos)
	b.rotation_degrees = randf() * 360
	return b

func move_ball(ball : Ball, intent_move : Vector2) -> void:
	var jmp_from = real2grid(ball.position)
	var to_jmp_over = jmp_from + intent_move
	var dest = to_jmp_over + intent_move
	if dest.x >= 0 and dest.y >= 0 and dest.x <= 9 and dest.y <= 9:
		if to_jmp_over in balls and dest in balls:
			if balls[to_jmp_over] != null and balls[dest] == null:
				balls[dest] = ball
				balls[jmp_from] = null
				balls[to_jmp_over].tween_fade_out_die()
				balls[to_jmp_over] = null
				ball.tween_move_to(grid2real(dest))
