extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts
var hearts2 = 4 setget set_hearts
var max_hearts2 = 4 setget set_max_hearts
onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var player1 = get_tree().get_root().get_node("/root/Player")
onready var startMenu = get_tree().get_root().get_node("/root/StartMenu")
var test =0

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts *15
		

	
func set_max_hearts(value):
	max_hearts= max(value,1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty !=null:
		heartUIEmpty.rect_size.x = max_hearts *15
	
func _ready():
	startMenu.connect("reloadgame",self,"reloadScene")
	player1.connect("player1dead",self,"changeToPlayer2")
	
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health

	PlayerStats.connect("health_changed",self , "set_hearts")
	PlayerStats.connect("max_health_changed",self, "set_max_hearts")

func changeToPlayer2():
	self.max_hearts = Stats2Stats.max_health
	self.hearts = Stats2Stats.health
	Stats2Stats.connect("health_changed",self , "set_hearts")
	Stats2Stats.connect("max_health_changed",self, "set_max_hearts")
	
func reloadScene():
	get_tree().reload_current_scene()

	
	
	
