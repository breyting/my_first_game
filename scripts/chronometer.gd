extends CanvasLayer

var time: float = 0.0
@export var minutes: int = 0
@export var seconds: int = 0
@export var msec: int = 0
@onready var chronometre = $"."
@onready var Minutes = $Panel/Minutes
@onready var Seconds = $Panel/Seconds
@onready var Msecs = $Panel/Msecs
@onready var nbr_coin = $Panel/Nbr_coin

@onready var game_manager = %GameManager
var total_coins_in_game: int
var score_in_game: int

func _ready():
	chronometre.visible = true


func _process(delta) -> void:
	time += delta
	msec = fmod(time, 1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	Minutes.text = "%02d:" % minutes
	Seconds.text = "%02d." % seconds
	Msecs.text = "%02d" % msec
	
	calcul_nbr_coin()

func stop() -> void:
	set_process(false)

func get_time_fomratted() -> String:
	return "%02d:%02d.%02d" % [minutes, seconds, msec]
	
func calcul_nbr_coin():
	total_coins_in_game = get_node("%GameManager").total_coins
	score_in_game = get_node("%GameManager").score	
	nbr_coin.text = str(score_in_game) + "/" + str(total_coins_in_game)
