extends Position2D

const Player2=preload("res://Player2.tscn")

func _ready():
	var player2 = Player2.instance()
	add_child(player2)
