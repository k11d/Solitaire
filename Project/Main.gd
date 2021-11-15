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

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func _on_ButtonQuit_pressed() -> void:
	get_tree().quit()


func _on_ButtonNewGame_pressed() -> void:
	new_game()

func _on_score_updated(score) -> void:
	$UI/LabelScore.text = "Score : %d" % score

func new_game() -> void:
	$CanvasLayer/Overlay.hide()
	$CanvasLayer/StartMenu.hide()
	$GameWidget.init_grid()
	$CanvasLayer/StartMenu/VBoxContainer/ButtonContinue.disabled = false
	game_state = GameRunning

func toggle_pause() -> void:
	if game_state == GameRunning:
		game_state = GamePaused
		$CanvasLayer/Overlay.show()
		$CanvasLayer/StartMenu.show()
	elif game_state == GamePaused:
		game_state = GameRunning
		$CanvasLayer/Overlay.hide()
		$CanvasLayer/StartMenu.hide()

func _on_ButtonContinue_pressed() -> void:
	toggle_pause()
