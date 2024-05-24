extends Label

@onready var fin_de_partie = $".."

@onready var score = $"."
@onready var leaderboard = $"../Leaderboard"
@onready var personnal_best = $"../Personnal_best"

@onready var center_container = $"../CenterContainer"
@onready var line_edit = $"../CenterContainer/LineEdit"
var player_name = ""
var temps_run = ""

const CONST_CALCUL_SCORE = 100000

var data = {}
var data_file_path = "user://results_file.json"

var restart_input_event

# Called when the node enters the scene tree for the first time.
func _ready():
	restart_input_event = InputMap.action_get_events("restart")
	InputMap.erase_action("restart")
	
	get_tree().paused = true
	
	line_edit.grab_focus()
	line_edit.set_caret_column(len(text))
	
	SilentWolf.configure({
	"api_key": "A2QoHFLHUZ9AYgF286zNC5dad31xugv432N8F9Ew",
	"game_id": "firstgame1",
	"log_level": 1
	})
	
	data = load_json_file(data_file_path)
	print(data)
	
	temps_run = CONST_CALCUL_SCORE - int(data["personnal"]["minutes"] + data["personnal"]["secondes"] + data["personnal"]["msecs"])
	print(temps_run)
	
	score.text = "You collected all the coins in \n" + data["personnal"]["minutes"] + ":" + data["personnal"]["secondes"] + "." + data["personnal"]["msecs"]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_json_file(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		dataFile.close()
		return parsedResult
		
	else:
		print("File doesn't exist!")
	
	

func _on_line_edit_text_submitted(new_text):
	player_name = line_edit.text
	center_container.process_mode = Node.PROCESS_MODE_DISABLED
	center_container.visible = false
	print(player_name + " a encodé son nom")
	
	#SilentWolf.Scores.wipe_leaderboard()
	
	var top_player_score = await SilentWolf.Scores.get_top_score_by_player(player_name,1).sw_top_player_score_complete 
	print("Does player have a top score? " + str(top_player_score.has("top_score")))
	print("Got top player score: " + str(top_player_score))
	print("top player null ? = " + str(top_player_score.has("top_score")))
		
	if !top_player_score.has("top_score") or temps_run > top_player_score.top_score.score:
			save_score()

	if top_player_score.has("top_score") and temps_run > top_player_score.top_score.score:
		personnal_best.text += data["personnal"]["minutes"] + ":" + data["personnal"]["secondes"] + "." + data["personnal"]["msecs"]
	elif !top_player_score.has("top_score"):
		personnal_best.text += data["personnal"]["minutes"] + ":" + data["personnal"]["secondes"] + "." + data["personnal"]["msecs"]
	else:
		var minutes
		var secondes
		var msec
		
		for score in top_player_score.top_score.score:
			score= CONST_CALCUL_SCORE - score
			msec = str("%02d" % (int(score) % 100))
			score = int(score)/100
			secondes = str("%02d" % (score % 100))
			score = score/100
			minutes = str("%02d" % (score % 100))
		personnal_best.text += minutes + ":" + secondes + "." + msec

	await get_tree().create_timer(1).timeout
	get_high_scores()
	
	for input_event in restart_input_event:
		InputMap.add_action("restart")
		InputMap.action_add_event("restart", input_event)
		
func save_score():
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(player_name, temps_run).sw_save_score_complete
	print("Score persisted successfully: " + str(sw_result.score_id))
		
		
func  get_high_scores():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(5).sw_get_scores_complete
	print("Scores: " + str(sw_result.scores))
	for score in sw_result.scores:
		score.score = CONST_CALCUL_SCORE - score.score
		var msec = str("%02d" % (int(score.score) % 100))
		score.score = int(score.score)/100
		var secondes = str("%02d" % (score.score % 100))
		score.score = score.score/100
		var minutes = str("%02d" % (score.score % 100))

		leaderboard.text += score.player_name + " : " + minutes + ":" + secondes + "." + msec + "\n"

func _input(event):
	if Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/game.tscn")
		
