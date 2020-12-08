extends Node2D

onready var startMenu = get_tree().get_root().get_node("/root/StartMenu")
onready var player1 = get_tree().get_root().get_node("/root/Player")
onready var player2= get_tree().get_root().get_node("/root/Player2")


func _ready():
	startMenu.connect("reloadgame",self,"reloadScene")
	player2.connect("p2Dead",self,"dead")
	player1.connect("player1dead",self,"changecamera")

func reloadScene():
	get_tree().reload_current_scene()

func dead():
	get_tree().change_scene(startMenu)


func changecamera():
	$YSort/Player/RemoteP1.use_global_coordinates = false
	$YSort/Player2/RemoteP2.use_global_coordinates = true


func _on_Button_pressed():
	get_tree().change_scene("res://StartMenu.tscn")
