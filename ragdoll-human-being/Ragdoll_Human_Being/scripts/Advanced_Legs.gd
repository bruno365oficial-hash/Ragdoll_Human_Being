extends RigidBody2D

@export var is_right_leg: bool = false
@export var lower_leg: RigidBody2D
@export var leg_speed_multiplier: float = 0.16 

var time: float = 0.0

func _physics_process(delta: float) -> void:
	var real_velocity = abs(linear_velocity.x)
	
	# TRICK: We lock the leg direction to the right as well!
	var direction := 1.0
	
	var is_running := Input.is_key_pressed(KEY_SHIFT)
	
	var current_thigh_swing = 32.0 if is_running else 15.0
	var current_knee_bend = 42.0 if is_running else 18.0
	
	# Now it only relies on whether the body is actually moving
	if real_velocity > 10.0:
		time += delta * real_velocity * leg_speed_multiplier
		var phase_offset = PI if is_right_leg else 0.0
		
		# 1. THIGH MOVEMENT
		var thigh_motion = cos(time + phase_offset) * current_thigh_swing * direction
		angular_velocity = thigh_motion
		
		# 2. LOWER LEG MOVEMENT (Knee)
		if lower_leg:
			var knee_motion = (sin(time + phase_offset) + 1.0) * current_knee_bend * direction
			lower_leg.angular_velocity = knee_motion
	else:
		# If it gets stuck somewhere, the legs relax
		time = move_toward(time, 0.0, 4.0 * delta)
		angular_velocity = move_toward(angular_velocity, 0, 15.0 * delta)
		if lower_leg:
			lower_leg.angular_velocity = move_toward(lower_leg.angular_velocity, 0, 15.0 * delta)
