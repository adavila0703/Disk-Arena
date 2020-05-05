#PLAYER
extends KinematicBody2D

#THANKS THAT NEED TO BE DONE.
#1. FIGURE OUT HOW TO STOP THE COLLISION OF THE PROJECTILE AND THE PLAYER
#2. COOLDOWN

var player_id = 1
#PROJECTILE SPEED!!
var shoot_speed = 50000
#This should load the player 2 not player 1, using player 1 for testing.
var arrow = preload("Player1_projectile.tscn")

#PLAYER SPEED
export (int) var speed = 200

#TIMER START/ DELAY TIME/ BOOKING IF TIMER IS TRUE
var timer = null
var bullet_delay = 2
var can_shoot = true

#SET VECTOR
var velocity = Vector2()

#READY FUNCTION
func _ready():
	#A group name for organization
	add_to_group("player2")
	#TIMER/COOLDOWN
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(bullet_delay)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	set_process(true)

#INPUTS THAT ARE BEING READ 
func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x +=1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	if Input.is_action_just_pressed('ui_select'):
		pass
	velocity = velocity.normalized() * speed

#PLAYER PROCESS(Deleted 8/12/2018 for testing )


#PROJECTILE BEING SHOT WITH SPACE BAR OR USER INPUT (Deleted 8/12/2018 for testing )


#TIMER OR COOLDOWN FOR PROJECTILE FUNCTION
func on_timeout_complete():
	can_shoot = true
	#TIMER ENDS AT 0

func player2_dead():
	queue_free()
	
#NOTE: need to pass in delta from func _fixed_process or func _process
#NEW FULL PROJECTILE CODE
func _shoot_arrow(delta):
	var new_arrow = arrow.instance()
	#COLLISION FOR THIS PLAYER PROJECTILE IS SET TO 1 AND 2 SO THEY ONLY COLLIED WITH WALLS AND NOT HIMSELF
	#ENEMY PLAYERS WILL HAVE TO HAVE A DIFFERENT MASK AND LAYER IN ORDER FOR THE PROJECTILE TO REGISTER
	new_arrow.set_collision_layer(2)
	new_arrow.set_collision_mask(1)

	var arrow_rotation = get_angle_to(get_global_mouse_position()) + self.get_rotation()
	new_arrow.set_rotation(arrow_rotation)
	new_arrow.set_global_position(self.get_global_position())
	get_parent().add_child(new_arrow)
	var rigidbody_vector = (get_global_mouse_position() - self.get_position()).normalized()
	new_arrow.set_linear_velocity(rigidbody_vector * shoot_speed * delta)
	
	
