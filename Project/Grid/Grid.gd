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
export(PackedScene) onready var empty_spot_scene
export(Resource) onready var colors_pool = colors_pool as ColorScheme


const ball_size := Vector2(64,64)
const grid_size := Vector2(len(OVERLAY), len(OVERLAY[0]))
var mouse_click_pos : Vector2
var hovering_ball = null
var picked_ball = null
var balls := {}
var empty_spots := {}
var score : int # the lower the better. Best score is 1

signal score_updated(score)



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
			var gpos = Vector2(x,y)
			if OVERLAY[y][x] == '1':
				balls[gpos] = null
				spawn_empty_spot(grid2real(gpos))
			elif OVERLAY[y][x] == '#':
				if !(gpos in balls):
					balls[gpos] = spawn_ball(gpos)
					score += 1
	emit_signal("score_updated", score)

func clear_grid() -> void:
	for o in get_tree().get_nodes_in_group("ball") + get_tree().get_nodes_in_group("empty"):
		o.queue_free()
		balls.clear()
		empty_spots.clear()
	score = 0

func spawn_ball(gpos : Vector2) -> Ball:
	var b : Ball = ball_base_scene.instance()
	var colors = colors_pool.color_pairs[randi() % len(colors_pool.color_pairs)]
	b.edge_color = colors[0]
	b.fill_color_0 = colors[1]
	b.fill_color_1 = colors[2]
	add_child(b)
	b.connect("mouse_hovering", self, "_on_mouse_hovering_ball")
	balls[gpos] = b
	b.position = grid2real(gpos)
	b.rotation_degrees = randf() * 360
	return b

func spawn_empty_spot(pos) -> void:
	var gpos = real2grid(pos)
	if !(gpos in empty_spots):
		var i = empty_spot_scene.instance()
		add_child(i)
		i.position = pos
		empty_spots[gpos] = i

func move_ball(ball : Ball, intent_move : Vector2) -> void:
	var jmp_from = real2grid(ball.position)
	var to_jmp_over = jmp_from + intent_move
	var dest = to_jmp_over + intent_move
	if dest.x >= 0 and dest.y >= 0 and dest.x <= 9 and dest.y <= 9:
		if to_jmp_over in balls and dest in balls:
			if balls[to_jmp_over] != null and balls[dest] == null:
				balls[dest] = ball
				balls[jmp_from] = null
				spawn_empty_spot(grid2real(to_jmp_over))
				balls[to_jmp_over].tween_fade_out_die()
				balls[to_jmp_over] = null
				spawn_empty_spot(ball.position)
				ball.tween_move_to(grid2real(dest))
				score -= 1
				emit_signal("score_updated", score)
