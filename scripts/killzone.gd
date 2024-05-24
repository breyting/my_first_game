extends Area2D

@onready var timer = $Timer
@onready var death_red = get_tree().get_root().get_node("/root/Game/Player/Camera2D/Chronometre/death_msg/death_red")
@onready var death_msg = get_tree().get_root().get_node("/root/Game/Player/Camera2D/Chronometre/death_msg")


var reload = 0


func _on_body_entered(body):
	Engine.time_scale = 0.5
	death_red.visible = true
	death_msg.visible = true
	body.get_node("CollisionShape2D").queue_free()
	timer.start()


func _on_timer_timeout():
	Engine.time_scale = 1
	reload += 1
	get_tree().reload_current_scene()
	
