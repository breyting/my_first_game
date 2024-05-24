extends Node

var score = 0
var total_coins = 0
@onready var decompte = $Decompte
@onready var decompte_affichage = $Decompte_affichage
@onready var player = $"../Player"
@onready var chronometre = $"../Player/Camera2D/Chronometre"

var data = {
	"personnal" : {
		"minutes" : "00",
		"secondes" : "00",
		"msecs" : "000",
	}
}
var data_file_path = "user://results_file.json"

func _ready():
	decompte_affichage.text = str(decompte.time_left)
	decompte.start()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	chronometre.process_mode = Node.PROCESS_MODE_DISABLED
	
	print(data)
	
	# data = load_json_file(data_file_path)
	
func _process(delta):
	if int(decompte.time_left * 2) == 0:
		decompte_affichage.text = "GO"
	else:
		decompte_affichage.text = str(int(decompte.time_left * 2))
		
	# Fin de partie 
	if score == total_coins:		
		get_tree().paused = true
		get_tree().get_root().get_node("/root/Music").process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		await get_tree().create_timer(0.2).timeout
		data["personnal"]["minutes"] = "%02d" % chronometre.minutes
		data["personnal"]["secondes"] = "%02d" % chronometre.seconds
		data["personnal"]["msecs"] = "%02d" % chronometre.msec
				
		save_in_json_file(data_file_path, data)
		data = load_json_file(data_file_path)


		get_tree().change_scene_to_file("res://scenes/fin_de_partie.tscn")
		
func add_point():
	score += 1


func _on_coins_tree_entered():
	total_coins += get_node("../Coins").get_child_count()



func _on_decompte_timeout():
	decompte_affichage.visible = false
	player.process_mode = Node.PROCESS_MODE_INHERIT
	chronometre.process_mode = Node.PROCESS_MODE_INHERIT
	

func load_json_file(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		print(typeof(parsedResult))
		print(parsedResult)
		dataFile.close()
		return parsedResult
	else:
		print("File doesn't exist!")
		save_in_json_file(filePath, data)
		
	
func save_in_json_file(filePath : String, data_to_store):
		var dataFile = FileAccess.open(filePath, FileAccess.WRITE)
		dataFile.store_line(JSON.stringify(data_to_store))
		dataFile.close()
