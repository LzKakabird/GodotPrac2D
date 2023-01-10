extends Node2D


func _process(delta):
	if Input.is_action_just_pressed("attack"):
		queue_free()
		#不会立刻移除，大概在最后一帧移除
	
