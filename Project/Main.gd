extends Control


onready var game_widget = $GameWidget
onready var overlay = $UI/Overlay
onready var start_menu = $UI/StartMenu
onready var button_continue = $UI/StartMenu/VBoxContainer/ButtonContinue
onready var label_score = $UI/LabelScore
onready var label_moves_left = $UI/LabelMovesLeft
onready var label_time = $UI/LabelTime
onready var timer = $Timer


enum {
	GamePaused,
	GameRunning
}
var game_state = GamePaused



func _ready():
#	seed(42)
	randomize()
	game_widget.connect_signal("score_updated", self, "_on_score_updated")
	game_widget.connect_signal("available_moves", self, "_on_available_moves_updated")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
	elif event is InputEventMouseButton:
		if game_state == GameRunning:
			if event.pressed:
				game_widget.mouse_down(event.position)
			else:
				game_widget.mouse_up(event.position)

func _on_ButtonQuit_pressed() -> void:
	get_tree().quit()

func _on_ButtonNewGame_pressed() -> void:
	new_game()

func _on_ButtonContinue_pressed() -> void:
	toggle_pause()

func _on_score_updated(score) -> void:
	label_score.text = "Score : %d" % score

func _on_available_moves_updated(moves) -> void:
	label_moves_left.text = "Moves : %d" % moves

func new_game() -> void:
	overlay.hide()
	start_menu.hide()
	game_widget.init_grid()
	button_continue.disabled = false
	game_state = GameRunning
	timer.paused = false
	timer.start(1.0)

func toggle_pause() -> void:
	if game_state == GameRunning:
		game_state = GamePaused
		timer.paused = true
		overlay.show()
		start_menu.show()
	elif game_state == GamePaused:
		game_state = GameRunning
		timer.paused = false
		overlay.hide()
		start_menu.hide()

func _on_Time_timeout() -> void:
	timer.start(1.0)
	label_time.text = "Time : " + str(int(label_time.text) + 1)

