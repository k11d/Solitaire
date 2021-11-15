extends Control

enum {
	GamePaused,
	GameRunning
}

var game_state = GamePaused


func _ready():
	seed(42)
	randomize()
	$GameWidget.connect_score_value(self, "_on_score_updated")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func _on_ButtonQuit_pressed() -> void:
	save_game()
	get_tree().quit()

func _on_ButtonNewGame_pressed() -> void:
	new_game()

func _on_ButtonContinue_pressed() -> void:
	toggle_pause()

func _on_score_updated(score) -> void:
	$UI/LabelScore.text = "Score : %d" % score

func new_game() -> void:
	$UI/Overlay.hide()
	$UI/StartMenu.hide()
	$GameWidget.init_grid()
	$UI/StartMenu/VBoxContainer/ButtonContinue.disabled = false
	game_state = GameRunning

func toggle_pause() -> void:
	if game_state == GameRunning:
		game_state = GamePaused
		$UI/Overlay.show()
		$UI/StartMenu.show()
	elif game_state == GamePaused:
		game_state = GameRunning
		$UI/Overlay.hide()
		$UI/StartMenu.hide()

func save_game() -> void:
	# TODO
	var grid_state = {
		"balls" : $GameWidget/Grid.balls,
		"empty" : $GameWidget/Grid.empty_spots,
		"score" : $GameWidget/Grid.score
	}
	
