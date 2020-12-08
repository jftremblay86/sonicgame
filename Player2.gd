extends KinematicBody2D

export var Acceleration = 700
export var MaxSpeed = 80
export var Friction = 600
export var roll_speed = 200
export var dash_speed = 160

signal playerdead

enum {
	WALK,
	RUNNIN,
	ROLL,
	SLEEP,
	FLY,
	ATTACK,
	DEAD
}

var state = FLY
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

var stats = Stats2Stats
onready var animationPlayer2 = $AnimationPlayer2
onready var animationTree2 = $AnimationTree2
onready var animationOnState2 = animationTree2.get("parameters/playback")
onready var SwordHitBox1 = $HitBoxPivot1/SwordHitBox1
onready var hurtBox = $HurtBox
onready var playerDetectionZone= $PlayerDetectionZone
onready var MinDist= $MinDist
onready var player1 = get_tree().get_root().get_node("/root/Player")
onready var startMenu = get_tree().get_root().get_node("/root/StartMenu")

func _ready():
	player1.connect("player1dead",self,"changeToWalk")
	startMenu.connect("reloadgame",self,"reloadScene")
	animationTree2.active = true
		
	SwordHitBox1.knockback_vector=roll_vector
	
	
func _physics_process(delta):
	match state:
		FLY:
			fly_state(delta)	
		WALK:
			move_state(delta)
		ROLL:
			roll_state(delta)
		SLEEP:
			sleep_state(delta)
		ATTACK:
			attack_state(delta)
		DEAD:
			dead_state(delta)
		
	

func move_state(delta):
	set_collision_layer_bit(1,true)
	set_collision_mask_bit(0,true)
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		SwordHitBox1.knockback_vector = input_vector
		animationTree2.set("parameters/Idle/blend_position", input_vector)
		animationTree2.set("parameters/Fly/blend_position", input_vector)
		animationTree2.set("parameters/Fly/blend_position", input_vector)
		animationTree2.set("parameters/Walk/blend_position", input_vector)
		animationTree2.set("parameters/Attack/blend_position", input_vector)
		animationTree2.set("parameters/Roll/blend_position", input_vector)
		animationTree2.set("parameters/Run/blend_position", input_vector)
		animationTree2.set("parameters/Sleep/blend_position", input_vector)
		animationOnState2.travel("Walk")
		velocity = velocity.move_toward(input_vector * MaxSpeed, Acceleration * delta)
	else:
		animationOnState2.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
				
	move()   #||("ui_left")||("ui_up")||("ui_down"))
	if Input.is_action_pressed("Run")&& (Input.is_action_pressed("ui_right")||Input.is_action_pressed("ui_left")||Input.is_action_pressed("ui_up")||Input.is_action_pressed("ui_down")):
		MaxSpeed = dash_speed
		animationOnState2.travel("Run")
			
	if stats.health == 0:
		get_tree().change_scene("res://StartMenu.tscn")
			
	if Input.is_action_just_released("Run"):
		MaxSpeed= 80
			
	if Input.is_action_just_pressed("Roll"):
		state = ROLL
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("sleep"):
		state = SLEEP
			
	if stats.health == 0:
		queue_free()
		
		
func fly_state(delta):
	move()
	var player = playerDetectionZone.player
	if playerDetectionZone.can_see_player():
		
		animationOnState2.travel("Fly")
		if velocity.x > 0:
			get_node( "Sprite" ).set_flip_h( false )			

		accelerate_towards_point(player.global_position, delta)
	

		
	
func changeToWalk():
	state = WALK
	
func sleep_state(_delta):
	velocity= Vector2.ZERO
	animationOnState2.travel("Sleep")
	if (Input.is_action_just_pressed("ui_right")||Input.is_action_just_pressed("ui_left")||Input.is_action_just_pressed("ui_up")||Input.is_action_just_pressed("ui_down")):
		state = WALK
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("Roll"):
		state = ROLL
	

func attack_state(_delta):
	velocity= Vector2.ZERO
	animationOnState2.travel("Attack")
	
func roll_state(_delta):
	velocity= roll_vector * roll_speed
	animationOnState2.travel("Roll")
	move()
	
func ROLLAnimationFinished():
	velocity = velocity * 0.8
	MaxSpeed = 80
	state=WALK

func attackAnimationFinished():
	MaxSpeed = 80
	state= WALK
	
func move():
	velocity = move_and_slide(velocity)

func dead_state(delta):
	emit_signal("p2dead")

func _on_HurtBox_area_entered(_area):

	stats.health -=1
	hurtBox.start_invicibility(0.5)
	hurtBox.create_hit_effect()

	
func accelerate_towards_point(position, delta):
	var direction = global_position.direction_to(position)
	if MinDist.can_see_player():
		MaxSpeed=0;
	else:
		MaxSpeed=dash_speed;
	velocity= velocity.move_toward(direction * MaxSpeed,Acceleration * delta)
	
func reloadScene():
	get_tree().reload_current_scene()
	

signal p2dead
