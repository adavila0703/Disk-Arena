extends RigidBody2D

var timer = null
var bullet_delay = 2
var alive = true

func _ready():
	#TIMER/COOLDOWN
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(bullet_delay)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	set_process(true)

#INPUTS THAT ARE BEING READ
func get_input():
	if Input.is_action_just_pressed('ui_select'):
		pass

#PLAYER PROCESS
func _physics_process(delta):
	get_input()
#PROJECTILE BEING SHOT WITH SPACE BAR OR USER INPUT
	if Input.is_action_just_pressed('ui_select'):
		pass
	if Input.is_action_just_released('ui_select') && alive:
		alive = false
		timer.start()

#SIGNAL FOR WHEN PLAYER 1 PROJECTILE COLLIDES WITH PLAYER 2
func _on_Player1_Projectile_body_entered(body):
	if body.get_groups().has("player2"):
		queue_free()
		body.player2_dead()

#TIMER OR COOLDOWN FOR PROJECTILE FUNCTION
func on_timeout_complete():
	alive = true
	if alive == true:
		#queue free is to destroy the object
		queue_free()
	#TIMER ENDS AT 0
