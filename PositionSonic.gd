extends Position2D
const Player=preload("res://Player.tscn")
onready var stats = PlayerStats

func _ready():
	var player = Player.instance()
	add_child(player)
	stats.health = stats.max_health
