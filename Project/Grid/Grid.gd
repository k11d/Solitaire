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

# Simple grid, for testing purpose
#const OVERLAY := [
#		['0','0','0','1','1','1','0','0','0'],
#		['0','0','0','1','1','1','0','0','0'],
#		['0','0','0','1','1','1','0','0','0'],
#		['1','1','1','1','1','1','1','1','1'],
#		['1','1','1','1','#','#','1','1','1'],
#		['1','1','1','1','1','1','1','1','1'],
#		['0','0','0','1','1','1','0','0','0'],
#		['0','0','0','1','1','1','0','0','0'],
#		['0','0','0','1','1','1','0','0','0'],
#]

export(PackedScene) onready var ball_base_scene
export(PackedScene) onready var empty_spot_scene
export(Resource) onready var colors_pool = colors_pool as ColorScheme


const ball_size := Vector2(64,64)
const grid_size := Vector2(len(OVERLAY), len(OVERLAY[0]))
var mouse_click_pos : Vector2
var hovering_ball = null
var picked_ball = null
var balls := {}

var score : int # the lower the better. Best score is 1
var moves_left : int
signal score_updated(score)
signal available_moves(moves_left)


func _on_mouse_hovering_ball(ball : Ball) -> void:
	hovering_ball = ball

func select_at(pos):
	mouse_click_pos = pos
	picked_ball = hovering_ball

func try_move_picked_at(pos):
	if picked_ball:
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
				spawn_empty_spot(gpos)
			elif OVERLAY[y][x] == '#':
				spawn_ball(gpos)
				score += 1
	emit_signal("score_updated", score)
	count_available_moves()

func clear_grid() -> void:
	for o in get_tree().get_nodes_in_group("ball") + get_tree().get_nodes_in_group("empty"):
		o.queue_free()
		balls.clear()
	score = 0

func spawn_ball(gpos : Vector2) -> void:
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

func spawn_empty_spot(gpos) -> void:
	var i = empty_spot_scene.instance()
	add_child(i)
	balls[gpos] = i
	i.position = grid2real(gpos)

func move_ball(ball : Ball, intent_move : Vector2) -> void:
	if ball == null:
		return
	var jmp_from = real2grid(ball.position)
	var to_jmp_over = jmp_from + intent_move
	var dest = to_jmp_over + intent_move
	if to_jmp_over in balls and dest in balls:
		var _balls = get_tree().get_nodes_in_group("ball")
		var _empties = get_tree().get_nodes_in_group("empty")
		if balls[to_jmp_over] in _balls and balls[dest] in _empties:
#			print("Before move, grid contains: %s balls and %s empty spots" % [len(_balls), len(_empties)])
			balls[dest].free()
			balls[dest] = ball
			spawn_empty_spot(jmp_from)
			balls[to_jmp_over].free()
			spawn_empty_spot(to_jmp_over)
#				balls[to_jmp_over].tween_fade_out_die()
#				ball.tween_move_to(grid2real(dest), funcref(empty_dest, "queue_free"))
			ball.position = grid2real(dest)
			score -= 1
			emit_signal("score_updated", score)
			count_available_moves()
#			_balls = get_tree().get_nodes_in_group("ball")
#			_empties = get_tree().get_nodes_in_group("empty")
#			print("After move, grid contains: %s balls and %s empty spots" % [len(_balls), len(_empties)])

func count_available_moves() -> void:
	var _balls = get_tree().get_nodes_in_group("ball")
	var _empties = get_tree().get_nodes_in_group("empty")
	moves_left = 0
	var moves = {}
	for bpos in balls:
		if balls[bpos] in _balls:
			moves[balls[bpos]] = []
			var east = bpos + Vector2(-1, 0)
			if east in balls and balls[east] in _balls:
				var east_dest = east + Vector2(-1, 0)
				if east_dest in balls and balls[east_dest] in _empties:
					moves[balls[bpos]].append(east_dest)
			var west = bpos + Vector2(1, 0)
			if west in balls and balls[west] in _balls:
				var west_dest = west + Vector2(1, 0)
				if west_dest in balls and balls[west_dest] in _empties:
					moves[balls[bpos]].append(west_dest)
			var north = bpos + Vector2(0, -1)
			if north in balls and balls[north] in _balls:
				var north_dest = north + Vector2(0, -1)
				if north_dest in balls and balls[north_dest] in _empties:
					moves[balls[bpos]].append(north_dest)
			var south = bpos + Vector2(0, 1)
			if south in balls and balls[south] in _balls:
				var south_dest = south + Vector2(0, 1)
				if south_dest in balls and balls[south_dest] in _empties:
					moves[balls[bpos]].append(south_dest)
			moves_left += len(moves[balls[bpos]]) 
	emit_signal("available_moves", moves_left)


