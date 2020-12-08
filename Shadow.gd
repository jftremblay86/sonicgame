extends KinematicBody2D

const EnemyDeathEffect = preload("res://EnemyDeathEffect.tscn")



export(int) var Acceleration = 1000
export(int) var maxSpeed = 50
var velocity = Vector2.ZERO
var knockBack = Vector2.ZERO
var knockBackPower = 300
var friction =500



enum{
	IDLE,
	WALK,
	ATTACK
}

onready var state = IDLE
onready var AnimationPlayerE = $AnimationPlayer
onready var stats = $Stats
onready var playerDetectionZone= $PlayerDetectionZone
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var MinDist= $MinDist
onready var playerA = MinDist.player
onready var playerD = playerDetectionZone.player

func _physics_process(delta):
	knockBack = knockBack.move_toward(Vector2.ZERO, friction * delta)
	knockBack= move_and_slide(knockBack)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	match state:
		IDLE:
			AnimationPlayerE.play("idle")
			seek_player()	
						
		WALK:
			seek_player()
			AnimationPlayerE.play("run")
			if velocity.x < 0:
				get_node( "Sprite" ).set_flip_h( true )
			else:
				get_node( "Sprite" ).set_flip_h( false )
			var player = playerDetectionZone.player			
			if player !=null:
				accelerate_towards_point(player.global_position, delta)

			
		ATTACK:
			seek_player()
			AnimationPlayerE.play("attack")
			if velocity.x < 0:
				get_node( "Sprite" ).set_flip_h( true )
			else:
				get_node( "Sprite" ).set_flip_h( false )

				
			#sprite.flip_h = velocity.x < 0
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta *400
	velocity = move_and_slide(velocity)
	
	

func accelerate_towards_point(position, delta):
	var direction = global_position.direction_to(position)
	velocity= velocity.move_toward(direction * maxSpeed,Acceleration * delta)	
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = WALK
		if MinDist.can_see_player():
			state = ATTACK
	else:
		state = IDLE



func _on_Stats_no_health():
	queue_free()
	var enemtDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemtDeathEffect)
	enemtDeathEffect.global_position =global_position
	get_tree().change_scene("res://StartMenu.tscn")


func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockBack = area.knockback_vector * knockBackPower
	hurtBox.create_hit_effect()
