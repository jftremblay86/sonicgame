extends Control

onready var player1stats= get_tree().get_root().get_node("/root/PlayerStats")
onready var player2stats= get_tree().get_root().get_node("/root/Stats2Stats")
signal reloadgame


func _on_NewGame_pressed():
	get_tree().change_scene("res://World.tscn")
	emit_signal("reloadgame")
	
	

func _on_exitGame_pressed():
	get_tree().quit()


func _on_Option_pressed():
	return
