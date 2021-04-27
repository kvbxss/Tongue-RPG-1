extends KinematicBody2D


var velocity = Vector2.ZERO 

enum { #tworzenie zmiennych (stałych) którym przypisywane są wartości: dla tego przypadku MOVE = 0, ROLL = 1, ATTACK = 2.
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE
export var MAX_SPEED = 80
export var  ACCELERATION = 500
export var FRICTION = 1000
var roll_vector = Vector2.DOWN


onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox


func _ready():
	animationTree.active = true # animation tree nie bedzie włączone dopóki gra nie wystartuje. (do tworzenia animacji)
	swordHitbox.knockback_vector = roll_vector

	
##Smh manipulative by the physics MOVE ROLL ATTACK movement
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
		

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
		
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	if Input.is_action_just_pressed("Roll"):
		state = ROLL

	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
func roll_state(delta):
	velocity = roll_vector * MAX_SPEED * 1.3
	animationState.travel("Roll")
	move()
		
		
func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	state = MOVE
