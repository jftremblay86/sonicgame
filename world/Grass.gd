extends Node2D

const GrassEffect =preload("res://GrassEffect.tscn")

func Create_Grass_Effect():
	var grassEffect= GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_HurtBox_area_entered(_area):
	Create_Grass_Effect()
	queue_free()
