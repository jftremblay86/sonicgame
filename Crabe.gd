extends KinematicBody2D

const EnemyDeathEffect = preload("res://EnemyDeathEffect.tscn")

export(int) var Acceleration = 500
export(int) var maxSpeed = 50
var velocity = Vector2.ZERO
var knockBack = Vector2.ZERO
var knockBackPower = 300
var friction =500

enum{
	IDLE,
	WANDER,
	CHASE
}

onready var state = pick_random_state([IDLE, WANDER])

onready var sprite = $Animsprite
onready var stats = $Stats
onready var playerDetectionZone= $PlayerDetectionZone
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wandercontroler = $wanderControler



func _physics_process(delta):
	knockBack = knockBack.move_toward(Vector2.ZERO, friction * delta)
	knockBack= move_and_slide(knockBack)

	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			seek_player()			
			if wandercontroler.get_time_left() == 0:
				Update_Wander()			
			
		WANDER:
			seek_player()
			if wandercontroler.get_time_left() == 0:
				Update_Wander()
			accelerate_towards_point(wandercontroler.target_position, delta)			
			if global_position.distance_to(wandercontroler.target_position) <= 4 :
				Update_Wander()
			
		CHASE:
			var player = playerDetectionZone.player
			if player !=null:
				accelerate_towards_point(player.global_position, delta)	
			else:
				state = IDLE
				
			#sprite.flip_h = velocity.x < 0
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta *400
	velocity = move_and_slide(velocity)
	
	
func Update_Wander():
	state = pick_random_state([IDLE, WANDER])
	wandercontroler.start_timer_wander(rand_range(1,2))
	
func accelerate_towards_point(position, delta):
	var direction = global_position.direction_to(position)
	velocity= velocity.move_toward(direction * maxSpeed,Acceleration * delta)	
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockBack = area.knockback_vector * knockBackPower
	hurtBox.create_hit_effect()


func _on_Stats_no_health():
	queue_free()
	var enemtDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemtDeathEffect)
	enemtDeathEffect.global_position =global_position
